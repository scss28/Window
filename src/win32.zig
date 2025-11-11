pub const HWND = *opaque {};
pub const HMENU = *opaque {};
pub const HINSTANCE = *opaque {};

pub const CW_USEDEFAULT = @as(i32, -2147483648);

pub const WINDOW_EX_STYLE = packed struct(u32) {
    DLGMODALFRAME: u1 = 0,
    _1: u1 = 0,
    NOPARENTNOTIFY: u1 = 0,
    TOPMOST: u1 = 0,
    ACCEPTFILES: u1 = 0,
    TRANSPARENT: u1 = 0,
    MDICHILD: u1 = 0,
    TOOLWINDOW: u1 = 0,
    WINDOWEDGE: u1 = 0,
    CLIENTEDGE: u1 = 0,
    CONTEXTHELP: u1 = 0,
    _11: u1 = 0,
    RIGHT: u1 = 0,
    RTLREADING: u1 = 0,
    LEFTSCROLLBAR: u1 = 0,
    _15: u1 = 0,
    CONTROLPARENT: u1 = 0,
    STATICEDGE: u1 = 0,
    APPWINDOW: u1 = 0,
    LAYERED: u1 = 0,
    NOINHERITLAYOUT: u1 = 0,
    NOREDIRECTIONBITMAP: u1 = 0,
    LAYOUTRTL: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    COMPOSITED: u1 = 0,
    _26: u1 = 0,
    NOACTIVATE: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const WINDOW_STYLE = packed struct(u32) {
    ACTIVECAPTION: u1 = 0,
    _1: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    TABSTOP: u1 = 0,
    GROUP: u1 = 0,
    THICKFRAME: u1 = 0,
    SYSMENU: u1 = 0,
    HSCROLL: u1 = 0,
    VSCROLL: u1 = 0,
    DLGFRAME: u1 = 0,
    BORDER: u1 = 0,
    MAXIMIZE: u1 = 0,
    CLIPCHILDREN: u1 = 0,
    CLIPSIBLINGS: u1 = 0,
    DISABLED: u1 = 0,
    VISIBLE: u1 = 0,
    MINIMIZE: u1 = 0,
    CHILD: u1 = 0,
    POPUP: u1 = 0,
    // MINIMIZEBOX (bit index 17) conflicts with GROUP
    // MAXIMIZEBOX (bit index 16) conflicts with TABSTOP
    // ICONIC (bit index 29) conflicts with MINIMIZE
    // SIZEBOX (bit index 18) conflicts with THICKFRAME
    // CHILDWINDOW (bit index 30) conflicts with CHILD
};

pub const WS_OVERLAPPEDWINDOW = WINDOW_STYLE{
    .TABSTOP = 1,
    .GROUP = 1,
    .THICKFRAME = 1,
    .SYSMENU = 1,
    .DLGFRAME = 1,
    .BORDER = 1,
};

pub const WNDCLASS_STYLES = packed struct(u32) {
    VREDRAW: u1 = 0,
    HREDRAW: u1 = 0,
    _2: u1 = 0,
    DBLCLKS: u1 = 0,
    _4: u1 = 0,
    OWNDC: u1 = 0,
    CLASSDC: u1 = 0,
    PARENTDC: u1 = 0,
    _8: u1 = 0,
    NOCLOSE: u1 = 0,
    _10: u1 = 0,
    SAVEBITS: u1 = 0,
    BYTEALIGNCLIENT: u1 = 0,
    BYTEALIGNWINDOW: u1 = 0,
    GLOBALCLASS: u1 = 0,
    _15: u1 = 0,
    IME: u1 = 0,
    DROPSHADOW: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const SHOW_WINDOW_CMD = packed struct(u32) {
    SHOWNORMAL: u1 = 0,
    SHOWMINIMIZED: u1 = 0,
    SHOWNOACTIVATE: u1 = 0,
    SHOWNA: u1 = 0,
    SMOOTHSCROLL: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
    // NORMAL (bit index 0) conflicts with SHOWNORMAL
    // PARENTCLOSING (bit index 0) conflicts with SHOWNORMAL
    // OTHERZOOM (bit index 1) conflicts with SHOWMINIMIZED
    // OTHERUNZOOM (bit index 2) conflicts with SHOWNOACTIVATE
    // SCROLLCHILDREN (bit index 0) conflicts with SHOWNORMAL
    // INVALIDATE (bit index 1) conflicts with SHOWMINIMIZED
    // ERASE (bit index 2) conflicts with SHOWNOACTIVATE
};

pub const SW_SHOW = SHOW_WINDOW_CMD{
    .SHOWNORMAL = 1,
    .SHOWNOACTIVATE = 1,
};

pub const HICON = *opaque {};
pub const HCURSOR = HICON;

pub const WPARAM = usize;
pub const LPARAM = isize;
pub const LRESULT = isize;
pub const HBRUSH = *opaque {};

pub const BOOL = i32;
pub const WM_NULL = @as(u32, 0);
pub const WM_CREATE = @as(u32, 1);
pub const WM_DESTROY = @as(u32, 2);
pub const WM_MOVE = @as(u32, 3);
pub const WM_SIZE = @as(u32, 5);
pub const WM_ACTIVATE = @as(u32, 6);
pub const WA_INACTIVE = @as(u32, 0);
pub const WA_ACTIVE = @as(u32, 1);
pub const WA_CLICKACTIVE = @as(u32, 2);
pub const WM_SETFOCUS = @as(u32, 7);
pub const WM_KILLFOCUS = @as(u32, 8);
pub const WM_ENABLE = @as(u32, 10);
pub const WM_SETREDRAW = @as(u32, 11);
pub const WM_SETTEXT = @as(u32, 12);
pub const WM_GETTEXT = @as(u32, 13);
pub const WM_GETTEXTLENGTH = @as(u32, 14);
pub const WM_PAINT = @as(u32, 15);
pub const WM_CLOSE = @as(u32, 16);
pub const WM_QUERYENDSESSION = @as(u32, 17);
pub const WM_QUERYOPEN = @as(u32, 19);
pub const WM_ENDSESSION = @as(u32, 22);
pub const WM_QUIT = @as(u32, 18);
pub const WM_ERASEBKGND = @as(u32, 20);
pub const WM_SYSCOLORCHANGE = @as(u32, 21);
pub const WM_SHOWWINDOW = @as(u32, 24);
pub const WM_WININICHANGE = @as(u32, 26);
pub const WM_SETTINGCHANGE = @as(u32, 26);
pub const WM_DEVMODECHANGE = @as(u32, 27);
pub const WM_ACTIVATEAPP = @as(u32, 28);
pub const WM_FONTCHANGE = @as(u32, 29);
pub const WM_TIMECHANGE = @as(u32, 30);
pub const WM_CANCELMODE = @as(u32, 31);
pub const WM_SETCURSOR = @as(u32, 32);
pub const WM_MOUSEACTIVATE = @as(u32, 33);
pub const WM_CHILDACTIVATE = @as(u32, 34);
pub const WM_QUEUESYNC = @as(u32, 35);
pub const WM_GETMINMAXINFO = @as(u32, 36);
pub const WM_PAINTICON = @as(u32, 38);
pub const WM_ICONERASEBKGND = @as(u32, 39);
pub const WM_NEXTDLGCTL = @as(u32, 40);
pub const WM_SPOOLERSTATUS = @as(u32, 42);
pub const WM_DRAWITEM = @as(u32, 43);
pub const WM_MEASUREITEM = @as(u32, 44);
pub const WM_DELETEITEM = @as(u32, 45);
pub const WM_VKEYTOITEM = @as(u32, 46);
pub const WM_CHARTOITEM = @as(u32, 47);
pub const WM_SETFONT = @as(u32, 48);
pub const WM_GETFONT = @as(u32, 49);
pub const WM_SETHOTKEY = @as(u32, 50);
pub const WM_GETHOTKEY = @as(u32, 51);
pub const WM_QUERYDRAGICON = @as(u32, 55);
pub const WM_COMPAREITEM = @as(u32, 57);
pub const WM_GETOBJECT = @as(u32, 61);
pub const WM_COMPACTING = @as(u32, 65);
pub const WM_COMMNOTIFY = @as(u32, 68);
pub const WM_WINDOWPOSCHANGING = @as(u32, 70);
pub const WM_WINDOWPOSCHANGED = @as(u32, 71);
pub const WM_POWER = @as(u32, 72);

pub const WM_MOUSEMOVE: u32 = 0x0200;
pub const WM_MOUSEWHEEL: u32 = 0x020A;

pub const WM_LBUTTONDOWN: u32 = 0x0201;
pub const WM_LBUTTONUP: u32 = 0x0202;

pub const WM_MBUTTONDOWN: u32 = 0x0207;
pub const WM_MBUTTONUP: u32 = 0x0208;

pub const WM_RBUTTONDOWN: u32 = 0x0204;
pub const WM_RBUTTONUP: u32 = 0x0205;

pub const WM_KEYDOWN: u32 = 0x0100;
pub const WM_KEYUP: u32 = 0x0101;

pub const HDC = *opaque {};
pub const HGLRC = *opaque {};

pub const PROC = *align(@alignOf(fn () callconv(.winapi) void)) const anyopaque;
pub const FARPROC = *const fn () callconv(.winapi) isize;

pub const POINT = extern struct {
    x: i32,
    y: i32,
};

pub const MSG = extern struct {
    hwnd: ?HWND,
    message: u32,
    wParam: WPARAM,
    lParam: LPARAM,
    time: u32,
    pt: POINT,
};

pub const WNDPROC = *const fn (
    param0: HWND,
    param1: u32,
    param2: WPARAM,
    param3: LPARAM,
) callconv(.winapi) LRESULT;

pub const WNDCLASSA = extern struct {
    style: WNDCLASS_STYLES,
    lpfnWndProc: ?WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: ?HINSTANCE,
    hIcon: ?HICON,
    hCursor: ?HCURSOR,
    hbrBackground: ?HBRUSH,
    lpszMenuName: ?[*:0]const u8,
    lpszClassName: ?[*:0]const u8,
};

pub const PEEK_MESSAGE_REMOVE_TYPE = packed struct(u32) {
    REMOVE: u1 = 0,
    NOYIELD: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    QS_PAINT: u1 = 0,
    QS_SENDMESSAGE: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,

    pub const remove: PEEK_MESSAGE_REMOVE_TYPE = .{ .REMOVE = 1 };
};

pub const PFD_FLAGS = packed struct(u32) {
    DOUBLEBUFFER: u1 = 0,
    STEREO: u1 = 0,
    DRAW_TO_WINDOW: u1 = 0,
    DRAW_TO_BITMAP: u1 = 0,
    SUPPORT_GDI: u1 = 0,
    SUPPORT_OPENGL: u1 = 0,
    GENERIC_FORMAT: u1 = 0,
    NEED_PALETTE: u1 = 0,
    NEED_SYSTEM_PALETTE: u1 = 0,
    SWAP_EXCHANGE: u1 = 0,
    SWAP_COPY: u1 = 0,
    SWAP_LAYER_BUFFERS: u1 = 0,
    GENERIC_ACCELERATED: u1 = 0,
    SUPPORT_DIRECTDRAW: u1 = 0,
    DIRECT3D_ACCELERATED: u1 = 0,
    SUPPORT_COMPOSITION: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    DEPTH_DONTCARE: u1 = 0,
    DOUBLEBUFFER_DONTCARE: u1 = 0,
    STEREO_DONTCARE: u1 = 0,
};

pub const PFD_PIXEL_TYPE = enum(i8) {
    RGBA = 0,
    COLORINDEX = 1,
};

pub const PFD_LAYER_TYPE = enum(i8) {
    UNDERLAY_PLANE = -1,
    MAIN_PLANE = 0,
    OVERLAY_PLANE = 1,
};

pub const PIXELFORMATDESCRIPTOR = extern struct {
    nSize: u16,
    nVersion: u16,
    dwFlags: PFD_FLAGS,
    iPixelType: PFD_PIXEL_TYPE,
    cColorBits: u8,
    cRedBits: u8,
    cRedShift: u8,
    cGreenBits: u8,
    cGreenShift: u8,
    cBlueBits: u8,
    cBlueShift: u8,
    cAlphaBits: u8,
    cAlphaShift: u8,
    cAccumBits: u8,
    cAccumRedBits: u8,
    cAccumGreenBits: u8,
    cAccumBlueBits: u8,
    cAccumAlphaBits: u8,
    cDepthBits: u8,
    cStencilBits: u8,
    cAuxBuffers: u8,
    iLayerType: PFD_LAYER_TYPE,
    bReserved: u8,
    dwLayerMask: u32,
    dwVisibleMask: u32,
    dwDamageMask: u32,
};

pub const WINDOW_LONG_PTR_INDEX = enum(i32) {
    _EXSTYLE = -20,
    P_HINSTANCE = -6,
    P_HWNDPARENT = -8,
    P_ID = -12,
    _STYLE = -16,
    P_USERDATA = -21,
    P_WNDPROC = -4,
    _,

    pub const _HINSTANCE = .P_HINSTANCE;
    pub const _ID = .P_ID;
    pub const _USERDATA = .P_USERDATA;
    pub const _WNDPROC = .P_WNDPROC;
    pub const _HWNDPARENT = .P_HWNDPARENT;
    pub fn tagName(self: WINDOW_LONG_PTR_INDEX) ?[:0]const u8 {
        return switch (self) {
            ._EXSTYLE => "_EXSTYLE",
            .P_HINSTANCE => "P_HINSTANCE",
            .P_HWNDPARENT => "P_HWNDPARENT",
            .P_ID => "P_ID",
            ._STYLE => "_STYLE",
            .P_USERDATA => "P_USERDATA",
            .P_WNDPROC => "P_WNDPROC",
            else => null,
        };
    }
    pub const format = if (@import("builtin").zig_version.order(.{ .major = 0, .minor = 15, .patch = 0 }) == .lt)
        formatLegacy
    else
        formatNew;
    fn formatLegacy(
        self: WINDOW_LONG_PTR_INDEX,
        comptime fmt: []const u8,
        options: @import("std").fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{s}({})", .{ self.value.tagName() orelse "?", @intFromEnum(self.value) });
    }
    fn formatNew(self: WINDOW_LONG_PTR_INDEX, writer: *@import("std").Io.Writer) @import("std").Io.Writer.Error!void {
        try writer.print("{s}({})", .{ self.value.tagName() orelse "?", @intFromEnum(self.value) });
    }
};

pub const GWL_EXSTYLE = WINDOW_LONG_PTR_INDEX._EXSTYLE;
pub const GWLP_HINSTANCE = WINDOW_LONG_PTR_INDEX.P_HINSTANCE;
pub const GWLP_HWNDPARENT = WINDOW_LONG_PTR_INDEX.P_HWNDPARENT;
pub const GWLP_ID = WINDOW_LONG_PTR_INDEX.P_ID;
pub const GWL_STYLE = WINDOW_LONG_PTR_INDEX._STYLE;
pub const GWLP_USERDATA = WINDOW_LONG_PTR_INDEX.P_USERDATA;
pub const GWLP_WNDPROC = WINDOW_LONG_PTR_INDEX.P_WNDPROC;
pub const GWL_HINSTANCE = WINDOW_LONG_PTR_INDEX.P_HINSTANCE;
pub const GWL_ID = WINDOW_LONG_PTR_INDEX.P_ID;
pub const GWL_USERDATA = WINDOW_LONG_PTR_INDEX.P_USERDATA;
pub const GWL_WNDPROC = WINDOW_LONG_PTR_INDEX.P_WNDPROC;
pub const GWL_HWNDPARENT = WINDOW_LONG_PTR_INDEX.P_HWNDPARENT;

pub const HWND_BOTTOM: HWND = @ptrFromInt(1);
pub const HWND_TOPMOST: HWND = @ptrFromInt(@as(usize, @bitCast(@as(isize, -1))));
pub const HWND_NOTOPMOST: HWND = @ptrFromInt(@as(usize, @bitCast(@as(isize, -2))));

pub const SET_WINDOW_POS_FLAGS = packed struct(u32) {
    NOSIZE: u1 = 0,
    NOMOVE: u1 = 0,
    NOZORDER: u1 = 0,
    NOREDRAW: u1 = 0,
    NOACTIVATE: u1 = 0,
    DRAWFRAME: u1 = 0,
    SHOWWINDOW: u1 = 0,
    HIDEWINDOW: u1 = 0,
    NOCOPYBITS: u1 = 0,
    NOOWNERZORDER: u1 = 0,
    NOSENDCHANGING: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    DEFERERASE: u1 = 0,
    ASYNCWINDOWPOS: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
    // FRAMECHANGED (bit index 5) conflicts with DRAWFRAME
    // NOREPOSITION (bit index 9) conflicts with NOOWNERZORDER
};
pub const SWP_ASYNCWINDOWPOS = SET_WINDOW_POS_FLAGS{ .ASYNCWINDOWPOS = 1 };
pub const SWP_DEFERERASE = SET_WINDOW_POS_FLAGS{ .DEFERERASE = 1 };
pub const SWP_DRAWFRAME = SET_WINDOW_POS_FLAGS{ .DRAWFRAME = 1 };
pub const SWP_FRAMECHANGED = SET_WINDOW_POS_FLAGS{ .DRAWFRAME = 1 };
pub const SWP_HIDEWINDOW = SET_WINDOW_POS_FLAGS{ .HIDEWINDOW = 1 };
pub const SWP_NOACTIVATE = SET_WINDOW_POS_FLAGS{ .NOACTIVATE = 1 };
pub const SWP_NOCOPYBITS = SET_WINDOW_POS_FLAGS{ .NOCOPYBITS = 1 };
pub const SWP_NOMOVE = SET_WINDOW_POS_FLAGS{ .NOMOVE = 1 };
pub const SWP_NOOWNERZORDER = SET_WINDOW_POS_FLAGS{ .NOOWNERZORDER = 1 };
pub const SWP_NOREDRAW = SET_WINDOW_POS_FLAGS{ .NOREDRAW = 1 };
pub const SWP_NOREPOSITION = SET_WINDOW_POS_FLAGS{ .NOOWNERZORDER = 1 };
pub const SWP_NOSENDCHANGING = SET_WINDOW_POS_FLAGS{ .NOSENDCHANGING = 1 };
pub const SWP_NOSIZE = SET_WINDOW_POS_FLAGS{ .NOSIZE = 1 };
pub const SWP_NOZORDER = SET_WINDOW_POS_FLAGS{ .NOZORDER = 1 };
pub const SWP_SHOWWINDOW = SET_WINDOW_POS_FLAGS{ .SHOWWINDOW = 1 };

pub const WINDOWPLACEMENT_FLAGS = packed struct(u32) {
    SETMINPOSITION: u1 = 0,
    RESTORETOMAXIMIZED: u1 = 0,
    ASYNCWINDOWPLACEMENT: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const RECT = extern struct {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,
};

pub const WINDOWPLACEMENT = extern struct {
    length: u32,
    flags: WINDOWPLACEMENT_FLAGS,
    showCmd: SHOW_WINDOW_CMD,
    ptMinPosition: POINT,
    ptMaxPosition: POINT,
    rcNormalPosition: RECT,
};

pub extern "user32" fn RegisterClassA(
    lpWndClass: ?*const WNDCLASSA,
) callconv(.winapi) u16;

pub extern "user32" fn CreateWindowExA(
    dwExStyle: WINDOW_EX_STYLE,
    lpClassName: ?[*:0]align(1) const u8,
    lpWindowName: ?[*:0]const u8,
    dwStyle: WINDOW_STYLE,
    X: i32,
    Y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?HWND,
    hMenu: ?HMENU,
    hInstance: ?HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(.winapi) ?HWND;

pub extern "kernel32" fn GetModuleHandleA(
    lpModuleName: ?[*:0]const u8,
) callconv(.winapi) ?HINSTANCE;

pub extern "user32" fn DefWindowProcA(
    hWnd: ?HWND,
    Msg: u32,
    wParam: WPARAM,
    lParam: LPARAM,
) callconv(.winapi) LRESULT;

pub extern "user32" fn GetMessageA(
    lpMsg: ?*MSG,
    hWnd: ?HWND,
    wMsgFilterMin: u32,
    wMsgFilterMax: u32,
) callconv(.winapi) BOOL;

pub extern "user32" fn PeekMessageA(
    lpMsg: ?*MSG,
    hWnd: ?HWND,
    wMsgFilterMin: u32,
    wMsgFilterMax: u32,
    wRemoveMsg: PEEK_MESSAGE_REMOVE_TYPE,
) callconv(.winapi) BOOL;

pub extern "user32" fn TranslateMessage(
    lpMsg: ?*const MSG,
) callconv(.winapi) BOOL;

pub extern "user32" fn DispatchMessageA(
    lpMsg: ?*const MSG,
) callconv(.winapi) LRESULT;

pub extern "user32" fn ShowWindow(
    hWnd: ?HWND,
    nCmdShow: SHOW_WINDOW_CMD,
) callconv(.winapi) BOOL;

pub extern "user32" fn GetWindowLongA(
    hWnd: ?HWND,
    nIndex: WINDOW_LONG_PTR_INDEX,
) callconv(.winapi) i32;

pub extern "user32" fn SetWindowLongA(
    hWnd: ?HWND,
    nIndex: WINDOW_LONG_PTR_INDEX,
    dwNewLong: i32,
) callconv(.winapi) i32;

pub extern "user32" fn SetWindowPos(
    hWnd: ?HWND,
    hWndInsertAfter: ?HWND,
    X: i32,
    Y: i32,
    cx: i32,
    cy: i32,
    uFlags: SET_WINDOW_POS_FLAGS,
) callconv(.winapi) BOOL;

pub extern "user32" fn GetWindowPlacement(
    hWnd: ?HWND,
    lpwndpl: ?*WINDOWPLACEMENT,
) callconv(.winapi) BOOL;

pub extern "user32" fn SetWindowPlacement(
    hWnd: ?HWND,
    lpwndpl: ?*const WINDOWPLACEMENT,
) callconv(.winapi) BOOL;

pub extern "user32" fn PostQuitMessage(
    nExitCode: i32,
) callconv(.winapi) void;

pub extern "user32" fn GetDC(
    hWnd: ?HWND,
) callconv(.winapi) ?HDC;

pub extern "gdi32" fn ChoosePixelFormat(
    hdc: ?HDC,
    ppfd: ?*const PIXELFORMATDESCRIPTOR,
) callconv(.winapi) i32;

pub extern "gdi32" fn SetPixelFormat(
    hdc: ?HDC,
    format: i32,
    ppfd: ?*const PIXELFORMATDESCRIPTOR,
) callconv(.winapi) BOOL;

pub extern "opengl32" fn wglCreateContext(
    hdc: ?HDC,
) callconv(.winapi) ?HGLRC;

pub extern "opengl32" fn wglMakeCurrent(
    hdc: ?HDC,
    rc: ?HGLRC,
) callconv(.winapi) BOOL;

pub extern "opengl32" fn wglGetProcAddress(
    name: ?[*:0]const u8,
) callconv(.winapi) ?PROC;

pub extern "opengl32" fn wglDeleteContext(rc: ?HGLRC) callconv(.winapi) BOOL;
pub extern "kernel32" fn GetProcAddress(
    hModule: ?HINSTANCE,
    lpProcName: ?[*:0]const u8,
) callconv(.winapi) ?FARPROC;

pub extern "gdi32" fn SwapBuffers(param0: ?HDC) callconv(.winapi) BOOL;
pub extern "user32" fn ShowCursor(bShow: BOOL) c_int;

pub const HMONITOR = *opaque {};

pub const MONITORINFO = extern struct {
    cbSize: u32,
    rcMonitor: RECT,
    rcWork: RECT,
    dwFlags: u32,
};

pub const MONITOR_FROM_FLAGS = enum(u32) {
    NEAREST = 2,
    NULL = 0,
    PRIMARY = 1,
};

pub extern "user32" fn GetMonitorInfoA(
    hMonitor: ?HMONITOR,
    lpmi: ?*MONITORINFO,
) callconv(.winapi) BOOL;

pub extern "user32" fn MonitorFromWindow(
    hwnd: ?HWND,
    dwFlags: MONITOR_FROM_FLAGS,
) callconv(.winapi) ?HMONITOR;
