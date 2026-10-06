//! MEGA65 hello build. Zig compiles the startup assembly, the linker-script
//! glue and a few libc sources itself for `-target mos-mega65`, so no separate
//! llvm-mos toolchain install is needed.
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

    const common = b.fmt("{s}/mos-platform/common", .{sdk_root});
    const crt0_dir = b.fmt("{s}/crt0", .{common});
    const com_inc = b.fmt("{s}/include", .{common});
    const com_asm = b.fmt("{s}/asminc", .{common});
    const plat_dir = b.fmt("{s}/mos-platform/mega65", .{sdk_root});
    const comm_dir = b.fmt("{s}/mos-platform/commodore", .{sdk_root});

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hello.zig"),
            .target = target,
            .optimize = optimize,
            .sanitize_c = .off,
            // MOS has no stack-guard lowering, so the SSP pass fails on any
            // function with a sized local buffer.
            .stack_protector = false,
        }),
    });
    exe.bundle_compiler_rt = false;
    exe.lto = .full;

    exe.root_module.addIncludePath(.{ .cwd_relative = com_inc });
    exe.root_module.addIncludePath(.{ .cwd_relative = com_asm });

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

    exe.forceUndefinedSymbol("main");
    exe.setLinkerScript(wrapperLd(b, sdk_root));

    b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{ .dest_sub_path = "hello.prg" }).step);
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
