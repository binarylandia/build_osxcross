# Prebuilt macOS cross-compilation toolchain for Linux

## [Releases](https://github.com/binarylandia/build_osxcross/releases)

Builds [osxcross](https://github.com/tpoechtrager/osxcross) toolchains that compile macOS binaries for x86_64 and arm64 on x86_64 Linux hosts.

## Contents of a release

- The osxcross `llvm` flavor: compiler wrappers such as `x86_64-apple-darwin20.2-clang` and `arm64-apple-darwin20.2-clang++`, and tool links (`ld`, `ar`, `otool`, `lipo`, `install_name_tool`, `dsymutil`, ...) that run clang, `ld64.lld`, and the LLVM Darwin tools
- cctools `lipo`, which the `llvm` flavor uses for compatibility
- compiler-rt for macOS in `compiler-rt/`, in the layout of the clang resource folder
- the macOS SDK in `SDK/`, as osxcross installs it
- CMake toolchain files

The wrappers do not contain clang. They run the clang, `ld64.lld`, and LLVM tools of the [build_llvm](https://github.com/binarylandia/build_llvm) release named in the release notes and in `manifest.json`.

## Use

1. Install the build_llvm release that the release names and put its `bin` folder on `PATH`
2. Unpack the archive, for example into `/opt/osxcross`, and put `/opt/osxcross/bin` on `PATH`
3. Copy the contents of `compiler-rt/` into `$(clang -print-resource-dir)`, so clang links compiler-rt (for example for `__builtin_available`)

The host programs run on x86_64 Linux with glibc 2.17 or newer and need no shared C++ runtime.

## Build

1. Put the SDK tarball into `tarballs/` and its path and sha256 into `.env` (see `.env.example`). The tarball comes from `tools/gen_sdk_package.sh` of osxcross, run on a Mac
2. `./build` builds the builder image and runs `scripts/main`, which writes the archives and their metadata into `.out/<build time>/`
3. `scripts/release <build time>` publishes them as a release

Every source is pinned: osxcross and cctools-port by commit, LLVM and the host GCC by release and sha256, the compiler-rt source by sha256 (`scripts/sources.sha256`), and the base image by digest.
