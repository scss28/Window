const std = @import("std");
const c = std.c;
const enums = std.enums;
const mem = std.mem;

const assert = std.debug.assert;

const egl = @cImport({
    @cInclude("EGL/egl.h");
    @cInclude("EGL/eglext.h");
});

const sys = @import("system.zig");
const linalg = @import("linalg.zig");
const input = @import("input.zig");

const xcb = @import("xcb.zig");

const XcbWindow = @This();

size: linalg.Vec2,

connection: *xcb.connection_t,
window: xcb.window_t,
atom_wm_protocols: xcb.atom_t,
atom_wm_delete_window: xcb.atom_t,

display: egl.EGLDisplay,
surface: egl.EGLSurface,

pub fn init(name: [:0]const u8, width: u16, height: u16) mem.Allocator.Error!XcbWindow {
    var scr: c_int = undefined;
    const connection = xcb.connect(null, &scr).?;
    if (xcb.connection_has_error(connection) != 0) {
        @panic("failed to connect to xserver");
    }

    const setup = xcb.get_setup(connection);
    var iter = xcb.setup_roots_iterator(setup);
    while (scr > 0) : (scr -= 1) {
        xcb.screen_next(&iter);
    }
    const screen = iter.data;

    const window = xcb.generate_id(connection);
    const value_mask = xcb.CW.BACK_PIXEL | xcb.CW.EVENT_MASK;
    const value_list = [_]u32{
        screen.black_pixel,
        xcb.EVENT_MASK.KEY_RELEASE |
            xcb.EVENT_MASK.KEY_PRESS |
            xcb.EVENT_MASK.EXPOSURE |
            xcb.EVENT_MASK.STRUCTURE_NOTIFY |
            xcb.EVENT_MASK.POINTER_MOTION |
            xcb.EVENT_MASK.BUTTON_PRESS |
            xcb.EVENT_MASK.BUTTON_RELEASE |
            xcb.EVENT_MASK.BUTTON_MOTION,
    };

    _ = xcb.create_window(
        connection,
        xcb.COPY_FROM_PARENT,
        window,
        screen.root,
        0,
        0,
        width,
        height,
        0,
        @intFromEnum(xcb.window_class_t.INPUT_OUTPUT),
        screen.root_visual,
        value_mask,
        &value_list,
    );

    // Send notification when window is destroyed.
    const atom_wm_protocols = try getAtom(connection, "WM_PROTOCOLS");
    const atom_wm_delete_window = try getAtom(connection, "WM_DELETE_WINDOW");
    _ = xcb.change_property(
        connection,
        .REPLACE,
        window,
        atom_wm_protocols,
        .ATOM,
        32,
        1,
        &atom_wm_delete_window,
    );

    _ = xcb.change_property(
        connection,
        .REPLACE,
        window,
        .WM_NAME,
        .STRING,
        8,
        @intCast(name.len),
        @ptrCast(name),
    );

    // Set the WM_CLASS property to display title in dash tooltip and
    // application menu on GNOME and other desktop environments
    var wm_class_buf: [100]u8 = undefined;
    const wm_class = std.fmt.bufPrint(
        &wm_class_buf,
        "windowName\x00{s}\x00",
        .{name},
    ) catch unreachable;

    _ = xcb.change_property(
        connection,
        .REPLACE,
        window,
        .WM_CLASS,
        .STRING,
        8,
        @intCast(wm_class.len),
        wm_class.ptr,
    );
    _ = xcb.map_window(connection, window);
    _ = xcb.flush(connection);

    const eglGetPlatformDisplayEXT: *const fn (
        platform: egl.EGLenum,
        native_display: ?*anyopaque,
        attrib_list: [*c]const egl.EGLAttrib,
    ) callconv(.c) egl.EGLDisplay = @ptrCast(egl.eglGetProcAddress("eglGetPlatformDisplayEXT").?);

    const egl_display = eglGetPlatformDisplayEXT(egl.EGL_PLATFORM_XCB_EXT, connection, null);
    if (egl_display == egl.EGL_NO_DISPLAY) @panic("failed to get an egl display");
    assert(egl.eglInitialize(egl_display, null, null) != 0);

    const egl_attribs: []const egl.EGLint = &.{
        egl.EGL_SURFACE_TYPE,
        egl.EGL_WINDOW_BIT,
        egl.EGL_RENDERABLE_TYPE,
        egl.EGL_OPENGL_BIT,
        egl.EGL_NONE,
    };

    var egl_config: egl.EGLConfig = undefined;
    var egl_num_config: egl.EGLint = undefined;
    _ = egl.eglChooseConfig(egl_display, egl_attribs.ptr, &egl_config, 1, &egl_num_config);

    const egl_surface = egl.eglCreateWindowSurface(
        egl_display,
        egl_config,
        window,
        null,
    );
    assert(egl_surface != egl.EGL_NO_SURFACE);
    assert(egl.eglBindAPI(egl.EGL_OPENGL_API) != 0);

    const egl_ctx_attribs: []const egl.EGLint = &.{
        egl.EGL_CONTEXT_MAJOR_VERSION,       4,
        egl.EGL_CONTEXT_MINOR_VERSION,       5,
        egl.EGL_CONTEXT_OPENGL_PROFILE_MASK, egl.EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT,
        egl.EGL_NONE,
    };

    const egl_context = egl.eglCreateContext(
        egl_display,
        egl_config,
        egl.EGL_NO_CONTEXT,
        egl_ctx_attribs.ptr,
    );
    assert(egl_context != egl.EGL_NO_CONTEXT);

    _ = egl.eglMakeCurrent(egl_display, egl_surface, egl_surface, egl_context);

    return .{
        .size = .init(@floatFromInt(width), @floatFromInt(height)),
        .connection = connection,
        .window = window,
        .atom_wm_protocols = atom_wm_protocols,
        .atom_wm_delete_window = atom_wm_delete_window,
        .display = egl_display,
        .surface = egl_surface,
    };
}

