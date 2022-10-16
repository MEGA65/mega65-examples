# Plasma example in LLVM C (`clang`)

This illustrates how to set up a C project using `clang` from the
[llvm-mos project](https://llvm-mos.org/wiki/Welcome)
and the official [`mega65-libc`](https://github.com/MEGA65/mega65-libc).
The latter is automatically downloaded by the `CMake` build system.

Clang provides modern compiler features and as illustrated in `plasma.c`,
using `#pragma unroll`, significant speedups can be achieved in targeted
bottle-necks.
It is also interesting to enable pedantic compiler warnings which aids in catching
bugs early on.
The setup can be easily adapted to instead use C++ (`clang++`); you merely need to
update `CMakeLists.txt` with `CXX` instead of `C` in the language setting.

## Building

1. Download the [llvm-mos-sdk](https://github.com/llvm-mos/llvm-mos-sdk/releases) binary
   and unpack to _e.g._ `$HOME/llvm-mos`.
2. Configure and build with:
   ~~~ bash
   cmake -DCMAKE_PREFIX_PATH=$HOME/llvm-mos . 
   make
   ~~~
