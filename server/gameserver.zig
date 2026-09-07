const std = @import("std");
const c = std.c;
const protocol = @import("protocol.zig");
const data_tables = @import("data_tables.zig");

pub const GameServer = struct {
    port: u16,
    running: bool = false,
    sock_fd: c_int = -1,

    pub fn init(port: u16) GameServer {
        return .{
            .port = port,
            .running = false,
            .sock_fd = -1,
        };
    }

    pub fn stop(self: *GameServer) void {
        self.running = false;
        if (self.sock_fd >= 0) {
            _ = c.shutdown(self.sock_fd, 2);
            _ = c.close(self.sock_fd);
            self.sock_fd = -1;
        }
    }

    pub fn start(self: *GameServer) !void {
        const sock_fd = c.socket(c.AF.INET, c.SOCK.STREAM, 0);
        if (sock_fd < 0) {
            std.debug.print("[GameServer] Failed to create socket\n", .{});
            return error.SocketCreationFailed;
        }
        self.sock_fd = sock_fd;
        defer {
            if (self.sock_fd >= 0) {
                _ = c.close(self.sock_fd);
                self.sock_fd = -1;
            }
        }

        const enable: c_int = 1;
        if (c.setsockopt(sock_fd, c.SOL.SOCKET, c.SO.REUSEADDR, &enable, @sizeOf(c_int)) != 0) {
            std.debug.print("[GameServer] Failed to set SO_REUSEADDR on port {}\n", .{self.port});
            return error.SetSockOptFailed;
        }

        var addr: c.sockaddr.in = undefined;
        addr.family = c.AF.INET;
        addr.port = std.mem.nativeToBig(u16, self.port);
        addr.addr = 0; // INADDR_ANY (0.0.0.0)

        if (c.bind(sock_fd, @ptrCast(&addr), @sizeOf(c.sockaddr.in)) != 0) {
            std.debug.print("[GameServer] Failed to bind to port {}\n", .{self.port});
            return error.BindFailed;
        }

        if (c.listen(sock_fd, 32) != 0) {
            std.debug.print("[GameServer] Failed to listen on port {}\n", .{self.port});
            return error.ListenFailed;
        }

        self.running = true;
        std.debug.print("[GameServer] TCP Game Server listening on 0.0.0.0:{}\n", .{self.port});

        while (self.running) {
            var client_addr: c.sockaddr.in = undefined;
            var client_len: c.socklen_t = @sizeOf(c.sockaddr.in);

            const client_fd = c.accept(sock_fd, @ptrCast(&client_addr), &client_len);
            if (client_fd < 0) continue;

            // Handle client in thread
            _ = std.Thread.spawn(.{}, handleClient, .{client_fd}) catch |err| {
                std.debug.print("[GameServer] Failed to spawn thread for client (fd: {}): {}\n", .{ client_fd, err });
                _ = c.close(client_fd);
            };
        }
    }

    fn readExact(fd: c_int, buf: []u8) bool {
        var total_read: usize = 0;
        while (total_read < buf.len) {
            const n = c.recv(fd, buf.ptr + total_read, buf.len - total_read, 0);
            if (n <= 0) return false;
            total_read += @intCast(n);
        }
        return true;
    }

    fn sendAll(fd: c_int, data: []const u8) !void {
        var total_sent: usize = 0;
        while (total_sent < data.len) {
            const sent = c.send(fd, data[total_sent..data.len].ptr, data.len - total_sent, 0);
            if (sent <= 0) return error.SendFailed;
            total_sent += @intCast(sent);
        }
    }

    fn sendPacket(fd: c_int, mid: u32, tag: u32, user_id: u32, payload: []const u8) !void {
        var hdr: [16]u8 = undefined;
        std.mem.writeInt(u32, hdr[0..4], @intCast(payload.len), .big);
        std.mem.writeInt(u32, hdr[4..8], mid, .big);
        std.mem.writeInt(u32, hdr[8..12], tag, .big);
        std.mem.writeInt(u32, hdr[12..16], user_id, .big);
        try sendAll(fd, &hdr);
        if (payload.len > 0) {
            try sendAll(fd, payload);
        }
    }

    fn handleClient(client_fd: c_int) void {
        defer _ = c.close(client_fd);
        std.debug.print("[GameServer] New client connected (fd: {})\n", .{client_fd});

        // Set socket timeouts (60s recv, 10s send) and TCP_NODELAY
        var rcv_timeout = c.timeval{ .sec = 60, .usec = 0 };
        var snd_timeout = c.timeval{ .sec = 10, .usec = 0 };
        const nodelay: c_int = 1;
        _ = c.setsockopt(client_fd, c.SOL.SOCKET, c.SO.RCVTIMEO, &rcv_timeout, @sizeOf(c.timeval));
        _ = c.setsockopt(client_fd, c.SOL.SOCKET, c.SO.SNDTIMEO, &snd_timeout, @sizeOf(c.timeval));
        _ = c.setsockopt(client_fd, 6, 1, &nodelay, @sizeOf(c_int)); // IPPROTO_TCP, TCP_NODELAY

        var header_buf: [16]u8 = undefined;
        var payload_buf: [65536]u8 = undefined;
        var response_proto_buf: [65536 * 2]u8 = undefined;
        var last_battle_level_id: i32 = 10101;
        var player_head: i32 = 10000;
        var player_head_frame: i32 = 10000;
        var player_menu_role: i32 = 10001;
        var player_home_role: i32 = 90000001; // Franca (default assistant from SteamLocalData 104020)

        var player_nickname_buf: [64]u8 = undefined;
        var player_nickname_len: usize = 9;
        @memcpy(player_nickname_buf[0..9], "Commander");

        var player_signature_buf: [128]u8 = undefined;
        var player_signature_len: usize = 21;
        @memcpy(player_signature_buf[0..21], "Haze Reverb Commander");

        var player_title_buf: [32]u8 = undefined;
        var player_title_len: usize = 1;
        @memcpy(player_title_buf[0..1], "1");

        var player_birthday_buf: [32]u8 = undefined;
        var player_birthday_len: usize = 5;
        @memcpy(player_birthday_buf[0..5], "01-01");

        while (true) {
            if (!readExact(client_fd, &header_buf)) {
                std.debug.print("[GameServer] Client disconnected (fd: {})\n", .{client_fd});
                break;
            }

            const payload_len = std.mem.readInt(u32, header_buf[0..4], .big);
            const mid = std.mem.readInt(u32, header_buf[4..8], .big);
            const tag = std.mem.readInt(u32, header_buf[8..12], .big);
            const user_id = std.mem.readInt(u32, header_buf[12..16], .big);

            if (payload_len > payload_buf.len) {
                std.debug.print("[GameServer] Payload too large: {d}\n", .{payload_len});
                break;
            }
            if (payload_len > 0) {
                if (!readExact(client_fd, payload_buf[0..payload_len])) {
                    break;
                }
            }

            std.debug.print("[GameServer] <-- Recv MID: {d} | Tag: {d} | UserID: {d} | Payload: {d} bytes\n", .{
                mid, tag, user_id, payload_len,
            });

            switch (mid) {
                protocol.MSGID.HEARTBEAT => {
                    // Reply Heartbeat
                    const proto_len = protocol.encodeHeartbeatMSG(&response_proto_buf, "ack");
                    sendPacket(client_fd, protocol.MSGID.HEARTBEAT, tag, user_id, response_proto_buf[0..proto_len]) catch break;
                    std.debug.print("[GameServer] --> Sent Heartbeat Response (MID: 1000)\n", .{});
                },
                protocol.MSGID.CLIENT_VERIFY_REQ => {
                    std.debug.print("[GameServer] [LOGIN] Handling CLIENT_VERIFY_REQ from UserID: {d}...\n", .{user_id});

                    // 1. Send CLIENT_VERIFY_ACK (MID: 1002, errNo = 0)
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_VERIFY_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_VERIFY_ACK (MID: 1002, errNo: 0)\n", .{});

                    // 2. Send CLIENT_VERIFY_NTF (MID: 1003, initial player state)
                    const ntf_len = protocol.encodeGodModeVerifyNTF(&response_proto_buf, @intCast(user_id), player_nickname_buf[0..player_nickname_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_VERIFY_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_VERIFY_NTF (MID: 1003) with player profile ({d} bytes)\n", .{ntf_len});
                },
                protocol.MSGID.CLIENT_GET_GAME_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_GAME_INFO_REQ (1223)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_GAME_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetGameInfoNTF(&response_proto_buf, player_home_role);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_GAME_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_GAME_INFO_ACK (1224) & NTF (1225)\n", .{});
                },
                protocol.MSGID.CLIENT_ACTIVITY_GET_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_ACTIVITY_GET_REQ (1292)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_ACTIVITY_GET_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientActivityGetNTF(&response_proto_buf, @intCast(user_id));
                    sendPacket(client_fd, protocol.MSGID.CLIENT_ACTIVITY_GET_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_ACTIVITY_GET_ACK (1293) & NTF (1294)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_HOME_DATA_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_HOME_DATA_REQ (1199)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HOME_DATA_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetHomeDataNTF(&response_proto_buf, player_home_role);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HOME_DATA_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_HOME_DATA_ACK (1200) & NTF (1201)\n", .{});
                },
                protocol.MSGID.CLIENT_LIMIT_SIGN_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_LIMIT_SIGN_REQ (2064)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_LIMIT_SIGN_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientLimitSignNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_LIMIT_SIGN_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_LIMIT_SIGN_ACK (2065) & NTF (2066) (Awarded Sign-in Rewards!)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_GIFT_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_GIFT_INFO_REQ (2038)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_GIFT_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    // Empty NTF (2040)
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_GIFT_INFO_NTF, tag, user_id, &[_]u8{}) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_GIFT_INFO_ACK (2039) & NTF (2040)\n", .{});
                },
                protocol.MSGID.CLIENT_BINGO_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BINGO_INFO_REQ (2224)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BINGO_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    // Empty NTF (2226)
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BINGO_INFO_NTF, tag, user_id, &[_]u8{}) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BINGO_INFO_ACK (2225) & NTF (2226)\n", .{});
                },
                protocol.MSGID.CLIENT_LEVEL_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_LEVEL_INFO_REQ (1010)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_LEVEL_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientLevelInfoNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_LEVEL_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_LEVEL_INFO_ACK (1011) & NTF (1012)\n", .{});
                },
                protocol.MSGID.CLIENT_RECRUIT_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_RECRUIT_REQ (1013)...\n", .{});
                    const req = protocol.decodeClientRecruitREQ(payload_buf[0..payload_len]);
                    std.debug.print("[GameServer] Recruit Req: Pool {d}, Count {d}, Index {d}\n", .{ req.recruitID, req.count, req.clientRecruitIndex });

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_RECRUIT_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientRecruitNTF(&response_proto_buf, req.recruitID, req.count, req.clientRecruitIndex);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_RECRUIT_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_RECRUIT_ACK (1014) & NTF (1015) (Summoned {d} Drivers!)\n", .{req.count});
                },
                protocol.MSGID.CLIENT_TASK_PERFORM_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_TASK_PERFORM_REQ (1019)...\n", .{});
                    const req = protocol.decodeClientTaskPerformREQ(payload_buf[0..payload_len]);
                    std.debug.print("[GameServer] Task Perform Req: Type {d}, ID {d}\n", .{ req.taskType, req.taskID });

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TASK_PERFORM_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTaskPerformNTF(&response_proto_buf, req.taskType, req.taskID);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TASK_PERFORM_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TASK_PERFORM_ACK (1020) & NTF (1021) (Claimed Task {d}!)\n", .{req.taskID});
                },
                protocol.MSGID.CLIENT_SIGN_IN_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SIGN_IN_REQ (1016)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SIGN_IN_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientSignInNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SIGN_IN_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SIGN_IN_ACK (1017) & NTF (1018)\n", .{});
                },
                protocol.MSGID.CLIENT_BATTLE_SUPPORT_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BATTLE_SUPPORT_REQ (1277)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BATTLE_SUPPORT_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    // Empty NTF (1279)
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BATTLE_SUPPORT_NTF, tag, user_id, &[_]u8{}) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BATTLE_SUPPORT_ACK (1278) & NTF (1279)\n", .{});
                },
                protocol.MSGID.CLIENT_TEAM_SAVE_REQ, protocol.MSGID.CLIENT_TEAM_SAVE_LEGACY_REQ => {
                    const ack_mid = if (mid == protocol.MSGID.CLIENT_TEAM_SAVE_REQ)
                        protocol.MSGID.CLIENT_TEAM_SAVE_ACK
                    else
                        protocol.MSGID.CLIENT_TEAM_SAVE_LEGACY_ACK;
                    const ntf_mid = if (mid == protocol.MSGID.CLIENT_TEAM_SAVE_REQ)
                        protocol.MSGID.CLIENT_TEAM_SAVE_NTF
                    else
                        protocol.MSGID.CLIENT_TEAM_SAVE_LEGACY_NTF;
                    std.debug.print("[GameServer] Handling CLIENT_TEAM_SAVE_REQ ({d})...\n", .{mid});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, ack_mid, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTeamSaveNTF(&response_proto_buf, payload_buf[0..payload_len]);
                    sendPacket(client_fd, ntf_mid, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TEAM_SAVE_ACK ({d}) & NTF ({d}) (Team formation saved & validated!)\n", .{ ack_mid, ntf_mid });
                },
                protocol.MSGID.CLIENT_SET_LEVEL_STAR_EX_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_LEVEL_STAR_EX_REQ (1283)...\n", .{});
                    const level_id = protocol.decodeLevelIdFromReq(payload_buf[0..payload_len]);
                    last_battle_level_id = level_id;
                    std.debug.print("[GameServer] Battle Start Level ID: {d}\n", .{level_id});

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_LEVEL_STAR_EX_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientSetLevelStarExNTF(&response_proto_buf, level_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_LEVEL_STAR_EX_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_LEVEL_STAR_EX_ACK (1284) & NTF (1285) (Battle simulation started with LeftWin=true!)\n", .{});
                },
                protocol.MSGID.CLIENT_CHOOSE_BATTLE_REWARD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHOOSE_BATTLE_REWARD_REQ (1280) for Level ID: {d}...\n", .{last_battle_level_id});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_BATTLE_REWARD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientChooseBattleRewardNTF(&response_proto_buf, last_battle_level_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_BATTLE_REWARD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHOOSE_BATTLE_REWARD_ACK (1281) & NTF (1282) (Awarded 3-Star Victory Rewards!)\n", .{});
                },
                protocol.MSGID.CLIENT_SET_LEVEL_STAR_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_LEVEL_STAR_REQ (1040)...\n", .{});
                    const level_id = protocol.decodeLevelIdFromReq(payload_buf[0..payload_len]);
                    last_battle_level_id = level_id;
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_LEVEL_STAR_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientSetLevelStarNTF(&response_proto_buf, level_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_LEVEL_STAR_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_LEVEL_STAR_ACK (1041) & NTF (1042)\n", .{});
                },
                protocol.MSGID.CLIENT_TOWER_BATTLE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_TOWER_BATTLE_REQ (1301)...\n", .{});
                    const level_id = protocol.decodeLevelIdFromReq(payload_buf[0..payload_len]);
                    last_battle_level_id = level_id;
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TOWER_BATTLE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTowerBattleNTF(&response_proto_buf, level_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TOWER_BATTLE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TOWER_BATTLE_ACK (1302) & NTF (1303)\n", .{});
                },
                protocol.MSGID.CLIENT_TOWER_REWARD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_TOWER_REWARD_REQ (1298)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TOWER_REWARD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTowerRewardNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TOWER_REWARD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TOWER_REWARD_ACK (1299) & NTF (1300)\n", .{});
                },
                protocol.MSGID.CLIENT_GUIDE_BATTLE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GUIDE_BATTLE_REQ (1307)...\n", .{});
                    const level_id = protocol.decodeLevelIdFromReq(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GUIDE_BATTLE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTowerBattleNTF(&response_proto_buf, level_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GUIDE_BATTLE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GUIDE_BATTLE_ACK (1308) & NTF (1309)\n", .{});
                },
                protocol.MSGID.CLIENT_GUIDE_REWARD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GUIDE_REWARD_REQ (1304)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GUIDE_REWARD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTowerRewardNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GUIDE_REWARD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GUIDE_REWARD_ACK (1305) & NTF (1306)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_RAND_SHOP_ITEM_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_RAND_SHOP_ITEM_REQ (1310)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_RAND_SHOP_ITEM_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetRandShopItemNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_RAND_SHOP_ITEM_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_RAND_SHOP_ITEM_ACK (1311) & NTF (1312) (Random Shop Catalog)\n", .{});
                },
                protocol.MSGID.CLIENT_BUY_RAND_SHOP_ITEM_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BUY_RAND_SHOP_ITEM_REQ (1313)...\n", .{});
                    const req = protocol.decodeClientBuyRandShopItemREQ(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_RAND_SHOP_ITEM_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientBuyRandShopItemNTF(&response_proto_buf, req.id, req.count);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_RAND_SHOP_ITEM_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BUY_RAND_SHOP_ITEM_ACK (1314) & NTF (1315) (Item {d} x{d})\n", .{ req.id, req.count });
                },
                protocol.MSGID.CLIENT_BUY_GOODS_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BUY_GOODS_REQ (1088)...\n", .{});
                    const req = protocol.decodeClientBuyGoodsREQ(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_GOODS_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientBuyGoodsNTF(&response_proto_buf, req.goodsID, req.buyNum);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_GOODS_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BUY_GOODS_ACK (1089) & NTF (1090) (Goods {d} x{d})\n", .{ req.goodsID, req.buyNum });
                },
                protocol.MSGID.CLIENT_SHOP_LIST_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SHOP_LIST_REQ (2007)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SHOP_LIST_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientShopListNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SHOP_LIST_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SHOP_LIST_ACK (2008) & NTF (2009) (Catalog of 84 Skins!)\n", .{});
                },
                protocol.MSGID.CLIENT_TASK_GET_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_TASK_GET_REQ (1106)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TASK_GET_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientTaskGetNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TASK_GET_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TASK_GET_ACK (1107) & NTF (1108) (Tasks & Achievement Stats)\n", .{});
                },
                protocol.MSGID.CLIENT_EMAIL_DATA_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_DATA_REQ (1070)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DATA_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailDataNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DATA_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_DATA_ACK (1071) & NTF (1072) (Mail List)\n", .{});
                },
                protocol.MSGID.CLIENT_EMAIL_GOODS_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_GOODS_REQ (1073)...\n", .{});
                    const email_id = protocol.decodeEmailID(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_GOODS_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailGoodsNTF(&response_proto_buf, email_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_GOODS_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_GOODS_ACK (1074) & NTF (1075) (Claimed Mail {d})\n", .{email_id});
                },
                protocol.MSGID.CLIENT_EMAIL_GOODS_ALL_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_GOODS_ALL_REQ (1079)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_GOODS_ALL_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailGoodsAllNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_GOODS_ALL_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_GOODS_ALL_ACK (1080) & NTF (1081) (Claimed All Mail)\n", .{});
                },
                protocol.MSGID.CLIENT_EMAIL_LOOK_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_LOOK_REQ (1103)...\n", .{});
                    const email_id = protocol.decodeEmailID(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_LOOK_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailLookNTF(&response_proto_buf, email_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_LOOK_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_LOOK_ACK (1104) & NTF (1105) (Looked Mail {d})\n", .{email_id});
                },
                protocol.MSGID.CLIENT_EMAIL_DELETE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_DELETE_REQ (1076)...\n", .{});
                    const email_id = protocol.decodeEmailID(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DELETE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailDeleteNTF(&response_proto_buf, email_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DELETE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_DELETE_ACK (1077) & NTF (1078) (Deleted Mail {d})\n", .{email_id});
                },
                protocol.MSGID.CLIENT_EMAIL_DELETE_ALL_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EMAIL_DELETE_ALL_REQ (1082)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DELETE_ALL_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEmailGoodsAllNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EMAIL_DELETE_ALL_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EMAIL_DELETE_ALL_ACK (1083) & NTF (1084)\n", .{});
                },
                protocol.MSGID.CLIENT_HERO_LEVEL_UP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_LEVEL_UP_REQ (1025)...\n", .{});
                    const hero_id = protocol.decodeHeroIdFromReq(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_LEVEL_UP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroLevelUPNTF(&response_proto_buf, hero_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_LEVEL_UP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_LEVEL_UP_ACK (1026) & NTF (1027) (Hero {d})\n", .{hero_id});
                },
                protocol.MSGID.CLIENT_HERO_STAR_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_STAR_REQ (1022)...\n", .{});
                    const hero_id = protocol.decodeHeroIdFromReq(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_STAR_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroStarNTF(&response_proto_buf, hero_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_STAR_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_STAR_ACK (1023) & NTF (1024) (Hero {d})\n", .{hero_id});
                },
                protocol.MSGID.CLIENT_HERO_SKILL_UP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_SKILL_UP_REQ (1031)...\n", .{});
                    const hero_id = protocol.decodeHeroIdFromReq(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_SKILL_UP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroSkillUPNTF(&response_proto_buf, hero_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_SKILL_UP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_SKILL_UP_ACK (1032) & NTF (1033) (Hero {d})\n", .{hero_id});
                },
                protocol.MSGID.CLIENT_HERO_DATA_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_DATA_REQ (1028)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_DATA_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroDataNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_DATA_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_DATA_ACK (1029) & NTF (1030)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_FRIEND_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_FRIEND_INFO_REQ (1238)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_FRIEND_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetFriendInfoNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_FRIEND_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_FRIEND_INFO_ACK (1239) & NTF (1240)\n", .{});
                },

                // ==================== STAGE SWEEP ====================
                protocol.MSGID.CLIENT_SWEEP_LEVEL_STAR_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SWEEP_LEVEL_STAR_REQ (1220)...\n", .{});
                    const req = protocol.decodeClientSweepLevelStarREQ(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SWEEP_LEVEL_STAR_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientSweepLevelStarNTF(&response_proto_buf, req.levelID, req.frequency);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SWEEP_LEVEL_STAR_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SWEEP_LEVEL_STAR_ACK (1221) & NTF (1222) (Swept {d} x{d})\n", .{ req.levelID, req.frequency });
                },

                // ==================== PROFILE & PERSONALIZATION ====================
                protocol.MSGID.CLIENT_CHOOSE_NIKE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHOOSE_NIKE_REQ (1097)...\n", .{});
                    const new_name = protocol.decodeStringField1(payload_buf[0..payload_len]);
                    if (new_name.len > 0 and new_name.len <= player_nickname_buf.len) {
                        @memcpy(player_nickname_buf[0..new_name.len], new_name);
                        player_nickname_len = new_name.len;
                    }
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_NIKE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeStringNTF(&response_proto_buf, 1, player_nickname_buf[0..player_nickname_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_NIKE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHOOSE_NIKE_ACK (1098) & NTF (1099) (Name: {s})\n", .{player_nickname_buf[0..player_nickname_len]});
                },
                protocol.MSGID.CLIENT_SET_HEAD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_HEAD_REQ (1166)...\n", .{});
                    const head_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    if (head_id > 0) player_head = head_id;

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_HEAD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeInt32NTF(&response_proto_buf, 1, player_head);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_HEAD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_HEAD_ACK (1167) & NTF (1168) (Head: {d})\n", .{player_head});
                },
                protocol.MSGID.CLIENT_SET_HEAD_FRAME_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_HEAD_FRAME_REQ (1169)...\n", .{});
                    const frame_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    if (frame_id > 0) player_head_frame = frame_id;

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_HEAD_FRAME_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeInt32NTF(&response_proto_buf, 1, player_head_frame);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_HEAD_FRAME_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_HEAD_FRAME_ACK (1170) & NTF (1171) (Frame: {d})\n", .{player_head_frame});
                },
                protocol.MSGID.CLIENT_SET_SIGNATURE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_SIGNATURE_REQ (1172)...\n", .{});
                    const new_sig = protocol.decodeStringField1(payload_buf[0..payload_len]);
                    if (new_sig.len > 0 and new_sig.len <= player_signature_buf.len) {
                        @memcpy(player_signature_buf[0..new_sig.len], new_sig);
                        player_signature_len = new_sig.len;
                    }
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_SIGNATURE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeStringNTF(&response_proto_buf, 1, player_signature_buf[0..player_signature_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_SIGNATURE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_SIGNATURE_ACK (1173) & NTF (1174)\n", .{});
                },
                protocol.MSGID.CLIENT_SET_TITLE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SET_TITLE_REQ (1100)...\n", .{});
                    const new_title = protocol.decodeStringField1(payload_buf[0..payload_len]);
                    if (new_title.len > 0 and new_title.len <= player_title_buf.len) {
                        @memcpy(player_title_buf[0..new_title.len], new_title);
                        player_title_len = new_title.len;
                    }
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_TITLE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeStringNTF(&response_proto_buf, 1, player_title_buf[0..player_title_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SET_TITLE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SET_TITLE_ACK (1101) & NTF (1102)\n", .{});
                },
                protocol.MSGID.CLIENT_CHOOSE_MENU_ROLE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHOOSE_MENU_ROLE_REQ (1094)...\n", .{});
                    const role_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    if (role_id > 0) player_menu_role = role_id;

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_MENU_ROLE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeInt32NTF(&response_proto_buf, 1, player_menu_role);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_MENU_ROLE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHOOSE_MENU_ROLE_ACK (1095) & NTF (1096) (Lobby Role: {d})\n", .{player_menu_role});
                },
                protocol.MSGID.CLIENT_CHANGE_BIRTHDAY_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHANGE_BIRTHDAY_REQ (1387)...\n", .{});
                    const bday = protocol.decodeStringField1(payload_buf[0..payload_len]);
                    if (bday.len > 0 and bday.len <= player_birthday_buf.len) {
                        @memcpy(player_birthday_buf[0..bday.len], bday);
                        player_birthday_len = bday.len;
                    }
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_BIRTHDAY_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeStringNTF(&response_proto_buf, 1, player_birthday_buf[0..player_birthday_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_BIRTHDAY_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHANGE_BIRTHDAY_ACK (1388) & NTF (1389)\n", .{});
                },
                protocol.MSGID.CLIENT_CHANGE_SKIN_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHANGE_SKIN_REQ (1390)...\n", .{});
                    const skin_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_SKIN_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeInt32NTF(&response_proto_buf, 1, skin_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_SKIN_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHANGE_SKIN_ACK (1391) & NTF (1392) (Skin: {d})\n", .{skin_id});
                },
                protocol.MSGID.CLIENT_GET_HIGH_LADDER_BASE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_HIGH_LADDER_BASE_REQ (1175)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HIGH_LADDER_BASE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetHighLadderBaseNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HIGH_LADDER_BASE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_HIGH_LADDER_BASE_ACK (1176) & NTF (1177)\n", .{});
                },
                protocol.MSGID.CLIENT_FRIEND_SUPPORT_GET_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_FRIEND_SUPPORT_GET_REQ (1247)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_FRIEND_SUPPORT_GET_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientFriendSupportGetNTF(&response_proto_buf, @intCast(user_id));
                    sendPacket(client_fd, protocol.MSGID.CLIENT_FRIEND_SUPPORT_GET_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_FRIEND_SUPPORT_GET_ACK (1248) & NTF (1249)\n", .{});
                },

                // ==================== INVENTORY & ITEMS ====================
                protocol.MSGID.CLIENT_USE_GOODS_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_USE_GOODS_REQ (1055)...\n", .{});
                    const goods_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_USE_GOODS_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientUseGoodsNTF(&response_proto_buf, goods_id, 1);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_USE_GOODS_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_USE_GOODS_ACK (1056) & NTF (1057)\n", .{});
                },
                protocol.MSGID.CLIENT_EXPAND_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EXPAND_REQ (1091)...\n", .{});
                    const slots = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EXPAND_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientExpandNTF(&response_proto_buf, slots + 5);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EXPAND_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EXPAND_ACK (1092) & NTF (1093)\n", .{});
                },
                protocol.MSGID.CLIENT_DECOMPOSE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_DECOMPOSE_REQ (1049)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_DECOMPOSE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientDecomposeNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_DECOMPOSE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_DECOMPOSE_ACK (1050) & NTF (1051)\n", .{});
                },
                protocol.MSGID.CLIENT_CHANGE_LOCK_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHANGE_LOCK_REQ (1396)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_LOCK_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientChangeLockNTF(&response_proto_buf, 1);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHANGE_LOCK_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHANGE_LOCK_ACK (1397) & NTF (1398)\n", .{});
                },

                // ==================== DRIVER INTIMACY & GEAR ====================
                protocol.MSGID.CLIENT_HERO_FAVOR_UP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_FAVOR_UP_REQ (1354)...\n", .{});
                    const hero_id = protocol.decodeHeroIdFromReq(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_FAVOR_UP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroFavorUPNTF(&response_proto_buf, hero_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_FAVOR_UP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_FAVOR_UP_ACK (1355) & NTF (1356) (Hero {d})\n", .{hero_id});
                },
                protocol.MSGID.CLIENT_HERO_CHANGE_ARMOR_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HERO_CHANGE_ARMOR_REQ (1085)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_CHANGE_ARMOR_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHeroChangeArmorNTF(&response_proto_buf, payload_buf[0..payload_len]);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HERO_CHANGE_ARMOR_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HERO_CHANGE_ARMOR_ACK (1086) & NTF (1087)\n", .{});
                },
                protocol.MSGID.CLIENT_EQUIP_UP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_EQUIP_UP_REQ (1064)...\n", .{});
                    const equip_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EQUIP_UP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEquipUPNTF(&response_proto_buf, equip_id, 10);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_EQUIP_UP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_EQUIP_UP_ACK (1065) & NTF (1066)\n", .{});
                },

                // ==================== STAMINA & BUY COUNTERS ====================
                protocol.MSGID.CLIENT_GET_BUY_NUMBER_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_BUY_NUMBER_REQ (1196)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_BUY_NUMBER_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetBuyNumberNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_BUY_NUMBER_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_BUY_NUMBER_ACK (1197) & NTF (1198)\n", .{});
                },
                protocol.MSGID.CLIENT_BUY_VIGOR_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BUY_VIGOR_REQ (1187)...\n", .{});
                    const vid = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_VIGOR_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientBuySpecialNTF(&response_proto_buf, vid);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUY_VIGOR_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BUY_VIGOR_ACK (1188) & NTF (1189)\n", .{});
                },

                // ==================== ONE-KEY TASK CLAIM & CDKEY ====================
                protocol.MSGID.CLIENT_TASK_REWARD_ONE_KEY_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_TASK_REWARD_ONE_KEY_REQ (2001)...\n", .{});
                    const ack_len = protocol.encodeClientTaskRewardOneKeyAck(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_TASK_REWARD_ONE_KEY_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_TASK_REWARD_ONE_KEY_ACK (2002) (One-Click Claim All!)\n", .{});
                },
                protocol.MSGID.CLIENT_CDKEY_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CDKEY_REQ (1339)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CDKEY_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientCDKeyNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CDKEY_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CDKEY_ACK (1340) & NTF (1341) (Redeemed to Mail)\n", .{});
                },

                // ==================== ARK / DORMITORY BASE ====================
                protocol.MSGID.CLIENT_HOMEBASE_BUILD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HOMEBASE_BUILD_REQ (1322)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOMEBASE_BUILD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHomeBaseBuildNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOMEBASE_BUILD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HOMEBASE_BUILD_ACK (1323) & NTF (1324)\n", .{});
                },
                protocol.MSGID.CLIENT_BUILD_HOME_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_BUILD_HOME_REQ (1202)...\n", .{});
                    const target_home_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUILD_HOME_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHomeBuildNTF(&response_proto_buf, target_home_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_BUILD_HOME_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_BUILD_HOME_ACK (1203) & NTF (1204)\n", .{});
                },
                protocol.MSGID.CLIENT_HOME_REAP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HOME_REAP_REQ (1205)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOME_REAP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHomeReapNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOME_REAP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HOME_REAP_ACK (1206) & NTF (1207) (Harvested base resources!)\n", .{});
                },
                protocol.MSGID.CLIENT_CHOOSE_HOME_ROLE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CHOOSE_HOME_ROLE_REQ (1328)...\n", .{});
                    const role_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    if (role_id >= 90000001 and role_id <= 90000004) player_home_role = role_id;

                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_HOME_ROLE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeInt32NTF(&response_proto_buf, 1, player_home_role);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CHOOSE_HOME_ROLE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CHOOSE_HOME_ROLE_ACK (1329) & NTF (1330) (Dorm Role: {d})\n", .{player_home_role});
                },

                // ==================== EXPEDITIONS ====================
                protocol.MSGID.CLIENT_GET_HOME_EXPEDITION_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_HOME_EXPEDITION_REQ (1235)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HOME_EXPEDITION_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetHomeExpeditionNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_HOME_EXPEDITION_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_HOME_EXPEDITION_ACK (1236) & NTF (1237)\n", .{});
                },
                protocol.MSGID.CLIENT_START_HOME_EXPEDITION_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_START_HOME_EXPEDITION_REQ (1208)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_START_HOME_EXPEDITION_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientStartHomeExpeditionNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_START_HOME_EXPEDITION_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_START_HOME_EXPEDITION_ACK (1209) & NTF (1210)\n", .{});
                },
                protocol.MSGID.CLIENT_END_HOME_EXPEDITION_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_END_HOME_EXPEDITION_REQ (1232)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_END_HOME_EXPEDITION_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientEndHomeExpeditionNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_END_HOME_EXPEDITION_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_END_HOME_EXPEDITION_ACK (1233) & NTF (1234)\n", .{});
                },
                protocol.MSGID.CLIENT_CANCEL_HOME_EXPEDITION_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CANCEL_HOME_EXPEDITION_REQ (1399)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CANCEL_HOME_EXPEDITION_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    sendPacket(client_fd, protocol.MSGID.CLIENT_CANCEL_HOME_EXPEDITION_NTF, tag, user_id, &[_]u8{}) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CANCEL_HOME_EXPEDITION_ACK (1400) & NTF (1401)\n", .{});
                },

                // ==================== BASE SYNTHESIS / CRAFTING ====================
                protocol.MSGID.CLIENT_HOME_MAKE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_HOME_MAKE_REQ (1211)...\n", .{});
                    const make_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOME_MAKE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientHomeMakeNTF(&response_proto_buf, make_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_HOME_MAKE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_HOME_MAKE_ACK (1212) & NTF (1213)\n", .{});
                },
                protocol.MSGID.CLIENT_SKILLMATERIALS_MAKE_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_SKILLMATERIALS_MAKE_REQ (1357)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SKILLMATERIALS_MAKE_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientSkillMaterialsMakeNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_SKILLMATERIALS_MAKE_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_SKILLMATERIALS_MAKE_ACK (1358) & NTF (1359)\n", .{});
                },

                // ==================== ONSEN / BATHHOUSE MINI-GAME ====================
                protocol.MSGID.CLIENT_REPORT_GAME_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_REPORT_GAME_INFO_REQ (1226)...\n", .{});
                    const event_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_REPORT_GAME_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientReportGameInfoNTF(&response_proto_buf, event_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_REPORT_GAME_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_REPORT_GAME_INFO_ACK (1227) & NTF (1228)\n", .{});
                },
                protocol.MSGID.CLIENT_ANSWER_GAME_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_ANSWER_GAME_INFO_REQ (1229)...\n", .{});
                    const role_id = protocol.decodeInt32Field1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_ANSWER_GAME_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientAnswerGameInfoNTF(&response_proto_buf, role_id);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_ANSWER_GAME_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_ANSWER_GAME_INFO_ACK (1230) & NTF (1231)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_N_GAME_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_N_GAME_INFO_REQ (1438)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_N_GAME_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_N_GAME_INFO_NTF, tag, user_id, &[_]u8{}) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_N_GAME_INFO_ACK (1439) & NTF (1440)\n", .{});
                },
                protocol.MSGID.CLIENT_N_GAME_PHASE_UP_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_N_GAME_PHASE_UP_REQ (1441)...\n", .{});
                    const two = protocol.decodeTwoInt32(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_N_GAME_PHASE_UP_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientNGamePhaseUpNTF(&response_proto_buf, two.f1, two.f2);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_N_GAME_PHASE_UP_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_N_GAME_PHASE_UP_ACK (1442) & NTF (1443)\n", .{});
                },
                protocol.MSGID.CLIENT_N_GAME_FINISH_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_N_GAME_FINISH_REQ (1444)...\n", .{});
                    const two = protocol.decodeTwoInt32(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_N_GAME_FINISH_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientNGamePhaseUpNTF(&response_proto_buf, two.f1, 1);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_N_GAME_FINISH_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_N_GAME_FINISH_ACK (1445) & NTF (1446)\n", .{});
                },
                protocol.MSGID.CLIENT_GET_N_GAME_REWARD_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_N_GAME_REWARD_REQ (1447)...\n", .{});
                    const two = protocol.decodeTwoInt32(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_N_GAME_REWARD_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientNGameRewardNTF(&response_proto_buf, two.f1);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_N_GAME_REWARD_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_N_GAME_REWARD_ACK (1448) & NTF (1449)\n", .{});
                },

                // ==================== GUILD / CLUB ====================
                protocol.MSGID.CLIENT_GET_CLUB_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_GET_CLUB_INFO_REQ (1363)...\n", .{});
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_CLUB_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientGetClubInfoNTF(&response_proto_buf);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_GET_CLUB_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_GET_CLUB_INFO_ACK (1364) & NTF (1365)\n", .{});
                },
                protocol.MSGID.CLIENT_CREATE_CLUB_INFO_REQ => {
                    std.debug.print("[GameServer] Handling CLIENT_CREATE_CLUB_INFO_REQ (1366)...\n", .{});
                    const club_name = protocol.decodeStringField1(payload_buf[0..payload_len]);
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CREATE_CLUB_INFO_ACK, tag, user_id, response_proto_buf[0..ack_len]) catch break;

                    const ntf_len = protocol.encodeClientCreateClubInfoNTF(&response_proto_buf, club_name);
                    sendPacket(client_fd, protocol.MSGID.CLIENT_CREATE_CLUB_INFO_NTF, tag, user_id, response_proto_buf[0..ntf_len]) catch break;
                    std.debug.print("[GameServer] --> Sent CLIENT_CREATE_CLUB_INFO_ACK (1367) & NTF (1368) (Club: {s})\n", .{club_name});
                },
                else => {
                    // Generic ACK with errNo = 0
                    const ack_mid = mid + 1;
                    const ack_len = protocol.encodeClientVerifyACK(&response_proto_buf, 0);
                    sendPacket(client_fd, ack_mid, tag, user_id, response_proto_buf[0..ack_len]) catch break;
                    std.debug.print("[GameServer] --> Sent Generic ACK (MID: {d})\n", .{ack_mid});
                },
            }
        }
    }
};