pub fn processMessages(w: *const XcbWindow) mem.Allocator.Error!bool {
    var should_exit = false;

    var opt_event = xcb.poll_for_event(w.connection);
    while (opt_event) |event| : (opt_event = xcb.poll_for_event(w.connection)) {
        defer c.free(event);

        switch (event.response_type.op) {
            .CLIENT_MESSAGE => blk: {
                const client_message: *xcb.client_message_event_t = @ptrCast(event);
                if (client_message.window != w.window) break :blk;

                if (client_message.type == w.atom_wm_protocols) {
                    const msg_atom: xcb.atom_t = @enumFromInt(client_message.data.data32[0]);
                    if (msg_atom == w.atom_wm_delete_window) {
                        should_exit = true;
                    }
                } else if (client_message.type == .NOTICE) {
                    // We repaint every frame regardless.
                }
            },
            .CONFIGURE_NOTIFY => {
                const configure: *xcb.configure_notify_event_t = @ptrCast(event);
                sys.window.size = .init(
                    @floatFromInt(configure.width),
                    @floatFromInt(configure.height),
                );
                sys.screen.ratio = sys.window.size.div(sys.screen.size);
            },
            .EXPOSE => {
                // We draw everything every frame, so this message is pointless.
            },
            .KEY_PRESS => {
                const key_press: *xcb.key_press_event_t = @ptrCast(event);
                const key = enums.fromInt(input.Key, key_press.detail) orelse continue;

                sys.keys.pressed_set.setPresent(key, true);
                try sys.events.appendEvent(.{ .key_down = key });
            },
            .KEY_RELEASE => {
                const key_press: *xcb.key_press_event_t = @ptrCast(event);
                const key = enums.fromInt(input.Key, key_press.detail) orelse continue;

                sys.keys.pressed_set.setPresent(key, false);
                try sys.events.appendEvent(.{ .key_up = key });
            },
            .MOTION_NOTIFY => {
                const motion_notify: *xcb.motion_notify_event_t = @ptrCast(event);
                const position: linalg.Vec2 = .init(
                    @floatFromInt(motion_notify.event_x),
                    @floatFromInt(motion_notify.event_y),
                );

                sys.mouse.screen = position.div(sys.screen.ratio);
            },
            .BUTTON_PRESS => {
                const button_press: *xcb.button_press_event_t = @ptrCast(event);
                switch (button_press.detail) {
                    1 => sys.mouse.pressed_set.setPresent(.left, true),
                    2 => sys.mouse.pressed_set.setPresent(.middle, true),
                    3 => sys.mouse.pressed_set.setPresent(.right, true),
                    else => {},
                }
            },
            .BUTTON_RELEASE => {
                const button_release: *xcb.button_release_event_t = @ptrCast(event);
                switch (button_release.detail) {
                    1 => sys.mouse.pressed_set.setPresent(.left, false),
                    2 => sys.mouse.pressed_set.setPresent(.middle, false),
                    3 => sys.mouse.pressed_set.setPresent(.right, false),
                    else => {},
                }
            },
            else => {},
        }
    }

    return !should_exit;
}

pub fn swapBuffers(w: *const XcbWindow) void {
    _ = egl.eglSwapBuffers(w.display, w.surface);
}

pub fn glLoader(_: *const XcbWindow) @TypeOf(egl.eglGetProcAddress) {
    return egl.eglGetProcAddress;
}

fn getAtom(conn: *xcb.connection_t, name: [:0]const u8) error{OutOfMemory}!xcb.atom_t {
    const cookie = xcb.intern_atom(conn, 0, @intCast(name.len), name.ptr);
    if (xcb.intern_atom_reply(conn, cookie, null)) |r| {
        defer std.c.free(r);
        return r.atom;
    }
    return error.OutOfMemory;
}
