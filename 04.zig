const std = @import("std");

const Intr = struct {
    fro: u16,
    to: u16,
    pub fn inside(self: @This(), other: @This()) bool {
        return self.fro <= other.fro and other.to <= self.to;
    }
    pub fn overlap(self: @This(), other: @This()) bool {
        return @max(self.fro, other.fro) <= @min(self.to, other.to);
    }
};

const IntrIter = struct {
    rit: std.mem.TokenIterator(u8, .scalar),

    pub fn init(buf: []const u8 ) IntrIter {
        return .{.rit = std.mem.tokenizeScalar(u8, buf, '\n')};
    }

    pub fn next(self: *@This()) ?struct {fst: Intr, snd: Intr} {
        const rowq = self.rit.next();
        if (rowq == null) return null;
        const row = rowq.?;

        const parse = struct {
            pub fn inner(buff: []const u8) Intr {
                const minus = std.mem.indexOfScalar(u8, buff, '-').?;
                const frS = buff[0..minus];
                const toS = buff[minus+1..];
                return .{.fro = std.fmt.parseInt(u16, frS, 10) catch unreachable,
                         .to = std.fmt.parseInt(u16, toS, 10) catch unreachable};
            }
        }.inner;

        const comma = std.mem.indexOfScalar(u8, row, ',').?;
        return .{.fst = parse(row[0..comma]), .snd=parse(row[comma+1..])};
    }
};

fn partBoth(ii: *IntrIter, op: fn(self: Intr, other: Intr) bool) u32 {
    var cnt: u32 = 0;
    while (ii.*.next()) |pair| {
        if (op(pair.fst, pair.snd) or op(pair.snd, pair.fst)) {
            cnt += 1;
        }
    }
    return cnt;
}

pub fn main() void {
    var intrIt = IntrIter.init(@embedFile("inputs/input04"));
    std.debug.print("Part1: {}\n", .{partBoth(&intrIt, Intr.inside)});
    intrIt.rit.reset();
    std.debug.print("Part1: {}\n", .{partBoth(&intrIt, Intr.overlap)});
}
