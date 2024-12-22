# syntax=docker/dockerfile:1
# check=experimental=all
FROM debian:12.7

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV HOST_GCC_TRIPLET="x86_64-unknown-linux-gnu"
ENV HOST_TUPLE="x86_64-unknown-linux-gnu"
ENV HOST_TUPLE_DEBIAN="x86_64-linux-gnu"

RUN set -euxo pipefail >/dev/null \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update -qq --yes \
&& apt-get install -qq --no-install-recommends --yes \
  bash \
  bzip2 \
  ca-certificates \
  curl \
  file \
  git \
  make \
  parallel \
  patch \
  pigz \
  pixz \
  pkg-config \
  python3 \
  sudo \
  tar \
  time \
  unzip \
  util-linux \
  xz-utils \
  zstd \
>/dev/null \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean autoclean >/dev/null \
&& apt-get autoremove --yes >/dev/null

ENV PREFIX_HOST="/usr"
ENV HOST_GCC_DIR="/opt/gcc"

COPY --link "dev/docker/files/install-libbzip2" "/"
RUN /install-libbzip2 "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-liblzma" "/"
RUN /install-liblzma "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libz" "/"
RUN /install-libz "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libzstd" "/"
RUN /install-libzstd "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-libxml" "/"
RUN /install-libxml "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-openssl" "/"
RUN /install-openssl "${HOST_TUPLE}" "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-ccache" "/"
RUN /install-ccache "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-cmake" "/"
RUN /install-cmake "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-llvm" "/"
RUN /install-llvm "${PREFIX_HOST}"

COPY --link "dev/docker/files/install-gcc-cross" "/"
RUN /install-gcc-cross "${HOST_TUPLE}" "${HOST_GCC_DIR}"

ENV PATH="${HOST_GCC_DIR}/bin:${PATH}"
ENV C_INCLUDE_PATH="/usr/include:/usr/include/${HOST_TUPLE_DEBIAN}"
ENV CPLUS_INCLUDE_PATH="${C_INCLUDE_PATH}"
ENV LIBRARY_PATH="/usr/lib:/usr/lib64:/usr/lib/${HOST_TUPLE_DEBIAN}"

ENV C_INCLUDE_PATH="${SYSROOT}/usr/include:${C_INCLUDE_PATH}"
ENV CPLUS_INCLUDE_PATH="${C_INCLUDE_PATH}"
ENV LIBRARY_PATH="${SYSROOT}/usr/lib:${LIBRARY_PATH}"

ENV SYSROOT="${HOST_GCC_DIR}/${HOST_GCC_TRIPLET}/sysroot"

ENV GCC="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gcc"
ENV GXX="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-g++"
ENV GPP="${GXX}"
ENV GFORTRAN="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gfortran"
ENV ADDR2LINE="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-addr2line"
ENV AR="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gcc-ar"
ENV AS="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-as"
ENV CPP="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-cpp"
ENV CPPFILT="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-c++filt"
ENV ELFEDIT="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-elfedit"
ENV LD="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-ld"
ENV LDD="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-ldd"
ENV NM="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gcc-nm"
ENV OBJCOPY="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-objcopy"
ENV OBJDUMP="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-objdump"
ENV RANLIB="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-gcc-ranlib"
ENV READELF="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-readelf"
ENV SIZE="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-size"
ENV STRINGS="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-strings"
ENV STRIP="${HOST_GCC_DIR}/bin/${HOST_GCC_TRIPLET}-strip"

ENV CLANG_FLAGS="--gcc-toolchain=${HOST_GCC_DIR} -static-libgcc -static-libstdc++ --sysroot=${SYSROOT} -fuse-ld=${LD}"
ENV CLANG="${PREFIX_HOST}/bin/clang ${CLANG_FLAGS}"
ENV CLANGXX="${PREFIX_HOST}/bin/clang++ ${CLANG_FLAGS}"
ENV CLANGPP="${CLANGXX}"
ENV FLANG="${PREFIX_HOST}/bin/flang ${CLANG_FLAGS}"

ENV CC="${GCC}"
ENV CXX="${GXX}"
ENV FC="${GFORTRAN}"

RUN set -euxo pipefail >/dev/null \
&& cd "${HOST_GCC_DIR}/bin" \
&& ln -sf "${CPPFILT}" "c++filt"


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

COPY --link "dev/docker/files/create-user" "/"
RUN /create-user


USER ${USER}
