const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const posix = std.posix;
const process = std.process;
const unicode = std.unicode;
const log = std.log;

const spoon = @import("spoon");

var term: spoon.Term = undefined;
var loop: bool = true;
var buf: [32]u8 = undefined;
var read: usize = undefined;
var empty = true;

pub fn main() !void {
    try term.init(.{});
    defer term.deinit() catch {};

    try posix.sigaction(posix.SIG.WINCH, &posix.Sigaction{
        .handler = .{ .handler = handleSigWinch },
        .mask = posix.empty_sigset,
        .flags = 0,
    }, null);

    var fds: [1]posix.pollfd = undefined;
    fds[0] = .{
        .fd = term.tty.?,
        .events = posix.POLL.IN,
        .revents = undefined,
    };

    try term.uncook(.{
        .request_kitty_keyboard_protocol = false,
        .request_mouse_tracking = false,
    });

    try term.fetchSize();
    try term.setWindowTitle("weather: Nijmegen", .{});
    try render();

    while (loop) {
        _ = try posix.poll(&fds, -1);

        read = try term.readInput(&buf);
        empty = false;
        try render();
    }
}

fn render() !void {
    var rc = try term.getRenderContext();
    defer rc.done() catch {};

    try rc.clear();

    try rc.moveCursorTo(0, 0);
    try rc.setAttribute(.{ .fg = .green, .reverse = true });
    var rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll(" Weather: Nijmegen");
    try rpw.pad();

    try rc.moveCursorTo(1, 0);
    try rc.setAttribute(.{ .fg = .red, .bold = true });
    rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll(" Input demo / tester, q to exit.");
    try rpw.finish();

    try rc.moveCursorTo(3, 0);
    try rc.setAttribute(.{ .bold = true });
    if (empty) {
        rpw = rc.restrictedPaddingWriter(term.width);
        try rpw.writer().writeAll(" Press a key! Or try to paste something!");
        try rpw.finish();
    } else {
        rpw = rc.restrictedPaddingWriter(term.width);
        var writer = rpw.writer();
        try writer.writeAll(" Bytes read:    ");
        try rc.setAttribute(.{});
        try writer.print("{}", .{read});
        try rpw.finish();

        var valid_unicode = true;
        _ = unicode.Utf8View.init(buf[0..read]) catch {
            valid_unicode = false;
        };
        try rc.moveCursorTo(4, 0);
        try rc.setAttribute(.{ .bold = true });
        rpw = rc.restrictedPaddingWriter(term.width);
        writer = rpw.writer();
        try writer.writeAll(" Valid unicode: ");
        try rc.setAttribute(.{});
        if (valid_unicode) {
            try writer.writeAll("yes: \"");
            for (buf[0..read]) |c| {
                try writer.writeByte(c);
            }
            try writer.writeByte('"');
        } else {
            try writer.writeAll("no");
        }
        try rpw.finish();

        var it = spoon.inputParser(buf[0..read]);
        var i: usize = 1;
        while (it.next()) |in| : (i += 1) {
            rpw = rc.restrictedPaddingWriter(term.width);
            writer = rpw.writer();

            try rc.moveCursorTo(5 + (i - 1), 0);

            const msg = " Input events:  ";
            if (i == 1) {
                try rc.setAttribute(.{ .bold = true });
                try writer.writeAll(msg);
                try rc.setAttribute(.{ .bold = false });
            } else {
                try writer.writeByteNTimes(' ', msg.len);
            }

            var mouse: ?struct { x: usize, y: usize } = null;

            try writer.print("{}: ", .{i});
            switch (in.content) {
                .codepoint => |cp| {
                    if (cp == 'q') {
                        loop = false;
                        return;
                    }
                    try writer.print("codepoint: {} x{X}", .{ cp, cp });
                },
                .function => |f| try writer.print("F{}", .{f}),
                .mouse => |m| {
                    mouse = .{ .x = m.x, .y = m.y };
                    try writer.print("mouse {s} {} {}", .{ @tagName(m.button), m.x, m.y });
                },
                else => try writer.writeAll(@tagName(in.content)),
            }
            if (in.mod_alt) try writer.writeAll(" +Alt");
            if (in.mod_ctrl) try writer.writeAll(" +Ctrl");
            if (in.mod_super) try writer.writeAll(" +Super");

            try rpw.finish();

            if (mouse) |m| {
                try rc.moveCursorTo(m.y, m.x);
                try rc.setAttribute(.{ .bg = .red, .bold = true });
                try rc.buffer.writer().writeByte('X');
            }
        }
    }
}

fn handleSigWinch(_: c_int) callconv(.C) void {
    term.fetchSize() catch {};
    render() catch {};
}
