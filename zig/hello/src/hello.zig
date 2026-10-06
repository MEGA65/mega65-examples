//! MEGA65 hello: writes a greeting to screen RAM and sets the border colour.
const std = @import("std");

/// Uppercase A-Z become screen codes 1-26; everything else maps to itself.
fn screenCodes(comptime s: []const u8) [s.len]u8 {
    var out: [s.len]u8 = undefined;
    for (s, 0..) |c, i|
        out[i] = if (std.ascii.isUpper(c)) c - 'A' + 1 else c;
    return out;
}

export fn main() void {
    // 80-column screen RAM at $0800; row 15 sits just below the RUN: prompt.
    const screen: [*]volatile u8 = @ptrFromInt(0x0800);
    const msg = comptime screenCodes("HELLO, ZIG! WELCOME TO MEGA65.");
    for (msg, 0..) |code, i| screen[14 * 80 + i] = code;
    @as(*volatile u8, @ptrFromInt(0xd020)).* = 5; // green border
}
