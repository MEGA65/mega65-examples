# C++ Plasma example

This illustrates how to set up a C++ project using `clang++` from the
[llvm-mos project](https://llvm-mos.org/wiki/Welcome)
and the official [`mega65-libc`](https://github.com/MEGA65/mega65-libc).
The latter is automatically downloaded by the `CMake` build system.

## Building

1. Download the [llvm-mos-sdk](https://github.com/llvm-mos/llvm-mos-sdk/releases) binary
   and unpack to _e.g._ `$HOME/llvm-mos`.
2. Configure and build with:
   ~~~ bash
   cmake -DCMAKE_PREFIX_PATH=$HOME/llvm-mos . 
   make
   ~~~