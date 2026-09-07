const std = @import("std");
const c = std.c;
const GatewayServer = @import("gateway.zig").GatewayServer;
const GameServer = @import("gameserver.zig").GameServer;

var g_gateway: ?GatewayServer = null;
var g_gameserver: ?GameServer = null;
var g_gw_thread: ?std.Thread = null;
var g_gs_thread: ?std.Thread = null;
var g_running = std.atomic.Value(bool).init(false);

// Android Bionic compatibility: Bionic exports __errno() instead of __errno_location()
extern "c" fn __errno() *c_int;
export fn __errno_location() *c_int {
    return __errno();
}

// Android compatibility: dl_iterate_phdr is in libdl, stub it so libdl dependency is not required
export fn dl_iterate_phdr(callback: ?*anyopaque, data: ?*anyopaque) c_int {
    _ = callback;
    _ = data;
    return 0;
}

// Redirects native stdout (1) and stderr (2) to Java pipe FD
export fn Java_com_hazereverb_companion_ServerService_redirectOutputToPipe(
    env: ?*anyopaque,
    thiz: ?*anyopaque,
    write_fd: c_int,
) void {
    _ = env;
    _ = thiz;
    _ = c.dup2(write_fd, 1);
    _ = c.dup2(write_fd, 2);
}

// Starts native Gateway & GameServer in background threads
export fn Java_com_hazereverb_companion_ServerService_startNativeServer(
    env: ?*anyopaque,
    thiz: ?*anyopaque,
) c_int {
    _ = env;
    _ = thiz;

    if (g_running.cmpxchgStrong(false, true, .seq_cst, .seq_cst) != null) return 0; // Already running

    std.debug.print(
        \\
        \\----------------------------------------
        \\  HAZE REVERB COMPANION SERVER
        \\----------------------------------------
        \\
    , .{});

    const bind_ip = "127.0.0.1";
    const game_addr = "127.0.0.1:8888";

    // Ensure working directory is set to app files directory so server_assets can be read
    _ = c.chdir("/data/data/com.hazereverb.companion/files");
    _ = c.chdir("/data/user/0/com.hazereverb.companion/files");

    std.debug.print("[Host] Initializing Gateway on 127.0.0.1:8100...\n", .{});
    std.debug.print("[Host] Initializing GameServer on 127.0.0.1:8888...\n", .{});

    g_gateway = GatewayServer.init(8100, bind_ip, game_addr);
    g_gameserver = GameServer.init(8888);

    g_gw_thread = std.Thread.spawn(.{}, runGateway, .{}) catch return -1;
    g_gs_thread = std.Thread.spawn(.{}, runGameServer, .{}) catch return -2;

    std.debug.print("[Host] All services running on 127.0.0.1! Ready for client.\n", .{});
    return 0;
}

// Gracefully stops native Gateway & GameServer
export fn Java_com_hazereverb_companion_ServerService_stopNativeServer(
    env: ?*anyopaque,
    thiz: ?*anyopaque,
) void {
    _ = env;
    _ = thiz;

    if (g_running.cmpxchgStrong(true, false, .seq_cst, .seq_cst) != null) return; // Not running
    std.debug.print("[Host] Stopping native server...\n", .{});

    if (g_gateway) |*gw| gw.stop();
    if (g_gameserver) |*gs| gs.stop();

    if (g_gw_thread) |t| t.join();
    if (g_gs_thread) |t| t.join();

    g_gw_thread = null;
    g_gs_thread = null;
    g_gateway = null;
    g_gameserver = null;

    std.debug.print("[Host] Native server stopped.\n", .{});
}

fn runGateway() void {
    if (g_gateway) |*gw| {
        gw.start() catch |err| {
            std.debug.print("[Gateway] Error: {}\n", .{err});
        };
    }
}

fn runGameServer() void {
    if (g_gameserver) |*gs| {
        gs.start() catch |err| {
            std.debug.print("[GameServer] Error: {}\n", .{err});
        };
    }
}
