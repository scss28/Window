const std = @import("std");

pub fn build(b: *std.Build) void {
    const use_wayland = b.systemIntegrationOption("wayland", .{});

    const DisplayServer = enum { x11, wayland };
    const display_server: DisplayServer = if (use_wayland)
        .wayland
    else
        .x11;

    const target = b.standardTargetOptions(.{});
    const mod = b.addModule("Window", .{
        .root_source_file = b.path("src/Window.zig"),
        .target = target,
    });

    const config = b.addOptions();
    config.addOption(DisplayServer, "display_server", display_server);

    mod.addOptions("config", config);

    switch (target.result.os.tag) {
        .linux => {
            mod.linkSystemLibrary("xcb", .{});
            mod.linkSystemLibrary("xcb-keysyms", .{});
            mod.linkSystemLibrary("egl", .{});
            mod.link_libc = true;
        },
        else => {},
    }
}
