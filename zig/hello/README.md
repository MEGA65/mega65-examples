# Hello world in Zig (`zig build`)

This is a minimal Zig program for the MEGA65: a greeting written straight into
screen RAM at `$0800`, and the border set to green. There is no runtime and no
libc, so `main` is a handful of stores. The ASCII to screen-code conversion
happens at comptime.

Zig compiles the startup assembly, the linker-script glue and a few libc
sources itself for `-target mos-mega65`. They come in as the `llvm-mos-sdk`
package, so no separate llvm-mos toolchain installation is needed.

## Building and Running

1. Install [zig-mos](https://github.com/kassane/zig-mos-bootstrap/releases),
   the `mos` fork of Zig.
2. Build:
   ~~~ bash
   cd zig/hello
   zig build                              # writes zig-out/bin/hello.prg
   zig build -Doptimize=ReleaseSmall      # 229 bytes instead of 821
   ~~~

Run in Xemu and dump the screen:

~~~ bash
timeout 30 xemu-xmega65 -headless -testing -besure \
    -sdimg ~/.local/share/xemu-lgb/mega65/mega65.img \
    -prg zig-out/bin/hello.prg -screenshot hello.png -dumpscreen hello.txt
~~~

The greeting appears on the line below the `RUN:` prompt.

## Metadata

Field         | Value
------------- | ---------------------------------------------
title         | Hello world
description   | A greeting written directly to screen RAM
author        | The MEGA65 Community
keywords      | hello, screen, zig
languages     | zig
requirements  | zig-mos
rom           | 920376
prgs          | hello.prg
build         | `zig build`
