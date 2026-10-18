# syntax=docker/dockerfile:1
ARG DOCKER_BASE_IMAGE="debian:12.14-slim@sha256:60eac759739651111db372c07be67863818726f754804b8707c90979bda511df"
FROM $DOCKER_BASE_IMAGE

ARG DOCKER_BASE_IMAGE
ENV DOCKER_BASE_IMAGE="${DOCKER_BASE_IMAGE}"

SHELL ["bash", "-euxo", "pipefail", "-c"]

RUN set -euxo pipefail >/dev/null \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update -qq --yes \
&& apt-get install -qq --no-install-recommends --yes \
  bash \
  bzip2 \
  ca-certificates \
  cmake \
  curl \
  file \
  git \
  jq \
  make \
  parallel \
  patch \
  pigz \
  python3 \
  sudo \
  tar \
  xz-utils \
  zstd \
>/dev/null \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean autoclean >/dev/null \
&& apt-get autoremove --yes >/dev/null

COPY --link "docker/files/fetch" "/"

# The host programs of the toolchain (the osxcross wrapper and cctools lipo)
# are built against the glibc 2.17 sysroot of this GCC and link libstdc++
# statically, so they run on any Linux host with glibc 2.17 or newer.
ARG HOST_GCC_RELEASE="gcc-14.4.0-2026-10-18_01-15-48"
ARG HOST_GCC_SHA256="c626e1527cde422062b97b6556d47c2e99085cca8867a54f531e2b145a68d0a4"
ENV HOST_GCC_TRIPLET="x86_64-unknown-linux-gnu"
ENV HOST_GCC_DIR="/opt/gcc"
RUN set -euxo pipefail >/dev/null \
&& name="${HOST_GCC_RELEASE/gcc-14.4.0-/gcc-14.4.0-${HOST_GCC_TRIPLET}-}" \
&& /fetch "https://github.com/binarylandia/build_crosstool-ng/releases/download/${HOST_GCC_RELEASE}/${name}.tar.xz" "${HOST_GCC_SHA256}" /tmp/gcc.tar.xz \
&& mkdir -p "${HOST_GCC_DIR}" \
&& tar -C "${HOST_GCC_DIR}" -xJf /tmp/gcc.tar.xz \
&& rm /tmp/gcc.tar.xz \
&& "${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gcc" --version

# The LLVM that the llvm flavor of osxcross runs: clang, ld64.lld, and the
# Darwin binary tools. Consumers install the same release.
ARG LLVM_RELEASE
ARG LLVM_SHA256
ENV LLVM_RELEASE="${LLVM_RELEASE}"
ENV LLVM_DIR="/opt/llvm"
RUN set -euxo pipefail >/dev/null \
&& /fetch "https://github.com/binarylandia/build_llvm/releases/download/${LLVM_RELEASE}/${LLVM_RELEASE}.tar.zst" "${LLVM_SHA256}" /tmp/llvm.tar.zst \
&& mkdir -p "${LLVM_DIR}" \
&& zstd -dc /tmp/llvm.tar.zst | tar -C "${LLVM_DIR}" -x \
&& rm /tmp/llvm.tar.zst \
&& "${LLVM_DIR}/bin/clang" --version \
&& "${LLVM_DIR}/bin/ld64.lld" --version

ENV PATH="${LLVM_DIR}/bin:${PATH}"
ENV SYSROOT="${HOST_GCC_DIR}/${HOST_GCC_TRIPLET}/sysroot"
ENV HOST_CFLAGS="--gcc-toolchain=${HOST_GCC_DIR} --sysroot=${SYSROOT} -fuse-ld=lld"
ENV HOST_LDFLAGS="-static-libgcc -static-libstdc++"
ENV AR="llvm-ar"
ENV NM="llvm-nm"
ENV RANLIB="llvm-ranlib"

ARG USER=user
ARG GROUP=user
ARG UID
ARG GID

ENV USER=$USER
ENV GROUP=$GROUP
ENV UID=$UID
ENV GID=$GID
ENV TERM="xterm-256color"
ENV HOME="/home/${USER}"

COPY --link "docker/files/create-user" "/"
RUN /create-user

USER ${USER}
