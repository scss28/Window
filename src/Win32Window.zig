const std = @import("std");
const enums = std.enums;
const mem = std.mem;

const Window = @import("Window.zig");
pub const InitOptions = Window.InitOptions;
pub const MouseButton = Window.MouseButton;
pub const Key = Window.Key;
pub const Event = Window.Event;

const assert = std.debug.assert;

const win32 = @import("win32.zig");

const Win32Window = @This();

hwnd: win32.HWND,
hdc: win32.HDC,

// Used for saving window state when entering fullscreen.
old_style: win32.WINDOW_STYLE = undefined,
old_placement: win32.WINDOWPLACEMENT = undefined,

pub fn init(options: InitOptions) !Win32Window {
    const h_instance = win32.GetModuleHandleA(null);
    const class_name = "ExtraWindow";

    var wc = mem.zeroes(win32.WNDCLASSA);
    wc.lpfnWndProc = &windowProc;
    wc.hInstance = h_instance;

    wc.lpszClassName = class_name;

    _ = win32.RegisterClassA(&wc);
    const hwnd = win32.CreateWindowExA(
        .{},
        class_name,
        options.name,
        win32.WS_OVERLAPPEDWINDOW,

        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        options.width,
        options.height,

        null,
        null,
        h_instance,
        null,
    ) orelse @panic("failed to create a window");

    const hdc = win32.GetDC(hwnd) orelse unreachable;
    const pfd = mem.zeroInit(win32.PIXELFORMATDESCRIPTOR, .{
        .nSize = @sizeOf(win32.PIXELFORMATDESCRIPTOR),
        .nVersion = 1,
        .dwFlags = .{
            .DRAW_TO_WINDOW = 1,
            .DOUBLEBUFFER = 1,
            .SUPPORT_OPENGL = 1,
        },
        .iPixelType = .RGBA,
        .cColorBits = 32,
        .cDepthBits = 24,
        .cStencilBits = 8,
        .iLayerType = .MAIN_PLANE,
    });

    const pixel_format = win32.ChoosePixelFormat(hdc, &pfd);
    _ = win32.SetPixelFormat(hdc, pixel_format, &pfd);

    if (options.opengl) |opengl| {
        const dummy_rc = win32.wglCreateContext(hdc) orelse
            @panic("failed to create wgl context");
        _ = win32.wglMakeCurrent(hdc, dummy_rc);

        const wglCreateContextAttribsARB: *const fn (
            ?win32.HDC,
            ?win32.HGLRC,
            [*:0]const c_int,
        ) callconv(.winapi) ?win32.HGLRC =
            @ptrCast(win32.wglGetProcAddress("wglCreateContextAttribsARB") orelse {
                @panic("failed to load ARB OpenGL extensions");
            });

        const new_rc = wglCreateContextAttribsARB(hdc, null, &.{
            0x2091, @intCast(opengl.major), // WGL_CONTEXT_MAJOR_VERSION_ARB
            0x2092, @intCast(opengl.minor), // WGL_CONTEXT_MINOR_VERSION_ARB
            0x9126, 0x00000001, // WGL_CONTEXT_PROFILE_MASK_ARB = CORE
            0x2094, 0x00000001, // WGL_CONTEXT_FLAGS_ARB = FORWARD_COMPATIBLE_BIT_ARB
            0,
        }) orelse @panic("failed to create wgl context");

        _ = win32.wglMakeCurrent(hdc, new_rc);
        _ = win32.wglDeleteContext(dummy_rc);
    }

    _ = win32.ShowWindow(hwnd, win32.SW_SHOW);

    return .{
        .hwnd = hwnd,
        .hdc = hdc,
        .active_wsi = .gl,
    };
}

pub fn enterFullscreen(w: *Win32Window) void {
    w.old_style = @bitCast(win32.GetWindowLongA(w.hwnd, win32.GWL_STYLE));
    _ = win32.GetWindowPlacement(w.hwnd, &w.old_placement);

    const monitor = win32.MonitorFromWindow(w.hwnd, .NEAREST);

    var monitor_info: win32.MONITORINFO = undefined;
    monitor_info.cbSize = @sizeOf(win32.MONITORINFO);

    assert(win32.GetMonitorInfoA(monitor, &monitor_info) != 0);

    _ = win32.SetWindowLongA(
        w.hwnd,
        win32.GWL_STYLE,
        @as(i32, @bitCast(w.old_style)) & ~@as(i32, @bitCast(win32.WS_OVERLAPPEDWINDOW)),
    );

    _ = win32.SetWindowPos(
        w.hwnd,
        win32.HWND_TOPMOST,
        monitor_info.rcMonitor.left,
        monitor_info.rcMonitor.top,
        monitor_info.rcMonitor.right - monitor_info.rcMonitor.left,
        monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
        @bitCast(@as(u32, @bitCast(win32.SWP_NOOWNERZORDER)) |
            @as(u32, @bitCast(win32.SWP_FRAMECHANGED))),
    );
}

