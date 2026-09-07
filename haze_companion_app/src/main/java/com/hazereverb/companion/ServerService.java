package com.hazereverb.companion;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.system.Os;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class ServerService extends Service {
    private static final String TAG = "ServerService";
    private static final String CHANNEL_ID = "haze_server_channel";
    private static final int NOTIF_ID = 1001;

    public static final String ACTION_START = "com.hazereverb.companion.START_SERVER";
    public static final String ACTION_STOP = "com.hazereverb.companion.STOP_SERVER";

    static {
        System.loadLibrary("server_haze");
    }

    // Native JNI methods
    public static native void redirectOutputToPipe(int writeFd);
    public static native int startNativeServer();
    public static native void stopNativeServer();

    public interface LogCallback {
        void onLogLine(String line);
        void onServerStatusChanged(boolean running);
    }

    private static LogCallback activeCallback = null;
    private static boolean isRunning = false;
    private static final List<String> logHistory = new ArrayList<>();

    private Thread serverThread = null;
    private Thread pipeThread = null;
    private ParcelFileDescriptor[] pipe = null;

    public static synchronized void setCallback(LogCallback cb) {
        activeCallback = cb;
        if (cb != null) {
            cb.onServerStatusChanged(isRunning);
            for (String line : logHistory) {
                cb.onLogLine(line);
            }
        }
    }

    public static synchronized boolean isServerRunning() {
        return isRunning;
    }

    public static synchronized void clearLogs() {
        logHistory.clear();
    }

    private static synchronized void appendLog(String line) {
        if (logHistory.size() > 500) {
            logHistory.remove(0);
        }
        logHistory.add(line);
        if (activeCallback != null) {
            activeCallback.onLogLine(line);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP.equals(intent.getAction())) {
            stopServer();
            stopForeground(true);
            stopSelf();
            return START_NOT_STICKY;
        }

        if (!isRunning) {
            Notification notif = buildNotification();
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE);
            } else {
                startForeground(NOTIF_ID, notif);
            }
            startServer();
        }
        return START_STICKY;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.notif_channel_name),
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Background status for Haze Reverb Server");
            NotificationManager nm = getSystemService(NotificationManager.class);
            if (nm != null) {
                nm.createNotificationChannel(channel);
            }
        }
    }

    private Notification buildNotification() {
        Intent contentIntent = new Intent(this, MainActivity.class);
        PendingIntent piContent = PendingIntent.getActivity(
                this, 0, contentIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
        );

        Intent stopIntent = new Intent(this, ServerService.class);
        stopIntent.setAction(ACTION_STOP);
        PendingIntent piStop = PendingIntent.getService(
                this, 1, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
        );

        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder = new Notification.Builder(this, CHANNEL_ID);
        } else {
            builder = new Notification.Builder(this);
        }

        return builder
                .setContentTitle(getString(R.string.status_running))
                .setContentText(getString(R.string.notif_running_text))
                .setSmallIcon(R.drawable.ic_launcher)
                .setContentIntent(piContent)
                .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop Server", piStop)
                .setOngoing(true)
                .build();
    }

    private synchronized void startServer() {
        if (isRunning) return;
        isRunning = true;
        if (activeCallback != null) activeCallback.onServerStatusChanged(true);

        serverThread = new Thread(() -> {
            try {
                File filesDir = getFilesDir();
                appendLog("[Host] Setting working directory: " + filesDir.getAbsolutePath());

                // Extract server_assets directory
                extractAssetDir("server_assets", new File(filesDir, "server_assets"));

                // Redirect native stdout/stderr to Java pipe for live log view
                try {
                    pipe = ParcelFileDescriptor.createPipe();
                    redirectOutputToPipe(pipe[1].getFd());

                    pipeThread = new Thread(() -> {
                        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new ParcelFileDescriptor.AutoCloseInputStream(pipe[0])))) {
                            String line;
                            while ((line = reader.readLine()) != null) {
                                appendLog(line);
                            }
                        } catch (IOException ignored) {}
                    }, "HazeLogPipe");
                    pipeThread.start();
                } catch (Exception e) {
                    Log.w(TAG, "Could not redirect pipe: " + e.getMessage());
                }

                appendLog("[Host] Starting native Zig server (libserver_haze.so)...");
                int res = startNativeServer();
                if (res != 0) {
                    appendLog("[Host Error] Native server failed to start: " + res);
                } else {
                    appendLog("[Host] Native server running successfully on 127.0.0.1!");
                }

            } catch (Exception e) {
                appendLog("[Host Error] " + e.getMessage());
                Log.e(TAG, "Server error", e);
                isRunning = false;
                if (activeCallback != null) activeCallback.onServerStatusChanged(false);
                stopForeground(true);
                stopSelf();
            }
        }, "HazeServerThread");

        serverThread.start();
    }

    private synchronized void stopServer() {
        if (!isRunning) return;
        try {
            stopNativeServer();
        } catch (Exception ignored) {}
        isRunning = false;
        if (activeCallback != null) activeCallback.onServerStatusChanged(false);
        appendLog("[Host] Server stopped by user.");
    }

    private void extractAssetFile(String assetName, File destFile) throws IOException {
        if (destFile.exists() && destFile.length() > 0) return;
        destFile.getParentFile().mkdirs();
        try (InputStream in = getAssets().open(assetName);
             OutputStream out = new FileOutputStream(destFile)) {
            byte[] buf = new byte[16384];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
        }
    }

    private void extractAssetDir(String assetDir, File destDir) {
        try {
            String[] files = getAssets().list(assetDir);
            if (files == null || files.length == 0) {
                extractAssetFile(assetDir, destDir);
                return;
            }
            if (!destDir.exists()) destDir.mkdirs();
            for (String file : files) {
                String subAsset = assetDir + "/" + file;
                File subDest = new File(destDir, file);
                extractAssetDir(subAsset, subDest);
            }
        } catch (IOException e) {
            Log.w(TAG, "Could not extract " + assetDir + ": " + e.getMessage());
        }
    }

    @Override
    public void onDestroy() {
        stopServer();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
