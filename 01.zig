const std = @import("std");
const input = @embedFile("inputs/input01");

fn getCalories(buf: []const u8, arr: *std.ArrayList(u32)) !void {
    var elves_it = std.mem.tokenizeSequence(u8, buf, "\n\n");
    while (elves_it.next()) |elves| {
        var meal_it = std.mem.tokenizeScalar(u8, elves, '\n');
        var sum_cal: u32 = 0;
        while (meal_it.next()) |meal| {
            sum_cal += try std.fmt.parseInt(u32, meal, 10);
        }
        try arr.*.append(sum_cal);

    }
}

// const sample =
//     \\100
//     \\200
//     \\
//     \\300
//     \\400
//     \\
//     \\1
//     \\
//     \\2
// ;



// test "run sample" {
//     var arr = std.ArrayList(u32).init(std.testing.allocator);
//     defer arr.deinit();

//     getCalories(sample, &arr) catch unreachable;

//     std.mem.sort(u32, arr.items, {}, std.sort.asc(u32));

//     for(arr.items) |item| {
//         std.debug.print("{} ", .{item});
//     }
//     std.debug.print("\n ", .{});
// }

pub fn main() void {
    var buf: [10000] u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(&buf);

    var arr = std.ArrayList(u32).init(alloc.allocator());
    defer arr.deinit();

    getCalories(input, &arr) catch unreachable;

    std.mem.sort(u32, arr.items, {}, std.sort.asc(u32));

    std.debug.print("Part 1: {}\n", .{arr.items[arr.items.len-1]});

    var max3: u32 = 0;
    for (arr.items[arr.items.len-3..]) |it| {
        max3 += it;
    }

    std.debug.print("Part 2: {}\n", .{max3});

}

