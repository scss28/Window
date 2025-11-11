const std = @import("std");
const Window = @import("Window");

pub fn main() void {
    var window: Window = try .init(.{
        .surface = .{ .opengl = .@"4.5" },
    });

    main_loop: while (true) {
        while (window.nextEvent()) |event| switch (event) {
            .close, .kill => break :main_loop,
            .key_down => |key| {
                if (key == .f11) window.toggleFullscreen();
            },
            else => {},
        };

        window.swapBuffers();
    }
}
