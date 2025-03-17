const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stb_dep = b.dependency("stb", .{
        .target = target,
        .optimize = optimize,
    });
    const stb_lib = b.addStaticLibrary(.{
        .name = "stb",
        .optimize = optimize,
        .target = target,
    });
    stb_lib.linkLibC();
    stb_lib.root_module.addCSourceFile(.{ .file = stb_dep.path("stb_image.h") });
    stb_lib.root_module.addCMacro("STB_IMAGE_IMPLEMENTATION", "");

    // This is what allows Zig source code to use `@import("foo")` where 'foo' is not a
    // file path. In this case, we set up `exe_mod` to import `lib_mod`.
    //exe_mod.addImport("mathetes_lib", lib_mod);
    //exe_mod.addImport("stb", stb_lib.root_module);
    const stb = b.addTranslateC(.{
        .root_source_file = stb_dep.path("stb_image.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const stb_mod = stb.createModule();

    // We will also create a module for our other entry point, 'main.zig'.
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "stb", .module = stb_mod },
        },
    });
    exe_mod.addImport("stb", stb_mod);

    exe_mod.linkLibrary(stb_lib);

    const exe = b.addExecutable(.{
        .name = "mathetes",
        .root_module = exe_mod,
    });
    exe.linkLibrary(stb_lib);
    exe.addIncludePath(stb_dep.path(""));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
