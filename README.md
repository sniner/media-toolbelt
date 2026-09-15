# media-toolbelt

**media-toolbelt** is a Docker image bundling a set of command-line tools for working with audio and video files. It's especially useful in environments where installing software is restricted, such as Unraid or locked-down servers. The goal is to provide a convenient, portable toolbox without polluting the host system.

## Usage

To run a tool, pass the command as arguments to the container. For example:

```bash
docker run --rm ghcr.io/sniner/media-toolbelt ffmpeg -version
```

If no command is given, the container will display this README.

Most tools require access to your media files to be useful. Use a volume mount to share files from your host system with the container:

```bash
docker run --rm -v .:/mnt ghcr.io/sniner/media-toolbelt mtb-replaygain "Eric Clapton/"
```

Mounting the current directory (`-v .:/mnt`) gives you the convenience of working inside your familiar folder structure. The container starts with `/mnt` as its working directory, so using relative paths feels natural—almost like using a native binary.

For added convenience, you can define an alias:

```bash
alias mtb="docker run --rm -it -v .:/mnt ghcr.io/sniner/media-toolbelt"
```

This allows you to run tools more easily:

```bash
mtb mtb-replaygain "Eric Clapton/"
mtb ls -ls
mtb fd -e m4a
```

If you're planning to run several commands in a row, it might be easier to enter an interactive shell and stay inside the container:

```bash
docker run --rm -it -v .:/mnt ghcr.io/sniner/media-toolbelt bash
```

Both `bash` and `fish` are available.

## Running on macOS

On an Apple silicon Mac, no Docker installation is needed. Apple's own
[`container`](https://github.com/apple/container) runs the very same image, and
pulls the `arm64` variant so the tools run at native speed:

```bash
brew install container
container system start
```

The first start asks whether to install the Linux kernel it runs containers
with; say yes, or install it beforehand with `container system kernel set
--recommended`.

From there, every command above works with `container` in place of `docker`:

```bash
container run --rm -v .:/mnt ghcr.io/sniner/media-toolbelt mtb-replaygain "Eric Clapton/"
container run --rm -it -v .:/mnt ghcr.io/sniner/media-toolbelt fish
```

Files written into the mounted directory belong to you afterwards, so tagging
in place needs no `--user` gymnastics.

One thing does not work here: `container` passes no devices into the container,
which rules out everything that talks to a drive — `whipper`, `cdparanoia` and
`sacd_extract` need a machine with the disc in it. Everything that works on
files is unaffected.

## Notable Programs

* `ffmpeg` – versatile audio/video encoder, converter and processing tool
* `loudgain` – ReplayGain 2.0 scanner and tagger
* `whipper` – accurate audio CD ripper (Python-based)
* `sacd_extract` – extracts audio from SACD images
* `mutagen-inspect` – metadata viewer for audio files (based on [Mutagen](https://github.com/quodlibet/mutagen))
* `flac`, `metaflac` – FLAC encoder and metadata tools
* `lame` – high-quality MP3 encoder
* `fdkaac` – high-quality AAC encoder using the Fraunhofer FDK codec
* `sox` – Swiss Army knife of sound processing
* `mediainfo` – displays technical and tag information about media files

### mkvtoolnix Tools

These tools are part of the [MKVToolNix](https://mkvtoolnix.download/) suite and are used to inspect, extract, and manipulate Matroska (MKV) container files:

* `mkvmerge` – merge multimedia streams into an MKV container
* `mkvinfo` – display information about MKV files
* `mkvextract` – extract tracks and data from MKV files

### libsndfile Tools

These utilities operate on audio files supported by libsndfile (e.g., WAV, FLAC, AIFF):

* `sndfile-cmp` – compare two audio files
* `sndfile-concat` – concatenate multiple files
* `sndfile-convert` – convert between formats
* `sndfile-deinterleave` – split interleaved multichannel files
* `sndfile-info` – show file format and audio metadata
* `sndfile-interleave` – combine separate channels into one file
* `sndfile-metadata-get` – extract metadata
* `sndfile-metadata-set` – write metadata
* `sndfile-play` – play audio via ALSA or OSS (if supported)
* `sndfile-salvage` – try to recover corrupted audio files

> These tools are part of the [libsndfile](http://www.mega-nerd.com/libsndfile/) project.

### Utility Tools

In addition to the specialized audio and video tools, **media-toolbelt** includes a set of helpful command-line utilities that simplify common file and directory operations. While these tools aren't directly media-related, they prove extremely useful in day-to-day workflows:

* `fd` – a modern replacement for `find`, faster and more user-friendly
* `ripgrep` – blazing-fast recursive search tool, great for scanning metadata or logs
* `fzf` – interactive fuzzy finder, handy for picking files or filtering lists
* `yazi` – a modern TUI file manager with preview support, perfect for quickly browsing media directories

  > Note: Since `yazi` is an interactive terminal application, don't forget to pass `-it` to `docker run`:
  >
  > ```bash
  > docker run --rm -it -v .:/mnt ghcr.io/sniner/media-toolbelt yazi
  > ```

* `mc` – Midnight Commander, the classic two-pane file manager, for anyone who prefers it to `yazi`. Being interactive as well, it needs `-it` just the same.
* `tree` – prints a directory as a tree, handy for showing the shape of an album or a season folder at a glance
* [`fifi`](https://github.com/sniner/fifi) – finds duplicate files by content, so a media library that grew over years can be checked for the same recording sitting in three places

## Included Scripts

* `mtb-replaygain [--single|--all] <directory>`
  Calculates R128 loudness (ReplayGain) for each subdirectory separately (`--single`) or all subdirectories as a single album (`--all`). Tags are written in-place.

* `mtb-media-check <directory>`
  Reads all media files and checks for errors.

* `mtb-flac-split <flac-file> <cue-file>`
  Splits a flac file that contains multiple tracks into individual flac files.

## License & Disclaimer

This project is licensed under the BSD 2-Clause License. Use at your own risk. No liability is accepted for any damage or data loss resulting from use of this image.
