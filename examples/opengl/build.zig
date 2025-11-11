const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "opengl",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const window = b.dependency("Window", .{ .target = target });
    exe.root_module.addImport("Window", window.module("Window"));

    const zigglgen = @import("zigglgen");
    exe.root_module.addImport("gl", zigglgen.generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.5",
        .profile = .core,
    }));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
