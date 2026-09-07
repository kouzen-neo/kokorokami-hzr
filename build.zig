const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "server_haze",
        .root_module = b.createModule(.{
            .root_source_file = b.path("server/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the server");
    run_step.dependOn(&run_cmd.step);

    // APK build step: zig build apk
    const apk_builder = b.addExecutable(.{
        .name = "build_apk",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/build_apk.zig"),
            .target = b.graph.host,
            .optimize = .ReleaseFast,
            .link_libc = true,
        }),
    });
    const run_apk = b.addRunArtifact(apk_builder);
    if (b.args) |args| {
        run_apk.addArgs(args);
    }
    const apk_step = b.step("apk", "Build Haze Companion Android APK");
    apk_step.dependOn(&run_apk.step);
}
