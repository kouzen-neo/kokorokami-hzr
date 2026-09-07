const std = @import("std");

extern "c" fn system([*:0]const u8) c_int;
extern "c" fn getenv([*:0]const u8) ?[*:0]const u8;

fn runCmd(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    const cmd = try std.fmt.allocPrintSentinel(allocator, fmt, args, 0);
    defer allocator.free(cmd);
    std.debug.print("[RUN] {s}\n", .{cmd});
    const rc = system(cmd.ptr);
    if (rc != 0) {
        std.debug.print("[ERROR] Command exited with code: {d}\n", .{rc});
        return error.CommandFailed;
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    std.debug.print(
        \\==========================================================
        \\      BUILDING HAZE COMPANION ANDROID APK (ZIG HOST)     
        \\==========================================================
        \\
    , .{});

    var sdk_path: []const u8 = "";
    var allocated_sdk_path = false;
    if (getenv("ANDROID_HOME")) |p| {
        sdk_path = std.mem.span(p);
    } else if (getenv("ANDROID_SDK_ROOT")) |p| {
        sdk_path = std.mem.span(p);
    } else if (getenv("HOME")) |h| {
        sdk_path = try std.fmt.allocPrint(allocator, "{s}/Android/Sdk", .{std.mem.span(h)});
        allocated_sdk_path = true;
    }
    defer if (allocated_sdk_path) allocator.free(sdk_path);

    const aapt2 = try std.fmt.allocPrintSentinel(allocator, "{s}/build-tools/35.0.0/aapt2", .{sdk_path}, 0);
    defer allocator.free(aapt2);
    const d8 = try std.fmt.allocPrintSentinel(allocator, "{s}/build-tools/35.0.0/d8", .{sdk_path}, 0);
    defer allocator.free(d8);
    const zipalign = try std.fmt.allocPrintSentinel(allocator, "{s}/build-tools/35.0.0/zipalign", .{sdk_path}, 0);
    defer allocator.free(zipalign);
    const apksigner = try std.fmt.allocPrintSentinel(allocator, "{s}/build-tools/35.0.0/apksigner", .{sdk_path}, 0);
    defer allocator.free(apksigner);
    const android_jar = try std.fmt.allocPrintSentinel(allocator, "{s}/platforms/android-35/android.jar", .{sdk_path}, 0);
    defer allocator.free(android_jar);

    // Prepare build directory
    try runCmd(allocator, "rm -rf haze_companion_app/build && mkdir -p haze_companion_app/build/lib/arm64-v8a haze_companion_app/build/gen haze_companion_app/build/classes haze_companion_app/build/dex haze_companion_app/build/assets", .{});

    // 1. Cross-compile ARM64 shared library
    std.debug.print("\n--- [1/7] Compiling Zig JNI shared library for Android aarch64 ---\n", .{});
    try runCmd(allocator, "zig build-lib server/jni.zig -target aarch64-linux-musl -lc -O ReleaseFast -dynamic -femit-bin=haze_companion_app/build/lib/arm64-v8a/libserver_haze.so", .{});

    // Copy assets
    std.debug.print("[+] Copying server_assets to APK assets folder...\n", .{});
    try runCmd(allocator, "cp -r server_assets haze_companion_app/build/assets/", .{});

    // 2. Compile resources
    std.debug.print("\n--- [2/7] Compiling Android resources (aapt2 compile) ---\n", .{});
    try runCmd(allocator, "{s} compile --dir haze_companion_app/src/main/res -o haze_companion_app/build/compiled_res.zip", .{aapt2});

    // 3. Link resources & generate R.java
    std.debug.print("\n--- [3/7] Linking resources & generating R.java (aapt2 link) ---\n", .{});
    try runCmd(allocator, "{s} link -I {s} --min-sdk-version 26 --target-sdk-version 34 --manifest haze_companion_app/src/main/AndroidManifest.xml -o haze_companion_app/build/unaligned_res.apk --java haze_companion_app/build/gen haze_companion_app/build/compiled_res.zip --auto-add-overlay", .{ aapt2, android_jar });

    // 4. Compile Java
    std.debug.print("\n--- [4/7] Compiling Java code (javac) ---\n", .{});
    try runCmd(allocator, "javac -cp {s} -d haze_companion_app/build/classes --source 11 --target 11 haze_companion_app/src/main/java/com/hazereverb/companion/*.java haze_companion_app/build/gen/com/hazereverb/companion/*.java", .{android_jar});

    // 5. Convert classes to DEX
    std.debug.print("\n--- [5/7] Converting bytecode to DEX (d8) ---\n", .{});
    try runCmd(allocator, "{s} --output haze_companion_app/build/dex --lib {s} haze_companion_app/build/classes/com/hazereverb/companion/*.class", .{ d8, android_jar });

    // 6. Packaging APK
    std.debug.print("\n--- [6/7] Packaging APK ---\n", .{});
    try runCmd(allocator, "cp haze_companion_app/build/unaligned_res.apk haze_companion_app/build/unaligned.apk", .{});
    try runCmd(allocator, "cd haze_companion_app/build/dex && zip -q -u ../unaligned.apk classes.dex", .{});
    try runCmd(allocator, "cd haze_companion_app/build && zip -q -u -r unaligned.apk lib assets", .{});

    // 7. Align & Sign
    std.debug.print("\n--- [7/7] Aligning & Signing APK ---\n", .{});
    try runCmd(allocator, "{s} -p -f 4 haze_companion_app/build/unaligned.apk haze_companion_app/build/aligned.apk", .{zipalign});
    try runCmd(allocator, "if [ ! -f debug.keystore ]; then keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Android Debug,O=Android,C=US'; fi", .{});
    try runCmd(allocator, "{s} sign --ks debug.keystore --ks-pass pass:android --out haze_companion_app/build/HazeCompanion.apk haze_companion_app/build/aligned.apk", .{apksigner});
    try runCmd(allocator, "{s} verify --verbose haze_companion_app/build/HazeCompanion.apk", .{apksigner});

    std.debug.print(
        \\
        \\==========================================================
        \\ SUCCESS! HazeCompanion.apk created successfully!
        \\ Output : haze_companion_app/build/HazeCompanion.apk
        \\==========================================================
        \\
    , .{});
}
