const std = @import("std");

const Move = struct {
    count: usize,
    src: usize,
    dest: usize
};

const MoveIt = struct {
    rowIt: std.mem.TokenIterator(u8, .scalar),

    fn init(buf: []const u8) @This() {
        return .{.rowIt = std.mem.tokenizeScalar(u8, buf, '\n')};
    }

    fn next(self: *@This()) !?Move {
        if (self.rowIt.peek() == null) return null;
        const row = self.rowIt.next().?;
        var itr = std.mem.splitScalar(u8, row, ' ');
        _ = itr.next().?;                                             // move
        const count = try std.fmt.parseInt(usize, itr.next().?, 10);  // count
        _ = itr.next().?;                                             // from
        const src = try std.fmt.parseInt(usize, itr.next().?, 10);    // src
        _ = itr.next().?;                                             // to
        const dest = try std.fmt.parseInt(usize, itr.next().?, 10);   // src
        return .{.count=count, .src=src, .dest=dest};
    }
};

fn parseInitialState(buf: []const u8, alloc: std.mem.Allocator) !std.ArrayList(std.ArrayList(u8)) {
    // COULD split backwards here - (1) the first row would be ' 1 2
    // ... LEN', (2) we have to reverse the items in the end.

    var rowIt = std.mem.tokenizeScalar(u8, buf, '\n');
    const row1 = rowIt.peek().?;
    var nStacks = (row1.len + 1) / 4;

    var res = try std.ArrayList(std.ArrayList(u8)).initCapacity(alloc, nStacks);
    for (0..nStacks) |_| {
        try res.append(std.ArrayList(u8).init(alloc));
    }
    while (rowIt.next()) |row| {
        // Every stack is 3 chars wide, with 1 char between
        // stacks. Stack rows are padded with spaces. That gives:
        // row.len = 4*nStacks - 1
        nStacks = (row.len + 1) / 4;
        for (0..nStacks) |i| {
            switch (row[1+i*4]) {
                'A'...'Z' => |ch| try res.items[i].append(ch),
                ' ', '1'...'9' => {},
                else => |ch| {
                    _ = ch;
                    unreachable;
                },
            }
        }
    }
    for (res.items) |stack| {
        std.mem.reverse(u8, stack.items);
    }
    return res;
}

fn execMove1(stacksP: *std.ArrayList(std.ArrayList(u8)), move: Move) void {
    const stacks = stacksP.*.items;
    for (0..move.count) |_| {
        stacks[move.dest-1].append(stacks[move.src-1].pop()) catch unreachable;
    }
}

fn execMove2(stacksP: *std.ArrayList(std.ArrayList(u8)), move: Move) void {
    const stacks = stacksP.*.items;
    const srcIs = stacks[move.src-1].items;
    const toMove = srcIs[srcIs.len-move.count..];
    // There is shrinkRetainingCapacity for this:
    stacks[move.src-1].items = srcIs[0..srcIs.len-move.count];
    stacks[move.dest-1].appendSlice(toMove) catch unreachable;
}

fn solve(moveIt: *MoveIt, stacks: *std.ArrayList(std.ArrayList(u8)), ans: []u8, execMove: anytype) ![]const u8 {
    while (try moveIt.next()) |m| {
        execMove(stacks, m);
    }

    for (stacks.*.items, 0..) |stack, i| {
        ans[i] = stack.items[stack.items.len-1];
    }
    return ans[0..stacks.*.items.len];
}

fn stacksDeinit(stacksP: *std.ArrayList(std.ArrayList(u8))) void {
    for (stacksP.*.items) |stack| {
        stack.deinit();
    }
    stacksP.*.deinit();
}

const input = @embedFile("inputs/input05");

const sample =
    \\    [D]    
    \\[N] [C]    
    \\[Z] [M] [P]
    \\ 1   2   3 
    \\
    \\move 1 from 2 to 1
    \\move 3 from 1 to 3
    \\move 2 from 2 to 1
    \\move 1 from 1 to 2
;

// playing around with consttime flags, Alloc and Parts:
const task = sample;
const Alloc = enum {
    gpa,
    buf
};
const allocType = Alloc.gpa;

const Parts = enum {
    p1,
    p2,
    both
};
const parts = .p1;

pub fn main() !void {
    var alloc = switch (allocType) {
        .buf => blk: {
            var buf: [10000]u8 = undefined;
            break :blk std.heap.FixedBufferAllocator.init(&buf);
        },
        .gpa => std.heap.GeneralPurposeAllocator(.{}){},
    };

    defer {
        if (allocType == .gpa) {
            std.debug.assert(alloc.deinit() == .ok);
        }
    }

    const initStop = std.mem.indexOfPos(u8, task, 0, "\n\n").?;
    var mIt = MoveIt.init(task[initStop+1..]);
    var ansBuf: [100] u8 = undefined;
    if (parts == .p1 or parts == .both) {
        var stacks = try parseInitialState(task[0..initStop], alloc.allocator());
        defer stacksDeinit(&stacks);
        const ans1 = try solve(&mIt, &stacks, &ansBuf, execMove1);
        std.debug.print("Part1: {s}\n", .{ans1});
    }

    if (parts == .p2 or parts == .both) {
        mIt.rowIt.reset();
        // Parse the task again, because the vec[vec] has changed (and
        // it's messy to make a deep copy).
        var stacks2 = try parseInitialState(task[0..initStop], alloc.allocator());
        defer stacksDeinit(&stacks2);
        const ans2 = try solve(&mIt, &stacks2, &ansBuf, execMove2);
        std.debug.print("Part2: {s}\n", .{ans2});
    }
}
