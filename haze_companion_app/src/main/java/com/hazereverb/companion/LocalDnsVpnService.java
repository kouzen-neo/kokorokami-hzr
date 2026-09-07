package com.hazereverb.companion;

import android.content.Intent;
import android.net.VpnService;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class LocalDnsVpnService extends VpnService implements Runnable {
    private static final String TAG = "LocalDnsVpn";
    public static final String ACTION_START = "com.hazereverb.companion.START_VPN";
    public static final String ACTION_STOP = "com.hazereverb.companion.STOP_VPN";

    private ParcelFileDescriptor vpnInterface = null;
    private Thread workerThread = null;
    private ExecutorService forwardExecutor = null;
    private volatile boolean isRunning = false;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP.equals(intent.getAction())) {
            stopVpn();
            stopSelf();
            return START_NOT_STICKY;
        }

        if (!isRunning) {
            startVpn();
        }
        return START_STICKY;
    }

    private synchronized void startVpn() {
        if (isRunning) return;
        try {
            Builder builder = new Builder();
            builder.setSession("HazeLocalDns");
            builder.addAddress("10.244.0.2", 24);
            builder.addDnsServer("10.244.0.1");
            builder.addRoute("10.244.0.1", 32);

            vpnInterface = builder.establish();
            if (vpnInterface == null) {
                Log.e(TAG, "Failed to establish VPN interface");
                return;
            }

            forwardExecutor = Executors.newFixedThreadPool(4);
            isRunning = true;
            workerThread = new Thread(this, "HazeDnsWorker");
            workerThread.start();
            Log.i(TAG, "Local DNS VPN service started");
        } catch (Exception e) {
            Log.e(TAG, "Error starting DNS VPN", e);
        }
    }

    private synchronized void stopVpn() {
        isRunning = false;
        if (vpnInterface != null) {
            try {
                vpnInterface.close();
            } catch (IOException ignored) {}
            vpnInterface = null;
        }
        if (workerThread != null) {
            workerThread.interrupt();
            workerThread = null;
        }
        if (forwardExecutor != null) {
            forwardExecutor.shutdownNow();
            forwardExecutor = null;
        }
        Log.i(TAG, "Local DNS VPN service stopped");
    }

    @Override
    public void run() {
        if (vpnInterface == null) return;
        FileInputStream in = new FileInputStream(vpnInterface.getFileDescriptor());
        FileOutputStream out = new FileOutputStream(vpnInterface.getFileDescriptor());
        byte[] packet = new byte[4096];

        while (isRunning) {
            try {
                int length = in.read(packet);
                if (length <= 0) {
                    Thread.sleep(20);
                    continue;
                }
                handlePacket(packet, length, out);
            } catch (Exception e) {
                if (!isRunning) break;
            }
        }
    }

    private void handlePacket(byte[] packet, int length, FileOutputStream out) {
        // Must be IPv4 (first nibble == 4) and UDP (protocol 17)
        if (length < 28 || (packet[0] >> 4) != 4 || packet[9] != 17) return;

        int ipHdrLen = (packet[0] & 0x0F) * 4;
        if (ipHdrLen + 8 > length) return;

        int destPort = ((packet[ipHdrLen + 2] & 0xFF) << 8) | (packet[ipHdrLen + 3] & 0xFF);
        if (destPort != 53) return;

        int dnsOffset = ipHdrLen + 8;
        int dnsLen = length - dnsOffset;
        if (dnsLen < 12) return;

        String domain = extractDomain(packet, dnsOffset, dnsLen);
        if (domain.contains("feimo") || domain.contains("feimogames.com")) {
            Log.i(TAG, "[Redirect] Domain: " + domain + " -> 127.0.0.1");
            try {
                byte[] responsePacket = createDnsResponse(packet, length, ipHdrLen, dnsOffset, dnsLen);
                if (responsePacket != null) {
                    synchronized (out) {
                        out.write(responsePacket);
                    }
                }
            } catch (Exception e) {
                Log.w(TAG, "Error writing DNS response: " + e.getMessage());
            }
        } else {
            // Forward other domains to public DNS (8.8.8.8) so QuickGame auth / Google works
            if (forwardExecutor != null && !forwardExecutor.isShutdown()) {
                byte[] reqCopy = new byte[length];
                System.arraycopy(packet, 0, reqCopy, 0, length);
                final String queryDomain = domain;
                forwardExecutor.submit(() -> forwardToUpstream(reqCopy, length, ipHdrLen, dnsOffset, dnsLen, queryDomain, out));
            }
        }
    }

    private String extractDomain(byte[] packet, int dnsOffset, int dnsLen) {
        if (dnsLen < 13) return "";
        int pos = dnsOffset + 12; // Skip 12-byte DNS header
        int end = dnsOffset + dnsLen;
        StringBuilder sb = new StringBuilder();
        while (pos < end) {
            int labelLen = packet[pos++] & 0xFF;
            if (labelLen == 0) break;
            if ((labelLen & 0xC0) != 0) break; // Stop on compression pointer
            if (pos + labelLen > end) break;
            if (sb.length() > 0) sb.append('.');
            for (int i = 0; i < labelLen; i++) {
                sb.append((char) packet[pos++]);
            }
        }
        return sb.toString().toLowerCase();
    }

    private void forwardToUpstream(byte[] reqPacket, int totalLen, int ipHdrLen, int dnsOffset, int dnsLen, String domain, FileOutputStream out) {
        DatagramSocket socket = null;
        try {
            socket = new DatagramSocket();
            protect(socket); // Bypass VPN tunnel to reach actual network
            socket.setSoTimeout(2500);

            // Upstream DNS server
            InetAddress dnsServer = InetAddress.getByName("8.8.8.8");
            DatagramPacket outPacket = new DatagramPacket(reqPacket, dnsOffset, dnsLen, dnsServer, 53);
            socket.send(outPacket);

            byte[] buf = new byte[2048];
            DatagramPacket inPacket = new DatagramPacket(buf, buf.length);
            socket.receive(inPacket);

            Log.d(TAG, "[Forward] Resolved " + domain + " via 8.8.8.8 (" + inPacket.getLength() + " bytes)");
            byte[] forwardResp = createForwardResponse(reqPacket, ipHdrLen, buf, inPacket.getLength());
            if (forwardResp != null) {
                synchronized (out) {
                    out.write(forwardResp);
                }
            }
        } catch (Exception e) {
            Log.w(TAG, "[Forward Error] Domain " + domain + ": " + e.getMessage());
        } finally {
            if (socket != null) {
                socket.close();
            }
        }
    }

    private byte[] createForwardResponse(byte[] reqPacket, int ipHdrLen, byte[] dnsPayload, int dnsPayloadLen) {
        int totalLen = ipHdrLen + 8 + dnsPayloadLen;
        byte[] resp = new byte[totalLen];

        // Copy IP header
        System.arraycopy(reqPacket, 0, resp, 0, ipHdrLen);

        // Swap IP src and dst
        for (int i = 0; i < 4; i++) {
            byte temp = resp[12 + i];
            resp[12 + i] = resp[16 + i];
            resp[16 + i] = temp;
        }

        // Swap UDP ports
        int srcPort = ((reqPacket[ipHdrLen] & 0xFF) << 8) | (reqPacket[ipHdrLen + 1] & 0xFF);
        int dstPort = ((reqPacket[ipHdrLen + 2] & 0xFF) << 8) | (reqPacket[ipHdrLen + 3] & 0xFF);
        resp[ipHdrLen] = (byte) (dstPort >> 8);
        resp[ipHdrLen + 1] = (byte) dstPort;
        resp[ipHdrLen + 2] = (byte) (srcPort >> 8);
        resp[ipHdrLen + 3] = (byte) srcPort;

        // UDP length
        int udpLen = 8 + dnsPayloadLen;
        resp[ipHdrLen + 4] = (byte) (udpLen >> 8);
        resp[ipHdrLen + 5] = (byte) udpLen;
        resp[ipHdrLen + 6] = 0;
        resp[ipHdrLen + 7] = 0;

        // Copy DNS response payload
        System.arraycopy(dnsPayload, 0, resp, ipHdrLen + 8, dnsPayloadLen);

        // Update IPv4 total length
        resp[2] = (byte) (totalLen >> 8);
        resp[3] = (byte) totalLen;

        // Recalculate IPv4 checksum
        resp[10] = 0;
        resp[11] = 0;
        int sum = 0;
        for (int i = 0; i < ipHdrLen; i += 2) {
            sum += ((resp[i] & 0xFF) << 8) | (resp[i + 1] & 0xFF);
        }
        while ((sum >> 16) > 0) {
            sum = (sum & 0xFFFF) + (sum >> 16);
        }
        int checksum = ~sum & 0xFFFF;
        resp[10] = (byte) (checksum >> 8);
        resp[11] = (byte) checksum;

        return resp;
    }

    private byte[] createDnsResponse(byte[] reqPacket, int totalLen, int ipHdrLen, int dnsOffset, int dnsLen) {
        byte[] resp = new byte[dnsOffset + dnsLen + 16];
        System.arraycopy(reqPacket, 0, resp, 0, totalLen);

        // Swap IP src and dst
        for (int i = 0; i < 4; i++) {
            byte temp = resp[12 + i];
            resp[12 + i] = resp[16 + i];
            resp[16 + i] = temp;
        }

        // Swap UDP ports
        int srcPort = ((resp[ipHdrLen] & 0xFF) << 8) | (resp[ipHdrLen + 1] & 0xFF);
        int dstPort = ((resp[ipHdrLen + 2] & 0xFF) << 8) | (resp[ipHdrLen + 3] & 0xFF);
        resp[ipHdrLen] = (byte) (dstPort >> 8);
        resp[ipHdrLen + 1] = (byte) dstPort;
        resp[ipHdrLen + 2] = (byte) (srcPort >> 8);
        resp[ipHdrLen + 3] = (byte) srcPort;

        // DNS header: Standard response, No error
        resp[dnsOffset + 2] = (byte) 0x81;
        resp[dnsOffset + 3] = (byte) 0x80;
        // Answer Count: 1
        resp[dnsOffset + 6] = 0;
        resp[dnsOffset + 7] = 1;

        int writePos = totalLen;
        // Answer pointer: 0xC0 0x0C
        resp[writePos++] = (byte) 0xC0;
        resp[writePos++] = (byte) 0x0C;
        // Type A: 1
        resp[writePos++] = 0;
        resp[writePos++] = 1;
        // Class IN: 1
        resp[writePos++] = 0;
        resp[writePos++] = 1;
        // TTL: 60s
        resp[writePos++] = 0;
        resp[writePos++] = 0;
        resp[writePos++] = 0;
        resp[writePos++] = 60;
        // Data length: 4 bytes (IPv4)
        resp[writePos++] = 0;
        resp[writePos++] = 4;
        // IP: 127.0.0.1
        resp[writePos++] = 127;
        resp[writePos++] = 0;
        resp[writePos++] = 0;
        resp[writePos++] = 1;

        int newTotalLen = writePos;
        // Update IP total length
        resp[2] = (byte) (newTotalLen >> 8);
        resp[3] = (byte) newTotalLen;
        // Update UDP length
        int newUdpLen = newTotalLen - ipHdrLen;
        resp[ipHdrLen + 4] = (byte) (newUdpLen >> 8);
        resp[ipHdrLen + 5] = (byte) newUdpLen;
        resp[ipHdrLen + 6] = 0;
        resp[ipHdrLen + 7] = 0;

        // Calculate IPv4 Header checksum
        resp[10] = 0;
        resp[11] = 0;
        int sum = 0;
        for (int i = 0; i < ipHdrLen; i += 2) {
            sum += ((resp[i] & 0xFF) << 8) | (resp[i + 1] & 0xFF);
        }
        while ((sum >> 16) > 0) {
            sum = (sum & 0xFFFF) + (sum >> 16);
        }
        int checksum = ~sum & 0xFFFF;
        resp[10] = (byte) (checksum >> 8);
        resp[11] = (byte) checksum;

        byte[] finalResp = new byte[newTotalLen];
        System.arraycopy(resp, 0, finalResp, 0, newTotalLen);
        return finalResp;
    }

    @Override
    public void onDestroy() {
        stopVpn();
        super.onDestroy();
    }
}
