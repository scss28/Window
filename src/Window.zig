const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");

const assert = std.debug.assert;
const Impl = switch (builtin.os.tag) {
    .windows => @import("Win32Window.zig"),
    .linux => switch (config.display_server) {
        .x11 => @import("XcbWindow.zig"),
        .wayland => @compileError("usupported"),
    },
    else => @compileError("unsupported"),
};

const Window = @This();

impl: Impl,
gl_init: bool,

/// This value should not be changed manually, use `enterFullscreen` and `exitFullscreen`.
fullscreen: bool = false,
/// This value should not be changed manually, use `showCursor` and `hideCursor`.
cursor_visible: bool = true,

pub const glGetProcAddress = Impl.glGetProcAddress;
pub const glLoader = Impl.glLoader;

pub const MouseButton = enum { left, middle, right };
pub const Key = switch (builtin.os.tag) {
    .windows => enum(u16) {
        backspace = 0x08,
        tab = 0x09,
        enter = 0x0D,
        pause = 0x13,
        caps_lock = 0x14,
        escape = 0x1B,
        space = 0x20,
        page_up = 0x21,
        page_down = 0x22,
        end = 0x23,
        home = 0x24,
        left = 0x25,
        up = 0x26,
        right = 0x27,
        down = 0x28,
        print_screen = 0x2C,
        insert = 0x2D,
        delete = 0x2E,

        @"0" = 0x30,
        @"1" = 0x31,
        @"2" = 0x32,
        @"3" = 0x33,
        @"4" = 0x34,
        @"5" = 0x35,
        @"6" = 0x36,
        @"7" = 0x37,
        @"8" = 0x38,
        @"9" = 0x39,

        a = 0x41,
        b = 0x42,
        c = 0x43,
        d = 0x44,
        e = 0x45,
        f = 0x46,
        g = 0x47,
        h = 0x48,
        i = 0x49,
        j = 0x4A,
        k = 0x4B,
        l = 0x4C,
        m = 0x4D,
        n = 0x4E,
        o = 0x4F,
        p = 0x50,
        q = 0x51,
        r = 0x52,
        s = 0x53,
        t = 0x54,
        u = 0x55,
        v = 0x56,
        w = 0x57,
        x = 0x58,
        y = 0x59,
        z = 0x5A,

        left_super = 0x5B,
        right_super = 0x5C,
        menu = 0x5D,

        kp_0 = 0x60,
        kp_1 = 0x61,
        kp_2 = 0x62,
        kp_3 = 0x63,
        kp_4 = 0x64,
        kp_5 = 0x65,
        kp_6 = 0x66,
        kp_7 = 0x67,
        kp_8 = 0x68,
        kp_9 = 0x69,
        kp_multiply = 0x6A,
        kp_add = 0x6B,
        kp_subtract = 0x6D,
        kp_decimal = 0x6E,
        kp_divide = 0x6F,

        f1 = 0x70,
        f2 = 0x71,
        f3 = 0x72,
        f4 = 0x73,
        f5 = 0x74,
        f6 = 0x75,
        f7 = 0x76,
        f8 = 0x77,
        f9 = 0x78,
        f10 = 0x79,
        f11 = 0x7A,
        f12 = 0x7B,
        f13 = 0x7C,
        f14 = 0x7D,
        f15 = 0x7E,
        f16 = 0x7F,
        f17 = 0x80,
        f18 = 0x81,
        f19 = 0x82,
        f20 = 0x83,
        f21 = 0x84,
        f22 = 0x85,
        f23 = 0x86,
        f24 = 0x87,

        num_lock = 0x90,
        scroll_lock = 0x91,

        semicolon = 0xBA,
        equals = 0xBB,
        comma = 0xBC,
        minus = 0xBD,
        period = 0xBE,
        slash = 0xBF,
        grave_accent = 0xC0,
        left_bracket = 0xDB,
        backslash = 0xDC,
        right_bracket = 0xDD,
        apostrophe = 0xDE,

        left_shift = 0xA0,
        right_shift = 0xA1,
        left_control = 0xA2,
        right_control = 0xA3,
        left_alt = 0xA4,
        right_alt = 0xA5,
    },
    .linux => switch (config.display_server) {
        .x11 => enum(u16) {
            escape = 0xFF1B,
            @"1" = 0x0031,
            @"2" = 0x0032,
            @"3" = 0x0033,
            @"4" = 0x0034,
            @"5" = 0x0035,
            @"6" = 0x0036,
            @"7" = 0x0037,
            @"8" = 0x0038,
            @"9" = 0x0039,
            @"0" = 0x0030,
            minus = 0x002D,
            equals = 0x003D,
            backspace = 0xFF08,
            tab = 0xFF09,
            q = 0x0071,
            w = 0x0077,
            e = 0x0065,
            r = 0x0072,
            t = 0x0074,
            y = 0x0079,
            u = 0x0075,
            i = 0x0069,
            o = 0x006F,
            p = 0x0070,
            left_bracket = 0x005B,
            right_bracket = 0x005D,
            enter = 0xFF0D,
            left_control = 0xFFE3,
            a = 0x0061,
            s = 0x0073,
            d = 0x0064,
            f = 0x0066,
            g = 0x0067,
            h = 0x0068,
            j = 0x006A,
            k = 0x006B,
            l = 0x006C,
            semicolon = 0x003B,
            apostrophe = 0x0027,
            grave_accent = 0x0060,
            left_shift = 0xFFE1,
            backslash = 0x005C,
            z = 0x007A,
            x = 0x0078,
            c = 0x0063,
            v = 0x0076,
            b = 0x0062,
            n = 0x006E,
            m = 0x006D,
            comma = 0x002C,
            period = 0x002E,
            slash = 0x002F,
            right_shift = 0xFFE2,
            kp_multiply = 0xFFAA,
            left_alt = 0xFFE9,
            space = 0x0020,
            caps_lock = 0xFFE5,
            f1 = 0xFFBE,
            f2 = 0xFFBF,
            f3 = 0xFFC0,
            f4 = 0xFFC1,
            f5 = 0xFFC2,
            f6 = 0xFFC3,
            f7 = 0xFFC4,
            f8 = 0xFFC5,
            f9 = 0xFFC6,
            f10 = 0xFFC7,
            num_lock = 0xFF7F,
            scroll_lock = 0xFF14,
            kp_7 = 0xFFB7,
            kp_8 = 0xFFB8,
            kp_9 = 0xFFB9,
            kp_subtract = 0xFFAD,
            kp_4 = 0xFFB4,
            kp_5 = 0xFFB5,
            kp_6 = 0xFFB6,
            kp_add = 0xFFAB,
            kp_1 = 0xFFB1,
            kp_2 = 0xFFB2,
            kp_3 = 0xFFB3,
            kp_0 = 0xFFB0,
            kp_decimal = 0xFFAE,
            f11 = 0xFFC8,
            f12 = 0xFFC9,
            kp_divide = 0xFFAF,
            right_control = 0xFFE4,
            print_screen = 0xFF61,
            right_alt = 0xFFEA,
            home = 0xFF50,
            up = 0xFF52,
            page_up = 0xFF55,
            left = 0xFF51,
            right = 0xFF53,
            end = 0xFF57,
            down = 0xFF54,
            page_down = 0xFF56,
            insert = 0xFF63,
            delete = 0xFFFF,
            kp_enter = 0xFF8D,
            kp_equal = 0xFFBD,
            pause = 0xFF13,
            left_super = 0xFFEB,
            right_super = 0xFFEC,
            menu = 0xFF67,
        },
        .wayland => @compileError("unsupported"),
    },
    else => @compileError("unsupported"),
};

