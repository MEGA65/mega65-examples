# Plasma effect in Zig (`zig build`)

This is a port of [`c/plasma`](../../c/plasma) to Zig. It keeps the same sine
table, screen layout and drawing loop, so the pattern on screen matches the C
build.

Unlike `zig/hello`, this one calls into C. The mega65-libc headers `conio.h`
and `random.h` are translated into a Zig module with `b.addTranslateC`, so
`plasma.zig` can call `setcharsetaddr` and `rand8` directly. The `conio.c` and
`random.c` behind those declarations are compiled by Zig from the same package.

## Building and Running

1. Install [zig-mos](https://github.com/kassane/zig-mos-bootstrap/releases),
   the `mos` fork of Zig.
2. Build:
   ~~~ bash
   cd zig/plasma
   zig build                              # writes zig-out/bin/plasma.prg
   zig build -Doptimize=ReleaseSmall
   ~~~

Run in Xemu:

~~~ bash
timeout 30 xemu-xmega65 -headless -testing -besure \
    -sdimg ~/.local/share/xemu-lgb/mega65/mega65.img \
    -prg zig-out/bin/plasma.prg -screenshot plasma.png
~~~

The whole 80x25 screen fills with a moving pattern and the program keeps
running, so Xemu needs a timeout.

## Metadata

Field         | Value
------------- | ---------------------------------------------
title         | Plasma effect in Zig
description   | A demo-inspired plasma effect in zig
author        | The MEGA65 Community
keywords      | plasma, charset, zig
languages     | zig
requirements  | zig-mos
rom           | 920376
prgs          | plasma.prg
build         | `zig build`
