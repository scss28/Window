const std = @import("std");

const fatal = std.process.fatal;

const gl = @import("gl");
const Window = @import("Window");

pub fn main() !void {
    var window: Window = try .init(.{
        .surface = .{ .opengl = .@"4.5" },
    });

    var gl_proc_table: gl.ProcTable = undefined;
    if (!gl_proc_table.init(window.glLoader())) fatal("failed to initialize gl", .{});
    gl.makeProcTableCurrent(&gl_proc_table);

    main_loop: while (true) {
        while (window.nextEvent()) |event| switch (event) {
            .close, .kill => break :main_loop,
            .resize => |size| {
                gl.Viewport(0, 0, size.width, size.height);
            },
            .key_down => |key| {
                if (key == .f11) window.toggleFullscreen();
            },
            else => {},
        };

        gl.ClearColor(0.39, 0.58, 0.92, 1);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        window.swapBuffers();
    }
}
