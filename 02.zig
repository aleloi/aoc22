const std = @import("std");

const sample =
    \\A Y
    \\B X
    \\C Z
;

const input = @embedFile("inputs/input02");

fn solve1(buf: []const u8) u32 {
    var points: u32 = 0;
    var i: usize = 0;
    while (i < buf.len) {
        const their = buf[i] - 'A' + 1;
        const your = buf[i+2] - 'X' + 1;
        switch ((your + 3 - their) % 3) {
            0 => {points += your + 3; }, // tie
            1 => {points += your + 6; }, // win
            2 => {points += your + 0; }, // loss
            else => unreachable,
        }
        i += 4;
    }
    return points;
}

fn solve2(buf: []const u8) u32 {
    var points: u32 = 0;
    var i: usize = 0;
    while (i < buf.len) {
        const their = buf[i] - 'A';
        const outcome = buf[i+2];
        const your = (their + (outcome + 3 - 'Y')) % 3 + 1;
        switch (outcome) {
            'X' => {points += your + 0; }, // loss
            'Y' => {points += your + 3; }, // draw
            'Z' => {points += your + 6; }, // win
            else => unreachable,
        }
        i += 4;
    }
    return points;
}

pub fn main() void {
    std.debug.print("Part1: {}\n", .{solve1(input)});
    std.debug.print("Part2: {}\n", .{solve2(input)});
}
