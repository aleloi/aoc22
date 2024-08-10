const std = @import("std");

const input = @embedFile("inputs/input06");

fn allDifferent(buf: []const u8) bool {
    var s = std.bit_set.IntegerBitSet(256).initEmpty();
    for (buf) |ch| {
        s.set(ch);
    }
    return s.count() == buf.len;
}

fn findMarker(unique: usize) usize {
    var it = std.mem.window(u8, input, unique, 1);
    var i = unique;  // num read chars
    while (it.next()) |win| :(i += 1) {
        if (allDifferent(win)) break;
    }
    return i;
}


pub fn main() void {
    std.debug.print(
        \\Part1: {}
        \\Part2: {}
        \\
            , .{findMarker(4), findMarker(14)}
    );
}
