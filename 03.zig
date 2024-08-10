const std = @import("std");

const sample =
    \\vJrwpWtwJgWrhcsFMMfFFhFp
    \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    \\PmmdzqPrVvPwwTWBwg
    \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    \\ttgJtRGJQctTZtZT
    \\CrZsJsPPZsGzwwsLwLmpwMDw
;

const input = @embedFile("inputs/input03");

const Bs = std.bit_set.IntegerBitSet(256);

fn ch2prio(ch: u8) u32 {
    return switch (ch) {
        'a'...'z' => ch-'a'+1,
        'A'...'Z' => ch-'A'+27,
        else => unreachable,
    };
}

fn part1Bs(buf: []const u8) u32 {
    var it = std.mem.splitScalar(u8, buf, '\n');
    var prio: u32 = 0;
    while (it.next()) |row| {
        var sets = [_]Bs{Bs.initEmpty(), Bs.initEmpty()};

        for (row[0..row.len/2]) |ch| {
            sets[0].set(ch);
        }
        for (row[row.len/2..]) |ch| {
            sets[1].set(ch);
        }
        var isec = sets[0].intersectWith(sets[1]).iterator(.{});
        while (isec.next()) |ch| {
            prio += ch2prio(@intCast(ch));
        }
    }

    return prio;
}


fn part2(buf: []const u8) u32 {
    var it = std.mem.splitScalar(u8, buf, '\n');

    var prio: u32 = 0;
    while (it.rest().len > 0) {
        const team: [3][]const u8 = .{it.next().?, it.next().?, it.next().?};
        var sets = [_]Bs{Bs.initEmpty(), Bs.initEmpty(), Bs.initEmpty()};

        for (team, 0..) |ruck, i| {
            for (ruck) |ch| {
                sets[i].set(ch);
            }
        }

        var isec = (sets[0]
                        .intersectWith(sets[1])
                        .intersectWith(sets[2])
                        .iterator(.{}));

        while (isec.next()) |ch| {
            prio += ch2prio(@intCast(ch));
        }
    }

    return prio;
}

pub fn main() void {
    std.debug.print("Part 1: {}\n", .{part1Bs(input)});
    std.debug.print("Part 2: {}\n", .{part2(input)});
}