pub fn exitFullscreen(w: *Win32Window) void {
    _ = win32.SetWindowLongA(
        w.hwnd,
        win32.GWL_STYLE,
        @as(i32, @bitCast(w.old_style)) | @as(i32, @bitCast(win32.WS_OVERLAPPEDWINDOW)),
    );

    _ = win32.SetWindowPlacement(w.hwnd, &w.old_placement);
    _ = win32.SetWindowPos(
        w.hwnd,
        null,
        0,
        0,
        0,
        0,
        @bitCast(@as(u32, @bitCast(win32.SWP_NOMOVE)) |
            @as(u32, @bitCast(win32.SWP_NOSIZE)) |
            @as(u32, @bitCast(win32.SWP_NOZORDER)) |
            @as(u32, @bitCast(win32.SWP_NOOWNERZORDER)) |
            @as(u32, @bitCast(win32.SWP_FRAMECHANGED))),
    );
}

pub inline fn showCursor(_: *Win32Window) void {
    _ = win32.ShowCursor(1);
}

pub inline fn hideCursor(_: *Win32Window) void {
    _ = win32.ShowCursor(0);
}

pub fn toggleCursor(w: *Win32Window) void {
    if (w.cursor_visible) w.hideCursor() else w.showCursor();
}

var current_event: ?Event = null;
pub fn nextEvent(_: *const Win32Window) ?Event {
    var msg: win32.MSG = undefined;
    if (win32.PeekMessageA(&msg, null, 0, 0, .remove) == 0) return null;

    _ = win32.TranslateMessage(&msg);
    _ = win32.DispatchMessageA(&msg);

    while (current_event == null) {
        if (win32.PeekMessageA(&msg, null, 0, 0, .remove) == 0) return null;

        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageA(&msg);
    }

    return current_event;
}

pub fn glSwapBuffers(w: *const Win32Window) void {
    _ = win32.SwapBuffers(w.hdc);
}

pub fn glGetProcAddress(name: ?[*:0]const u8) ?*const fn () callconv(.c) void {
    return win32.wglGetProcAddress(name) orelse win32.GetProcAddress(
        win32.GetModuleHandleA("opengl32.dll"),
        name,
    );
}

pub inline fn glLoader() struct {
    opengl_instance: ?win32.HINSTANCE,

    pub fn getProcAddress(l: @This(), name: [*:0]const u8) ?*const fn () callconv(.c) void {
        return win32.wglGetProcAddress(name) orelse win32.GetProcAddress(
            l.opengl_instance,
            name,
        );
    }
} {
    return .{ .opengl_instance = win32.GetModuleHandleA("opengl32.dll") };
}

fn windowProc(
    hwnd: win32.HWND,
    msg: u32,
    wparam: win32.WPARAM,
    lparam: win32.LPARAM,
) callconv(.winapi) win32.LRESULT {
    current_event = switch (msg) {
        win32.WM_DESTROY => .kill,
        win32.WM_CLOSE => .close,
        win32.WM_SIZE => .{
            .resize = .{
                .width = @truncate(@as(usize, @bitCast(lparam))),
                .height = @truncate(@as(usize, @bitCast(lparam)) >> 16),
            },
        },
        win32.WM_MOUSEMOVE => .{
            .mouse_move = .{
                .x = @truncate(@as(usize, @bitCast(lparam))),
                .y = @truncate(@as(usize, @bitCast(lparam)) >> 16),
            },
        },
        inline win32.WM_LBUTTONDOWN,
        win32.WM_MBUTTONDOWN,
        win32.WM_RBUTTONDOWN,
        => |event| .{
            .mouse_down = switch (event) {
                win32.WM_LBUTTONDOWN => .left,
                win32.WM_MBUTTONDOWN => .middle,
                win32.WM_RBUTTONDOWN => .right,
                else => unreachable,
            },
        },
        inline win32.WM_LBUTTONUP,
        win32.WM_MBUTTONUP,
        win32.WM_RBUTTONUP,
        => |event| .{
            .mouse_up = switch (event) {
                win32.WM_LBUTTONUP => .left,
                win32.WM_MBUTTONUP => .middle,
                win32.WM_RBUTTONUP => .right,
                else => unreachable,
            },
        },
        win32.WM_MOUSEWHEEL => .{
            .mouse_scroll = @truncate(@as(isize, @bitCast(wparam)) >> 16),
        },
        win32.WM_KEYDOWN => blk: {
            const key = enums.fromInt(Key, wparam) orelse break :blk null;
            break :blk .{ .key_down = key };
        },
        win32.WM_KEYUP => blk: {
            const key = enums.fromInt(Key, wparam) orelse break :blk null;
            break :blk .{ .key_up = key };
        },
        else => null,
    };

    return if (current_event != null) 0 else win32.DefWindowProcA(hwnd, msg, wparam, lparam);
}
