# build_osxcross

Prebuilt macOS cross-compilation toolchain for Linux.

## [Releases](https://github.com/binarylandia/build_osxcross/releases)

Builds [osxcross](https://github.com/tpoechtrager/osxcross) toolchains that enable compiling macOS binaries from x86_64 Linux hosts. Includes both Clang and GCC backends for maximum compatibility.

## Features

- Clang-based toolchain (primary)
- GCC cross-compiler with Fortran support
- compiler-rt for sanitizers and profiling
- Statically linked for portability
- dsymutil for debug symbol handling

## Use Cases

- Building macOS binaries in Linux CI/CD
- Cross-compiling Rust, Go, or C/C++ for macOS
- Creating universal macOS binaries from Linux
- macOS ARM64 (Apple Silicon) cross-compilation

## Keywords

osxcross, macos cross compile, linux to macos, apple cross compiler, darwin cross compile, macos sdk linux, apple silicon cross compile, aarch64 darwin, x86_64 darwin, macos toolchain linux