pub const Event = union(enum) {
    resize: struct { width: u16, height: u16 },
    close,
    kill,

    mouse_move: struct { x: u16, y: u16 },
    mouse_scroll: i16,
    mouse_down: MouseButton,
    mouse_up: MouseButton,

    key_down: Key,
    key_up: Key,
};

pub const InitOptions = struct {
    name: [:0]const u8 = "Window",
    width: u16 = 640,
    height: u16 = 360,

    opengl: ?struct {
        major: u8,
        minor: u8,

        pub const @"4.5": @This() = .{
            .major = 4,
            .minor = 5,
        };

        pub const @"4.1": @This() = .{
            .major = 4,
            .minor = 5,
        };

        pub const @"3.2": @This() = .{
            .major = 3,
            .minor = 2,
        };
    } = null,
};

pub inline fn init(options: InitOptions) !Window {
    const impl: Impl = try .init(options);
    return .{
        .impl = impl,
        .gl_init = options.opengl != null,
    };
}

pub inline fn nextEvent(w: *const Window) ?Event {
    return w.impl.nextEvent();
}

pub fn enterFullscreen(w: *Window) void {
    if (w.fullscreen) return;

    w.impl.enterFullscreen();
    w.fullscreen = true;
}

pub fn exitFullscreen(w: *Window) void {
    if (!w.fullscreen) return;

    w.impl.exitFullscreen();
    w.fullscreen = false;
}

pub fn toggleFullscreen(w: *Window) void {
    if (w.fullscreen) w.exitFullscreen() else w.enterFullscreen();
}

pub fn showCursor(w: *Window) void {
    if (w.cursor_visible) return;

    w.impl.showCursor();
    w.cursor_visible = true;
}

pub fn hideCursor(w: *Window) void {
    if (!w.cursor_visible) return;

    w.impl.hideCursor();
    w.cursor_visible = false;
}

pub fn toggleCursor(w: *Window) void {
    if (w.cursor_visible) w.hideCursor() else w.showCursor();
}

/// Asserts the window was initialized with OpenGL.
pub fn glSwapBuffers(w: *const Window) void {
    assert(w.gl_init);
    w.impl.glSwapBuffers();
}
