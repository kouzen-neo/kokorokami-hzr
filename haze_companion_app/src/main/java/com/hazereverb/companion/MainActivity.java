package com.hazereverb.companion;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.VpnService;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity implements ServerService.LogCallback {
    private static final int VPN_REQUEST_CODE = 2001;

    private View viewStatusDot;
    private TextView textServerStatus;
    private Button btnToggleServer;
    private Button btnLaunchGame;
    private Button btnClearLogs;
    private CheckBox checkboxDnsRedirect;
    private TextView textLogs;
    private ScrollView scrollLogs;

    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final StringBuilder logBuilder = new StringBuilder();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        viewStatusDot = findViewById(R.id.view_status_dot);
        textServerStatus = findViewById(R.id.text_server_status);
        btnToggleServer = findViewById(R.id.btn_toggle_server);
        btnLaunchGame = findViewById(R.id.btn_launch_game);
        btnClearLogs = findViewById(R.id.btn_clear_logs);
        checkboxDnsRedirect = findViewById(R.id.checkbox_dns_redirect);
        textLogs = findViewById(R.id.text_logs);
        scrollLogs = findViewById(R.id.scroll_logs);

        btnToggleServer.setOnClickListener(v -> toggleServer());
        btnLaunchGame.setOnClickListener(v -> launchHazeReverb());
        btnClearLogs.setOnClickListener(v -> {
            logBuilder.setLength(0);
            ServerService.clearLogs();
            textLogs.setText("[Logs cleared]\n");
        });

        ServerService.setCallback(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateUI(ServerService.isServerRunning());
    }

    @Override
    protected void onDestroy() {
        ServerService.setCallback(null);
        super.onDestroy();
    }

    private void toggleServer() {
        if (ServerService.isServerRunning()) {
            // Stop
            Intent stopIntent = new Intent(this, ServerService.class);
            stopIntent.setAction(ServerService.ACTION_STOP);
            startService(stopIntent);

            Intent stopVpn = new Intent(this, LocalDnsVpnService.class);
            stopVpn.setAction(LocalDnsVpnService.ACTION_STOP);
            startService(stopVpn);

            updateUI(false);
        } else {
            // Start DNS VPN if requested
            if (checkboxDnsRedirect.isChecked()) {
                Intent vpnPrepareIntent = VpnService.prepare(this);
                if (vpnPrepareIntent != null) {
                    startActivityForResult(vpnPrepareIntent, VPN_REQUEST_CODE);
                    return;
                } else {
                    startDnsVpn();
                }
            }
            startServerService();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                startDnsVpn();
            } else {
                Toast.makeText(this, "DNS redirect permission denied. Server will still run on 127.0.0.1.", Toast.LENGTH_LONG).show();
            }
            startServerService();
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    private void startDnsVpn() {
        Intent vpnIntent = new Intent(this, LocalDnsVpnService.class);
        vpnIntent.setAction(LocalDnsVpnService.ACTION_START);
        startService(vpnIntent);
    }

    private void startServerService() {
        Intent serverIntent = new Intent(this, ServerService.class);
        serverIntent.setAction(ServerService.ACTION_START);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serverIntent);
        } else {
            startService(serverIntent);
        }
        updateUI(true);
    }

    private void updateUI(boolean running) {
        mainHandler.post(() -> {
            if (running) {
                viewStatusDot.setBackgroundColor(getColor(R.color.accent_green));
                textServerStatus.setText(R.string.status_running);
                textServerStatus.setTextColor(getColor(R.color.accent_green));
                btnToggleServer.setText(R.string.btn_stop);
                btnToggleServer.setBackgroundColor(getColor(R.color.accent_red));
            } else {
                viewStatusDot.setBackgroundColor(getColor(R.color.accent_red));
                textServerStatus.setText(R.string.status_stopped);
                textServerStatus.setTextColor(getColor(R.color.accent_red));
                btnToggleServer.setText(R.string.btn_start);
                btnToggleServer.setBackgroundColor(getColor(R.color.primary));
            }
        });
    }

    private void launchHazeReverb() {
        String[] candidatePackages = new String[]{
                "com.gennmu.hazereverben",
                "com.gennmugame.hazereverb",
                "com.gennmu.hazereverb",
                "com.gennmugame.hazereverben",
                "com.feimo.hazereverben",
                "com.feimo.hazereverb",
                "com.feimogames.hazereverb",
                "com.feimo.hazereverb.bilibili",
                "com.feimo.hazereverb.google",
                "com.feimo.hazereverb.qooapp"
        };

        PackageManager pm = getPackageManager();
        Intent launchIntent = null;
        String foundPackage = null;

        for (String pkg : candidatePackages) {
            try {
                launchIntent = pm.getLaunchIntentForPackage(pkg);
                if (launchIntent != null) {
                    foundPackage = pkg;
                    break;
                }
            } catch (Exception ignored) {}
        }

        if (launchIntent == null) {
            // Fuzzy search among installed apps
            try {
                java.util.List<android.content.pm.PackageInfo> installed = pm.getInstalledPackages(0);
                for (android.content.pm.PackageInfo pi : installed) {
                    String pName = pi.packageName != null ? pi.packageName.toLowerCase() : "";
                    CharSequence labelSeq = pi.applicationInfo != null ? pm.getApplicationLabel(pi.applicationInfo) : "";
                    String label = labelSeq != null ? labelSeq.toString().toLowerCase() : "";

                    if (pName.contains("hazereverb") || pName.contains("haze") ||
                        label.contains("haze") || label.contains("reverb") ||
                        label.contains("绯色") || label.contains("残机") || label.contains("殘機") ||
                        label.contains("苍雾") || label.contains("蒼霧")) {
                        launchIntent = pm.getLaunchIntentForPackage(pi.packageName);
                        if (launchIntent != null) {
                            foundPackage = pi.packageName;
                            break;
                        }
                    }
                }
            } catch (Exception e) {
                onLogLine("[Host] Package scan warning: " + e.getMessage());
            }
        }

        if (launchIntent != null) {
            onLogLine("[Host] Launching game package: " + foundPackage);
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            try {
                startActivity(launchIntent);
            } catch (Exception e) {
                onLogLine("[Host] Launch failed: " + e.getMessage());
                Toast.makeText(this, "Launch error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }
        } else {
            onLogLine("[Host] Haze Reverb package not found on this device.");
            Toast.makeText(this, "Game APK not found. Please verify Haze Reverb is installed.", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onLogLine(String line) {
        mainHandler.post(() -> {
            logBuilder.append(line).append("\n");
            textLogs.setText(logBuilder.toString());
            scrollLogs.post(() -> scrollLogs.fullScroll(View.FOCUS_DOWN));
        });
    }

    @Override
    public void onServerStatusChanged(boolean running) {
        updateUI(running);
    }
}
