# Plasma example in Rust

This illustrates how to set up a Rust project using `rust-mos` and the
[`mos-hardware`](https://github.com/mlund/mos-hardware) crate.
The latter includes hardware register tables; bindings to MEGA65 libc; etc.

## Building and Running

The project requires [rust-mos](https://github.com/mrk-its/rust-mos).
A docker image of rust-mos is [available](https://hub.docker.com/r/mrkits/rust-mos) if you
do not fancy compiling LLVM and rust-mos, see below.

### Docker and Visual Studio Code

The easiest way is to use the provided `.devcontainer.json` configuration for vscode:

1. Start Docker
2. In Visual Studio Code, add the 
   [Dev Containers](vscode:extension/ms-vscode-remote.remote-containers) extension
3. Open the project in vscode (_e.g._ with `code .`) and when asked, _Reopen in Container_.
   The directory is automatically mounted inside the Docker container.
4. In the vscode terminal do:
   ~~~ bash
   export CARGO_NET_GIT_FETCH_WITH_CLI=true # only needed if Docker uses qemu
   cargo build --release                    # output in target/mos-mega65-none/release
   ~~~

## Metadata

Field         | Value
------------- | -------------------------------
title         | Plasma effect
description   | A demo-inspired plasma effect
author        | wombat
keywords      | plasma, charset
languages     | rust
requirements  | rust-mos
rom           | 920376
discord       | wombat
prgs          | plasma.prg
build         | `cargo build --release`

