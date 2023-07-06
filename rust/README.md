# Rust examples for MEGA65

This illustrates how to set up a cargo workspace using `rust-mos` and the
[`mos-hardware`](https://github.com/mlund/mos-hardware) crate.
The latter includes hardware register tables; bindings to MEGA65 libc; etc.

## Building and Running

Building requires [rust-mos](https://github.com/mrk-its/rust-mos).
A docker image of rust-mos is [available](https://hub.docker.com/r/mrkits/rust-mos) if you
do not fancy compiling LLVM and rust-mos, see below.

### Docker and Visual Studio Code

The easiest way is to use the provided `.devcontainer.json` configuration for vscode:

1. Start Docker
2. In Visual Studio Code (VSC), add the 
   [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
3. Open the project in VSC:
   ~~~ bash
   cd mega65-examples/rust
   code .
   ~~~

4. When asked, _Reopen in Container_.
   The directory is automatically mounted inside the Docker container.
5. In the VSC terminal do:
   ~~~ bash
   cargo build --release                    # outputs to target/mos-mega65-none/release
   ~~~

## Adding More Examples

1. Create a new directory, e.g. `my_example` in the `rust` directory with the following layout:
   ~~~
   my_example/
   ├── README.md
   ├── Cargo.toml
   └── src/
       └── main.rs
   ~~~
   (see `plasma/` for an example)
2. In `rust/Cargo.toml`, add the new directory name, here `my_example`, to `members`
3. Build with `cargo build --release -p my_example`

