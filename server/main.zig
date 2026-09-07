const std = @import("std");
const c = std.c;
const GatewayServer = @import("gateway.zig").GatewayServer;
const GameServer = @import("gameserver.zig").GameServer;

pub fn main(init: std.process.Init.Minimal) !void {
    std.debug.print(
        \\
        \\=============================================================
        \\              HAZE REVERB - SERVER EMULATOR
        \\=============================================================
        \\
    , .{});

    var bind_ip: []const u8 = "127.0.0.1";
    if (init.args.vector.len > 1) {
        bind_ip = std.mem.span(init.args.vector[1]);
    } else if (c.getenv("SERVER_IP")) |p| {
        bind_ip = std.mem.span(p);
    } else {
        std.debug.print("[Server] Note: No IP specified, defaulting to 127.0.0.1 (pass LAN IP as argument or SERVER_IP=<IP> for mobile access)\n", .{});
    }

    var game_addr_buf: [128]u8 = undefined;
    const game_addr = try std.fmt.bufPrint(&game_addr_buf, "{s}:8888", .{bind_ip});

    std.debug.print("[Server] Gateway Public Address : http://{s}:8100\n", .{bind_ip});
    std.debug.print("[Server] GameServer Target       : {s}\n", .{game_addr});
    std.debug.print("[Server] Android Hosts Mapping  : {s} cwveren2.feimogames.com\n", .{bind_ip});
    std.debug.print("[Server] Initializing Gateway (Port 8100) & Game Server (Port 8888)...\n\n", .{});

    var gateway = GatewayServer.init(8100, bind_ip, game_addr);
    var gameserver = GameServer.init(8888);

    // Spawn Gateway in thread
    const gw_thread = try std.Thread.spawn(.{}, runGateway, .{&gateway});
    // Spawn Game Server in thread
    const gs_thread = try std.Thread.spawn(.{}, runGameServer, .{&gameserver});

    std.debug.print("[Server] All services running! Ready to receive client connections.\n", .{});

    gw_thread.join();
    gs_thread.join();
}

fn runGateway(gw: *GatewayServer) void {
    gw.start() catch |err| {
        std.debug.print("[Gateway] Error: {}\n", .{err});
    };
}

fn runGameServer(gs: *GameServer) void {
    gs.start() catch |err| {
        std.debug.print("[GameServer] Error: {}\n", .{err});
    };
}
