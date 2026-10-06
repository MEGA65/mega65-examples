//! MEGA65 plasma build. Same zig-only startup as zig/hello, plus the
//! mega65-libc C headers translated into a Zig module for `plasma.zig`.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .mos,
            .os_tag = .mega65,
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const sdk = b.dependency("llvm-mos-sdk", .{});
    const sdk_root = sdk.builder.root.root_dir.path orelse ".";
    const libc = b.dependency("mega65-libc", .{});

    const common = b.fmt("{s}/mos-platform/common", .{sdk_root});
    const crt0_dir = b.fmt("{s}/crt0", .{common});
    const com_inc = b.fmt("{s}/include", .{common});
    const com_asm = b.fmt("{s}/asminc", .{common});
    const plat_dir = b.fmt("{s}/mos-platform/mega65", .{sdk_root});
    const comm_dir = b.fmt("{s}/mos-platform/commodore", .{sdk_root});

    const exe = b.addExecutable(.{
        .name = "plasma",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/plasma.zig"),
            .target = target,
            .optimize = optimize,
            .sanitize_c = .off,
            // LLVM-MOS has no stack-guard lowering, so the SSP pass fails on any
            // function with a sized local buffer.
            .stack_protector = false,
            .imports = &.{.{
                .name = "mega65",
                .module = mega65Headers(b, sdk, libc, target, optimize),
            }},
        }),
    });
    exe.bundle_compiler_rt = false;
    exe.lto = .full;

    exe.root_module.addIncludePath(.{ .cwd_relative = com_inc });
    exe.root_module.addIncludePath(.{ .cwd_relative = com_asm });
    exe.root_module.addIncludePath(libc.path("include"));
    exe.root_module.addIncludePath(libc.path("include/mega65"));

    // crt0.S and save-basic.S only contribute section contents and export no
    // symbol, so an archive member would be dropped. Link them directly.
    exe.root_module.addObject(sectionOnlyObj(b, target, optimize, "crt0", crt0_dir, com_asm, com_inc, &.{"crt0.S"}));
    exe.root_module.addObject(sectionOnlyObj(b, target, optimize, "save-basic", comm_dir, com_asm, com_inc, &.{"save-basic.S"}));

    exe.root_module.addCSourceFiles(.{
        .root = .{ .cwd_relative = crt0_dir },
        .files = &.{ "init-stack.S", "copy-zp-data.c" },
    });
    exe.root_module.addCSourceFiles(.{
        .root = .{ .cwd_relative = b.fmt("{s}/exit", .{crt0_dir}) },
        .files = &.{ "exit-custom.S", "exit-loop.c", "exit.c" },
    });
    exe.root_module.addCSourceFiles(.{
        .root = .{ .cwd_relative = plat_dir },
        .files = &.{ "basic-header.S", "unmap-basic.S" },
    });
    exe.root_module.addCSourceFiles(.{ .root = .{ .cwd_relative = b.fmt("{s}/c", .{common}) }, .files = &.{"mem.c"} });
    // mega65-libc implementations behind the translated headers.
    exe.root_module.addCSourceFiles(.{ .root = libc.path("src"), .files = &.{ "conio.c", "random.c" } });
    exe.root_module.addCSourceFiles(.{ .root = .{ .cwd_relative = comm_dir }, .files = &.{"abort.c"} });

    exe.forceUndefinedSymbol("main");
    exe.setLinkerScript(wrapperLd(b, sdk_root));

    b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{ .dest_sub_path = "plasma.prg" }).step);
}

fn mega65Headers(b: *std.Build, sdk: *std.Build.Dependency, libc: *std.Build.Dependency, target: std.Build.ResolvedTarget, opt: std.builtin.OptimizeMode) *std.Build.Module {
    const tc = b.addTranslateC(.{
        .root_source_file = b.addWriteFiles().add("mega65-api.h",
            \\#include <conio.h>
            \\#include <random.h>
        ),
        .target = target,
        .optimize = opt,
        .link_libc = false,
    });
    tc.addIncludePath(libc.path("include"));
    tc.addIncludePath(libc.path("include/mega65"));
    tc.addIncludePath(sdk.path("mos-platform/common/include"));
    tc.addIncludePath(sdk.path("mos-platform/commodore"));
    return tc.createModule();
}

fn sectionOnlyObj(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, name: []const u8, root: []const u8, com_asm: []const u8, com_inc: []const u8, files: []const []const u8) *std.Build.Step.Compile {
    const obj = b.addObject(.{
        .name = name,
        .root_module = b.createModule(.{ .target = target, .optimize = optimize }),
    });
    obj.root_module.addIncludePath(.{ .cwd_relative = com_asm });
    obj.root_module.addIncludePath(.{ .cwd_relative = com_inc });
    obj.root_module.addCSourceFiles(.{ .root = .{ .cwd_relative = root }, .files = files });
    obj.lto = .none;
    return obj;
}

/// mega65/link.ld merged with commodore/commodore.ld, with the INPUT()
/// directives replaced by the objects linked above.
fn wrapperLd(b: *std.Build, sdk_root: []const u8) std.Build.LazyPath {
    return b.addWriteFiles().add("mega65-wrapper.ld", b.fmt(
        \\SEARCH_DIR("{0s}/mos-platform/mega65");
        \\SEARCH_DIR("{0s}/mos-platform/commodore");
        \\SEARCH_DIR("{0s}/mos-platform/common/ldscripts");
        \\__basic_zp_start = 0x0002;
        \\__basic_zp_end = 0x0090;
        \\MEMORY {{ ram (rw) : ORIGIN = 0x2001, LENGTH = 0xafff }}
        \\__rc0 = __basic_zp_start;
        \\INCLUDE "imag-regs.ld"
        \\__basic_zp_size = __basic_zp_end - __basic_zp_start;
        \\MEMORY {{ zp : ORIGIN = __rc31 + 1, LENGTH = __basic_zp_end - (__rc31 + 1) }}
        \\REGION_ALIAS("c_readonly", ram)
        \\REGION_ALIAS("c_writeable", ram)
        \\SECTIONS {{ .basic_header : {{ *(.basic_header) }} INCLUDE "c.ld" }}
        \\__stack = 0xd000;
        \\OUTPUT_FORMAT {{ SHORT(0x2001) TRIM(ram) }}
    , .{sdk_root}));
}
