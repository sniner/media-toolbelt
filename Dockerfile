# syntax=docker/dockerfile:1

# Debian base. Override to build against a newer package set, e.g.
#   --build-arg DEBIAN_RELEASE=sid
ARG DEBIAN_RELEASE=trixie

# -----------------------------------
# Stage 1: Builder (out-of-archive tools)
# -----------------------------------
# Almost everything in this image is packaged in Debian. This stage covers the
# two exceptions: sacd_extract has no Debian package at all, and yazi is not in
# the archive either, but upstream publishes static musl builds as .deb.
FROM debian:${DEBIAN_RELEASE}-slim AS builder

ARG SACD_RIPPER_VERSION=0.3.9.3
ARG YAZI_VERSION=26.9.1
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

# 1) Build tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential cmake pkgconf git curl ca-certificates \
       libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 2) Build sacd_extract from the sacd-ripper sources
#    - the bundled CMakeLists.txt predates CMake 3.5 and is rejected by current CMake
#    - the sources need a relaxed pointer check to compile with current GCC
RUN git clone --depth 1 --branch "${SACD_RIPPER_VERSION}" \
       https://github.com/sacd-ripper/sacd-ripper.git /src \
    && sed -i 's/cmake_minimum_required(VERSION 2.6)/cmake_minimum_required(VERSION 3.5)/' \
       /src/tools/sacd_extract/CMakeLists.txt \
    && cmake -S /src/tools/sacd_extract -B /build \
       -DCMAKE_C_FLAGS=-Wno-incompatible-pointer-types \
    && cmake --build /build \
    && install -Dm755 /build/sacd_extract /out/sacd_extract

# 3) Fetch the statically linked yazi build for the target architecture
RUN case "${TARGETARCH}" in \
        amd64) yazi_target=x86_64-unknown-linux-musl ;; \
        arm64) yazi_target=aarch64-unknown-linux-musl ;; \
        *) echo "no yazi build for TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/yazi.deb \
       "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-${yazi_target}.deb" \
    && dpkg-deb -x /tmp/yazi.deb /tmp/yazi \
    && install -Dm755 /tmp/yazi/usr/bin/yazi /out/yazi \
    && install -Dm755 /tmp/yazi/usr/bin/ya /out/ya


# -----------------------------------
# Stage 2: Runtime (Debian image)
# -----------------------------------
FROM debian:${DEBIAN_RELEASE}-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1) fdkaac lives in non-free (the Fraunhofer FDK license is not DFSG-free)
RUN sed -i 's/^Components:.*/Components: main contrib non-free/' \
       /etc/apt/sources.list.d/debian.sources

# 2) Install runtime packages
#    whipper pulls in its own dependencies (cd-paranoia, cdrdao, eject,
#    python3-cdio, python3-libdiscid, ...), so those are not listed here.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash fish less ca-certificates \
       python3 python3-pip python-is-python3 \
       python3-mutagen python3-musicbrainzngs \
       ffmpeg sox flac lame fdkaac \
       cdparanoia cd-discid libcdio-utils whipper \
       loudgain shntool cuetools sndfile-programs \
       mediainfo mkvtoolnix \
       ripgrep fd-find fzf jq 7zip chafa poppler-utils glow \
       mc libxml2-utils \
    && rm -rf /var/lib/apt/lists/*

# 3) Debian ships fd as "fdfind" to avoid a name clash; restore the usual name
RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

# 4) Copy the tools built or fetched in the builder stage
COPY --from=builder /out/sacd_extract /out/yazi /out/ya /usr/local/bin/

# 5) Copy scripts
COPY --chmod=755 bin/ /usr/local/bin/

# 6) Entrypoint and default command
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
COPY README.md /app/README.md
WORKDIR /mnt
ENTRYPOINT ["/app/docker-entrypoint.sh"]
