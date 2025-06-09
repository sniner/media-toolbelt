# syntax=docker/dockerfile:1.4

# -----------------------------------
# Stage 1: Builder (build packages)
# -----------------------------------
FROM archlinux:latest AS builder

# 1) Initialize keyring and install build tools and runtime deps for building
RUN pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Sy --noconfirm --needed \
       git base-devel fakeroot cmake pkgconf \
       ffmpeg taglib taglib1 libebur128 libcdio libdiscid libsndfile libxml2 \
       boost python swig libmusicbrainz5 \
    && pacman -Scc --noconfirm

# 2) Create unprivileged user for makepkg
RUN useradd -m builder
USER builder
WORKDIR /home/builder

# 3) Clone loudgain-ffmpeg7 from AUR, analyze PKGBUILD and patch
RUN git clone https://aur.archlinux.org/loudgain-ffmpeg7.git loudgain

RUN cd loudgain && \
    printf 'prepare() {\n  cd "${srcdir}/${_pkgname}-${_pkgver}"\n  sed -i '\''s/CMAKE_MINIMUM_REQUIRED(VERSION 2.8)/CMAKE_MINIMUM_REQUIRED(VERSION 3.5)/'\'' CMakeLists.txt\n}\n' >> PKGBUILD && \
    makepkg --noconfirm --skippgpcheck

# 4) Clone sacd-extract from AUR, patch PKGBUILD and build
RUN git clone https://aur.archlinux.org/sacd-extract.git sacd-extract

RUN cd sacd-extract && \
    printf 'prepare() {\n  cd sacd-ripper/tools/sacd_extract\n  sed -i '\''s/cmake_minimum_required(VERSION 2.6)/cmake_minimum_required(VERSION 3.5)/'\'' CMakeLists.txt\n}\n' >> PKGBUILD && \
    makepkg --noconfirm --skippgpcheck

# 5) Save built packages
USER root
RUN mkdir /packages && \
    cp /home/builder/loudgain/*.pkg.tar.zst /packages/ && \
    cp /home/builder/sacd-extract/*.pkg.tar.zst /packages/


# -----------------------------------
# Stage 2: Runtime (Archlinux image)
# -----------------------------------
FROM archlinux:latest

# 1) Initialize keyring and install official runtime packages
RUN pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Sy --noconfirm --needed \
       bash fish less ca-certificates python python-pip \
       cdparanoia flac lame sox gpac fd whipper \
       ffmpeg taglib libebur128 libcdio libdiscid libsndfile libxml2 \
       python-musicbrainzngs python-pycdio python-mutagen \
    && pacman -Scc --noconfirm

# 2) Copy built AUR packages and install
COPY --from=builder /packages/*.pkg.tar.zst /tmp/packages/
RUN pacman -U --noconfirm /tmp/packages/*.pkg.tar.zst && \
    rm -rf /tmp/packages

# 3) Copy scripts and make them executable
COPY bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# 4) Entrypoint and default command
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
COPY README.md /app/README.md
ENTRYPOINT ["/app/docker-entrypoint.sh"]
