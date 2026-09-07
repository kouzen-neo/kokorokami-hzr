const std = @import("std");
const c = std.c;
const protocol = @import("protocol.zig");

extern "c" fn fseek(stream: *c.FILE, offset: c_long, whence: c_int) c_int;
extern "c" fn ftell(stream: *c.FILE) c_long;

pub const GatewayServer = struct {
    port: u16,
    server_ip: []const u8,
    game_server_addr: []const u8,
    running: bool = false,
    sock_fd: c_int = -1,

    pub fn init(port: u16, server_ip: []const u8, game_server_addr: []const u8) GatewayServer {
        return .{
            .port = port,
            .server_ip = server_ip,
            .game_server_addr = game_server_addr,
            .running = false,
            .sock_fd = -1,
        };
    }

    pub fn stop(self: *GatewayServer) void {
        self.running = false;
        if (self.sock_fd >= 0) {
            _ = c.shutdown(self.sock_fd, 2);
            _ = c.close(self.sock_fd);
            self.sock_fd = -1;
        }
    }

    fn sendAll(client_fd: c_int, data: []const u8) !void {
        var sent: usize = 0;
        while (sent < data.len) {
            const n = c.send(client_fd, data[sent..data.len].ptr, data.len - sent, 0);
            if (n <= 0) return error.SendFailed;
            sent += @intCast(n);
        }
    }

    fn sendStaticFile(client_fd: c_int, file_path_z: [*:0]const u8, content_type: []const u8) bool {
        const maybe_file = c.fopen(file_path_z, "rb");
        if (maybe_file == null) return false;
        const fp = maybe_file.?;
        defer _ = c.fclose(fp);

        if (fseek(fp, 0, 2) != 0) return false; // SEEK_END
        const sz = ftell(fp);
        if (sz < 0) return false;
        const file_size: usize = @intCast(sz);
        if (fseek(fp, 0, 0) != 0) return false; // SEEK_SET

        var header_buf: [512]u8 = undefined;
        const header = std.fmt.bufPrint(&header_buf,
            "HTTP/1.1 200 OK\r\n" ++
            "Content-Type: {s}\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Access-Control-Allow-Origin: *\r\n" ++
            "Connection: close\r\n\r\n",
            .{ content_type, file_size },
        ) catch return false;

        sendAll(client_fd, header) catch return false;

        var chunk: [65536]u8 = undefined;
        while (true) {
            const bytes_read = c.fread(&chunk, 1, chunk.len, fp);
            if (bytes_read == 0) break;
            sendAll(client_fd, chunk[0..bytes_read]) catch return false;
        }
        return true;
    }

    pub fn start(self: *GatewayServer) !void {
        const sock_fd = c.socket(c.AF.INET, c.SOCK.STREAM, 0);
        if (sock_fd < 0) {
            std.debug.print("[Gateway] Failed to create socket\n", .{});
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
            std.debug.print("[Gateway] Failed to set SO_REUSEADDR on port {}\n", .{self.port});
            return error.SetSockOptFailed;
        }

        var addr: c.sockaddr.in = undefined;
        addr.family = c.AF.INET;
        addr.port = std.mem.nativeToBig(u16, self.port);
        addr.addr = 0; // INADDR_ANY (0.0.0.0)

        if (c.bind(sock_fd, @ptrCast(&addr), @sizeOf(c.sockaddr.in)) != 0) {
            std.debug.print("[Gateway] Failed to bind to port {}\n", .{self.port});
            return error.BindFailed;
        }

        if (c.listen(sock_fd, 16) != 0) {
            std.debug.print("[Gateway] Failed to listen on port {}\n", .{self.port});
            return error.ListenFailed;
        }

        self.running = true;
        std.debug.print("[Gateway] HTTP Gateway Server listening on 0.0.0.0:{}\n", .{self.port});

        var buffer: [4096]u8 = undefined;

        while (self.running) {
            var client_addr: c.sockaddr.in = undefined;
            var client_len: c.socklen_t = @sizeOf(c.sockaddr.in);

            const client_fd = c.accept(sock_fd, @ptrCast(&client_addr), &client_len);
            if (client_fd < 0) continue;
            defer _ = c.close(client_fd);

            var rcv_timeout = c.timeval{ .sec = 10, .usec = 0 };
            var snd_timeout = c.timeval{ .sec = 10, .usec = 0 };
            _ = c.setsockopt(client_fd, c.SOL.SOCKET, c.SO.RCVTIMEO, &rcv_timeout, @sizeOf(c.timeval));
            _ = c.setsockopt(client_fd, c.SOL.SOCKET, c.SO.SNDTIMEO, &snd_timeout, @sizeOf(c.timeval));

            var total_read: usize = 0;
            while (total_read < buffer.len - 1) {
                const n = c.recv(client_fd, &buffer[total_read], buffer.len - 1 - total_read, 0);
                if (n <= 0) break;
                total_read += @intCast(n);
                buffer[total_read] = 0;

                if (std.mem.indexOf(u8, buffer[0..total_read], "\r\n\r\n")) |hdr_end| {
                    if (std.mem.indexOf(u8, buffer[0..hdr_end], "Content-Length:")) |cl_pos| {
                        const cl_slice = buffer[cl_pos + 15 .. hdr_end];
                        const eol = std.mem.indexOf(u8, cl_slice, "\r\n") orelse cl_slice.len;
                        const content_len = std.fmt.parseInt(usize, std.mem.trim(u8, cl_slice[0..eol], " \t"), 10) catch 0;
                        if (total_read >= hdr_end + 4 + content_len) break;
                    } else {
                        break;
                    }
                }
            }
            if (total_read == 0) continue;

            const req = buffer[0..total_read];
            std.debug.print("\n[Gateway] <-- Request ({d} bytes):\n{s}\n", .{ total_read, req });

            // Extract HTTP path
            var path_start: usize = 0;
            if (std.mem.startsWith(u8, req, "GET ")) {
                path_start = 4;
            } else if (std.mem.startsWith(u8, req, "POST ")) {
                path_start = 5;
            }

            var path_end: usize = path_start;
            while (path_end < req.len and req[path_end] != ' ' and req[path_end] != '?' and req[path_end] != '\r' and req[path_end] != '\n') : (path_end += 1) {}
            const path = if (path_start > 0) req[path_start..path_end] else "";
            std.debug.print("[Gateway] Parsed path: \"{s}\"\n", .{path});

            // Prevent path traversal
            if (std.mem.indexOf(u8, path, "..") != null) continue;

            // 1. Static bundle files under /android/bundles/
            if (std.mem.startsWith(u8, path, "/android/bundles/")) {
                const filename = path["/android/bundles/".len..];
                var file_path_buf: [300]u8 = undefined;
                const file_path_z = std.fmt.bufPrintZ(&file_path_buf, "server_assets/android/bundles/{s}", .{filename}) catch "";

                var content_type: []const u8 = "application/octet-stream";
                if (std.mem.endsWith(u8, filename, ".version") or std.mem.endsWith(u8, filename, ".txt")) {
                    content_type = "text/plain";
                }

                if (sendStaticFile(client_fd, file_path_z.ptr, content_type)) {
                    std.debug.print("[Gateway] Served bundle file: {s}\n", .{file_path_z});
                    continue;
                } else if (std.mem.endsWith(u8, filename, ".version")) {
                    const ver_body = "1.0.0-26-08-31-172308";
                    var header_buf: [256]u8 = undefined;
                    const resp = std.fmt.bufPrint(&header_buf,
                        "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: {d}\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n{s}",
                        .{ ver_body.len, ver_body },
                    ) catch "";
                    sendAll(client_fd, resp) catch |err| {
                        std.debug.print("[Gateway] Failed to send version response: {}\n", .{err});
                    };
                    std.debug.print("[Gateway] Fallback served version string: {s}\n", .{ver_body});
                    continue;
                } else {
                    std.debug.print("[Gateway] Bundle file not found: {s}\n", .{file_path_z});
                    const not_found = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n";
                    sendAll(client_fd, not_found) catch |err| {
                        std.debug.print("[Gateway] Failed to send 404 response: {}\n", .{err});
                    };
                    continue;
                }
            }

            // 2. Localization or options txt
            if (std.mem.indexOf(u8, path, "version_l.txt") != null or std.mem.indexOf(u8, path, "opt.txt") != null) {
                const txt_body = "Localization=true\n";
                var header_buf: [256]u8 = undefined;
                const resp = std.fmt.bufPrint(&header_buf,
                    "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: {d}\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n{s}",
                    .{ txt_body.len, txt_body },
                ) catch "";
                sendAll(client_fd, resp) catch |err| {
                    std.debug.print("[Gateway] Failed to send text response: {}\n", .{err});
                };
                std.debug.print("[Gateway] Served text: {s}\n", .{path});
                continue;
            }

            // 3. /httpLogin (Protobuf PBClient.ClientLoginResult)
            if (std.mem.indexOf(u8, path, "httpLogin") != null or std.mem.indexOf(u8, path, "Login") != null and std.mem.indexOf(u8, path, "version") == null) {
                var pb_buf: [256]u8 = undefined;
                const pb_len = protocol.encodeClientLoginResult(&pb_buf, self.game_server_addr);

                var header_buf: [256]u8 = undefined;
                const header = std.fmt.bufPrint(&header_buf,
                    "HTTP/1.1 200 OK\r\n" ++
                    "Content-Type: application/octet-stream\r\n" ++
                    "Content-Length: {d}\r\n" ++
                    "Access-Control-Allow-Origin: *\r\n" ++
                    "Connection: close\r\n\r\n",
                    .{pb_len},
                ) catch continue;

                sendAll(client_fd, header) catch |err| {
                    std.debug.print("[Gateway] Failed to send login header: {}\n", .{err});
                    continue;
                };
                sendAll(client_fd, pb_buf[0..pb_len]) catch |err| {
                    std.debug.print("[Gateway] Failed to send login payload: {}\n", .{err});
                    continue;
                };
                std.debug.print("[Gateway] Sent PBClient.ClientLoginResult ({d} bytes, addrGate={s})\n", .{ pb_len, self.game_server_addr });
                continue;
            }

            // 4. JSON endpoints
            var response_body_buf: [2048]u8 = undefined;
            var resp_body: []const u8 = "";

            if (std.mem.eql(u8, path, "/version")) {
                resp_body = std.fmt.bufPrint(&response_body_buf,
                    \\{{"code":0,"msg":"success","data":{{"loginName":"Local Zig World","loginUrl":"http://{s}:8100","payUrl":"http://{s}:8100","resUrl":"http://{s}:8100","serVer":"1.0.14","newAppVer":"1.0.14","TextHint":"","CloseDialog":true}}}}
                , .{ self.server_ip, self.server_ip, self.server_ip }) catch "{}";
            } else if (std.mem.indexOf(u8, path, "area") != null or std.mem.indexOf(u8, path, "Area") != null) {
                resp_body = std.fmt.bufPrint(&response_body_buf,
                    \\{{"code":0,"msg":"success","data":{{"areaList":[{{"loginName":"Local Zig World","loginUrl":"http://{s}:8100"}}]}}}}
                , .{self.server_ip}) catch "{}";
            } else if (std.mem.indexOf(u8, path, "server") != null or std.mem.indexOf(u8, path, "Server") != null) {
                resp_body = std.fmt.bufPrint(&response_body_buf,
                    \\{{"code":0,"msg":"success","data":{{"serverList":[{{"loginName":"Local Zig World","loginUrl":"http://{s}:8100","payUrl":"http://{s}:8100","resUrl":"http://{s}:8100","serVer":"1.0.14"}}],"payUrl":"http://{s}:8100","resUrl":"http://{s}:8100","serVer":"1.0.14"}}}}
                , .{ self.server_ip, self.server_ip, self.server_ip, self.server_ip, self.server_ip }) catch "{}";
            } else if (std.mem.indexOf(u8, path, "ping") != null or std.mem.indexOf(u8, path, "Ping") != null) {
                resp_body = std.fmt.bufPrint(&response_body_buf,
                    \\{{"code":0,"msg":"success","data":{{"pingAck":{{"flag":1}}}}}}
                , .{}) catch "{}";
            } else if (std.mem.indexOf(u8, path, "notice") != null or std.mem.indexOf(u8, path, "Notice") != null) {
                resp_body = "{\"errNo\":0,\"code\":0,\"list\":[]}";
            } else {
                resp_body = std.fmt.bufPrint(&response_body_buf,
                    \\{{"code":0,"errNo":0,"msg":"success","loginName":"Local Zig World","loginUrl":"http://{s}:8100","addrGate":"{s}","token":"zig_token","userID":10001,"status":"ok","list":[]}}
                , .{ self.server_ip, self.game_server_addr }) catch "{}";
            }

            var http_header_buf: [512]u8 = undefined;
            const http_resp = std.fmt.bufPrint(&http_header_buf,
                "HTTP/1.1 200 OK\r\n" ++
                "Content-Type: application/json; charset=utf-8\r\n" ++
                "Content-Length: {d}\r\n" ++
                "Access-Control-Allow-Origin: *\r\n" ++
                "Connection: close\r\n\r\n" ++
                "{s}",
                .{ resp_body.len, resp_body },
            ) catch continue;

            sendAll(client_fd, http_resp) catch |err| {
                std.debug.print("[Gateway] Failed to send HTTP response: {}\n", .{err});
            };
            std.debug.print("[Gateway] Sent JSON response ({d} bytes)\n", .{resp_body.len});
        }
    }
};
