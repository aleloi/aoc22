const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .optimize=optimize,
        .target=target,
        .name="lib"
    });

    const days = 6;

    inline for (1..days+1) |day| {
        const fname: []const u8 = blk: {
            var buf: [10]u8 = undefined;
            break :blk std.fmt.bufPrint(&buf, "{:0>2}.zig", .{day}) catch unreachable;
        };
        const obj = b.addObject(.{
            .name=fname,
            .root_source_file=b.path(fname),
            .target=target,
            .optimize=optimize
        });
        lib.addObject(obj);
    }

    const day = b.option(u8, "day", "Which day to build?") orelse 1;

    const fname: []const u8 = blk: {
        var buf: [10]u8 = undefined;
        break :blk std.fmt.bufPrint(&buf, "{:0>2}.zig", .{day}) catch unreachable;
    };

    var buf2: [10]u8 = undefined;
    const binName = std.fmt.bufPrint(&buf2, "{:0>2}", .{day}) catch unreachable;


    const exe = b.addExecutable(.{
        .name = binName,
        .root_source_file = b.path(fname),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    const check = b.step("check", "Check if it compiles");
    check.dependOn(&lib.step);
}
