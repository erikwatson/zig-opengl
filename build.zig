const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = mode,
    });

    // Add include path for glad.h (src/include)
    exe.addIncludePath(.{ .cwd_relative = "src/include" }); // This is the crucial part to find glad.h

    // Add glad.c to the build, explicitly passing the include path
    const glad = b.addObject(.{
        .name = "glad",
        .target = target,
        .optimize = mode,
    });

    glad.addCSourceFile(.{
        .file = b.path("src/glad.c"),
        .flags = &.{ "-I", "src/include" }, // Explicitly pass the include path for glad.h
    });

    exe.addObject(glad);

    // Link OpenGL
    exe.linkSystemLibrary("GL"); // On macOS/Linux
    // exe.linkSystemLibrary("opengl32"); // On Windows

    // Ensure Zig finds SDL3 (Homebrew installed it in /usr/local/opt/sdl2)
    exe.addIncludePath(.{ .cwd_relative = "/usr/local/opt/sdl3/include" });
    exe.addLibraryPath(.{ .cwd_relative = "/usr/local/opt/sdl3/lib" });
    exe.linkSystemLibrary("SDL3");

    b.installArtifact(exe);
}
