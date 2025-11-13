// adapted: https://codeberg.org/andrewrk/daw/src/branch/main/src/XcbWindow.zig

const std = @import("std");
const c = std.c;
const enums = std.enums;
const mem = std.mem;

const Window = @import("Window.zig");
const InitOptions = Window.InitOptions;
const MouseButton = Window.MouseButton;
const Key = Window.Key;
const Event = Window.Event;

const assert = std.debug.assert;

const xcb = @import("xcb.zig");
const egl = @cImport({
    @cInclude("EGL/egl.h");
    @cInclude("EGL/eglext.h");
});

const XcbWindow = @This();

connection: *xcb.connection_t,
root: xcb.window_t,
window: xcb.window_t,

key_symbols: *xcb.key_symbols_t,
hidden_cursor: xcb.cursor_t,

atom_wm_protocols: xcb.atom_t,
atom_wm_delete_window: xcb.atom_t,
atom_net_wm_state: xcb.atom_t,
atom_net_wm_state_fullscreen: xcb.atom_t,

egl_display: egl.EGLDisplay,
egl_surface: egl.EGLSurface,

pub fn init(options: InitOptions) mem.Allocator.Error!XcbWindow {
    var scr: c_int = undefined;
    const connection = xcb.connect(null, &scr).?;
    if (xcb.connection_has_error(connection) != 0) {
        @panic("failed to connect to xserver");
    }

    var iter = xcb.setup_roots_iterator(xcb.get_setup(connection));
    const root = iter.data.root;

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
        options.width,
        options.height,
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
        @intCast(options.name.len),
        @ptrCast(options.name),
    );

    const atom_net_wm_state = try getAtom(connection, "_NET_WM_STATE");
    const atom_net_wm_state_fullscreen = try getAtom(connection, "_NET_WM_STATE_FULLSCREEN");

    const key_symbols = xcb.key_symbols_alloc(connection) orelse return error.OutOfMemory;

    const hidden_cursor_pixmap = xcb.generate_id(connection);
    _ = xcb.create_pixmap(connection, 1, hidden_cursor_pixmap, window, 1, 1);

    const gc = xcb.generate_id(connection);
    _ = xcb.create_gc(connection, gc, window, 0, null);

    _ = xcb.put_image(
        connection,
        xcb.IMAGE_FORMAT_XY_BITMAP,
        hidden_cursor_pixmap,
        gc,
        1,
        1,
        0,
        0,
        0,
        1,
        1,
        &.{0},
    );

    const hidden_cursor = xcb.generate_id(connection);
    _ = xcb.create_cursor(
        connection,
        hidden_cursor,
        hidden_cursor_pixmap,
        hidden_cursor_pixmap,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    );

    // Set the WM_CLASS property to display title in dash tooltip and
    // application menu on GNOME and other desktop environments
    var wm_class_buf: [100]u8 = undefined;
    const wm_class = std.fmt.bufPrint(
        &wm_class_buf,
        "windowName\x00{s}\x00",
        .{options.name},
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

    var egl_display: egl.EGLDisplay = undefined;
    var egl_surface: egl.EGLSurface = undefined;
    if (options.opengl) |opengl| {
        const eglGetPlatformDisplayEXT: *const fn (
            platform: egl.EGLenum,
            native_display: ?*anyopaque,
            attrib_list: [*c]const egl.EGLAttrib,
        ) callconv(.c) egl.EGLDisplay =
            @ptrCast(egl.eglGetProcAddress("eglGetPlatformDisplayEXT").?);

        egl_display = eglGetPlatformDisplayEXT(
            egl.EGL_PLATFORM_XCB_EXT,
            connection,
            null,
        );
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

        egl_surface = egl.eglCreateWindowSurface(
            egl_display,
            egl_config,
            window,
            null,
        );
        assert(egl_surface != egl.EGL_NO_SURFACE);
        assert(egl.eglBindAPI(egl.EGL_OPENGL_API) != 0);

        const egl_ctx_attribs: []const egl.EGLint = &.{
            egl.EGL_CONTEXT_MAJOR_VERSION,       opengl.major,
            egl.EGL_CONTEXT_MINOR_VERSION,       opengl.minor,
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
    }

    return .{
        .connection = connection,
        .window = window,
        .root = root,

        .key_symbols = key_symbols,
        .hidden_cursor = hidden_cursor,

        .atom_wm_protocols = atom_wm_protocols,
        .atom_wm_delete_window = atom_wm_delete_window,
        .atom_net_wm_state = atom_net_wm_state,
        .atom_net_wm_state_fullscreen = atom_net_wm_state_fullscreen,

        .egl_display = egl_display,
        .egl_surface = egl_surface,
    };
}

pub fn nextEvent(w: *const XcbWindow) ?Event {
    while (xcb.poll_for_event(w.connection)) |event| switch (event.response_type.op) {
        .CLIENT_MESSAGE => blk: {
            const client_message: *xcb.client_message_event_t = @ptrCast(event);
            if (client_message.window != w.window) break :blk;
            if (client_message.type == w.atom_wm_protocols) {
                const msg_atom: xcb.atom_t = @enumFromInt(client_message.data.data32[0]);
                if (msg_atom == w.atom_wm_delete_window) {
                    return .close;
                }
            }
        },
        .CONFIGURE_NOTIFY => {
            const configure: *xcb.configure_notify_event_t = @ptrCast(event);
            return .{
                .resize = .{
                    .width = configure.width,
                    .height = configure.height,
                },
            };
        },
        .KEY_PRESS => {
            const press: *xcb.key_press_event_t = @ptrCast(event);

            const key_sym = xcb.key_symbols_get_keysym(w.key_symbols, press.detail, 0);
            const key = enums.fromInt(Key, key_sym) orelse continue;

            return .{ .key_down = key };
        },
        .KEY_RELEASE => {
            const release: *xcb.key_press_event_t = @ptrCast(event);

            const key_sym = xcb.key_symbols_get_keysym(w.key_symbols, release.detail, 0);
            const key = enums.fromInt(Key, key_sym) orelse continue;

            return .{ .key_up = key };
        },
        .MOTION_NOTIFY => {
            const motion_notify: *xcb.motion_notify_event_t = @ptrCast(event);
            return .{
                .mouse_move = .{
                    .x = @intCast(motion_notify.event_x),
                    .y = @intCast(motion_notify.event_y),
                },
            };
        },
        .BUTTON_PRESS => {
            const press: *xcb.button_press_event_t = @ptrCast(event);
            const button: MouseButton = switch (press.detail) {
                1 => .left,
                2 => .middle,
                3 => .right,
                else => continue,
            };

            return .{ .mouse_down = button };
        },
        .BUTTON_RELEASE => {
            const release: *xcb.button_release_event_t = @ptrCast(event);
            const button: MouseButton = switch (release.detail) {
                1 => .left,
                2 => .middle,
                3 => .right,
                else => continue,
            };

            return .{ .mouse_up = button };
        },
        else => {},
    };

    return null;
}

fn setFullscreen(w: *const XcbWindow, comptime fullscreen: bool) void {
    const event = mem.zeroInit(xcb.client_message_event_t, .{
        .response_type = .{
            .op = .CLIENT_MESSAGE,
            .mystery = 0,
        },
        .window = w.window,
        .type = w.atom_net_wm_state,
        .format = 32,
        .data = xcb.client_message_data_t{
            .data32 = .{
                @intFromBool(fullscreen),
                @intFromEnum(w.atom_net_wm_state_fullscreen),
                0,
                0,
                0,
            },
        },
    });

    _ = xcb.send_event(
        w.connection,
        0,
        w.root,
        xcb.EVENT_MASK.SUBSTRUCTURE_REDIRECT | xcb.EVENT_MASK.SUBSTRUCTURE_NOTIFY,
        @ptrCast(&event),
    );
    _ = xcb.flush(w.connection);
}

pub inline fn enterFullscreen(w: *const XcbWindow) void {
    w.setFullscreen(true);
}

pub inline fn exitFullscreen(w: *const XcbWindow) void {
    w.setFullscreen(false);
}

pub fn showCursor(w: *const XcbWindow) void {
    xcb.change_window_attributes(w.connection, w.window, xcb.CW.CURSOR, &.{0});
}

pub fn hideCursor(w: *const XcbWindow) void {
    xcb.change_window_attributes(w.connection, w.window, xcb.CW.CURSOR, &.{w.hidden_cursor});
}

pub fn glSwapBuffers(w: *const XcbWindow) void {
    _ = egl.eglSwapBuffers(w.egl_display, w.egl_surface);
}

pub const glGetProcAddress = egl.eglGetProcAddress;

pub inline fn glLoader() struct {
    pub fn getProcAddress(_: @This(), name: [*:0]const u8) ?*const fn () callconv(.c) void {
        return egl.eglGetProcAddress(name);
    }
} {
    return .{};
}

fn getAtom(conn: *xcb.connection_t, name: [:0]const u8) error{OutOfMemory}!xcb.atom_t {
    const cookie = xcb.intern_atom(conn, 0, @intCast(name.len), name.ptr);
    const r = xcb.intern_atom_reply(conn, cookie, null) orelse return error.OutOfMemory;
    defer std.c.free(r);

    return r.atom;
}
