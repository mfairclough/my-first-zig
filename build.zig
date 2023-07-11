const std = @import("std");
const mach = @import("libs/mach/build.zig");
const zmath = @import("libs/zmath/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zmath_pkg = zmath.package(b, target, optimize, .{
        .options = .{ .enable_cross_platform_determinism = true },
    });
    const zmath_dep = std.Build.ModuleDependency{
        .name = "zmath",
        .module = zmath_pkg.zmath,
    };

    const deps = [_]std.Build.ModuleDependency{zmath_dep};

    const app = try mach.App.init(b, .{
        .name = "my-first-zig",
        .src = "src/main.zig",
        .target = target,
        //.deps = &[_]std.build.ModuleDependency{},
        .deps = &deps,
        .optimize = optimize,
    });
    try app.link(.{});
    app.install();

    const run_cmd = app.addRunArtifact();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
