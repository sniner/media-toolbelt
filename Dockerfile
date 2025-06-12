# syntax=docker/dockerfile:1

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
       boost python swig libmusicbrainz5

# 2) Create unprivileged user for makepkg
RUN useradd -m builder
USER builder
WORKDIR /home/builder

# 3) Install AUR packages that require no modifications to build
# ...

# 4) Clone shntool from AUR and build with older language standard
RUN git clone https://aur.archlinux.org/shntool.git shntool \
    && cd shntool \
    && printf 'build() {\n  cd "${srcdir}/${pkgname}-${pkgver}"\n  CFLAGS="$CFLAGS -std=gnu17" ./configure --prefix=/usr\n  make\n}\n' >> PKGBUILD \
    && makepkg --noconfirm --skippgpcheck

# 4) Clone loudgain-ffmpeg7 from AUR, analyze PKGBUILD, patch and build
RUN git clone https://aur.archlinux.org/loudgain-ffmpeg7.git loudgain \
    && cd loudgain \
    && printf 'prepare() {\n  cd "${srcdir}/${_pkgname}-${_pkgver}"\n  sed -i '\''s/CMAKE_MINIMUM_REQUIRED(VERSION 2.8)/CMAKE_MINIMUM_REQUIRED(VERSION 3.5)/'\'' CMakeLists.txt\n}\n' >> PKGBUILD \
    && makepkg --noconfirm --skippgpcheck

# 5) Clone sacd-extract from AUR, patch PKGBUILD and build
RUN git clone https://aur.archlinux.org/sacd-extract.git sacd-extract \
    && cd sacd-extract \
    && printf 'prepare() {\n  cd sacd-ripper/tools/sacd_extract\n  sed -i '\''s/cmake_minimum_required(VERSION 2.6)/cmake_minimum_required(VERSION 3.5)/'\'' CMakeLists.txt\n}\n' >> PKGBUILD \
    && makepkg --noconfirm --skippgpcheck

# 6) Save built packages
USER root
RUN mkdir /packages \
    && cp /home/builder/shntool/*.pkg.tar.zst /packages/ \
    && cp /home/builder/loudgain/*.pkg.tar.zst /packages/ \
    && cp /home/builder/sacd-extract/*.pkg.tar.zst /packages/


# -----------------------------------
# Stage 2: Runtime (Archlinux image)
# -----------------------------------
FROM archlinux:latest

# 1) Initialize keyring and install official runtime packages
RUN pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Sy --noconfirm --needed \
       bash fish less ca-certificates python python-pip \
       cdparanoia flac fdkaac lame sox gpac fd whipper \
       ffmpeg taglib libebur128 libcdio libdiscid libsndfile libxml2 \
       mediainfo mkvtoolnix-cli cuetools yazi ripgrep fzf glow \
       python-musicbrainzngs python-pycdio python-mutagen \
    && pacman -Scc --noconfirm \
    && rm -rf /var/cache/pacman/pkg/* \
    && rm -rf /var/lib/pacman/sync/* \
    && rm -rf /tmp/*

# 2) Suppress pkg_resources deprecation warnings
ENV PYTHONWARNINGS="ignore::UserWarning:whipper.*"

# 3) Copy built AUR packages and install in single layer
RUN --mount=type=bind,from=builder,source=/packages,target=/tmp/packages \
    pacman -Sy --noconfirm \
    && pacman -U --noconfirm /tmp/packages/*.pkg.tar.zst \
    && pacman -Scc --noconfirm \
    && rm -rf /var/cache/pacman/pkg/* \
    && rm -rf /var/lib/pacman/sync/* \
    && rm -rf /var/tmp/*

# 4) Copy scripts and make them executable
COPY bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# 5) Entrypoint and default command
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
COPY README.md /app/README.md
WORKDIR /mnt
ENTRYPOINT ["/app/docker-entrypoint.sh"]
