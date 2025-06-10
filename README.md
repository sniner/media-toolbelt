# media-toolbelt

**media-toolbelt** is a Docker image bundling a set of command-line tools for working with audio and video files. It's especially useful in environments where installing software is restricted, such as Unraid or locked-down servers. The goal is to provide a convenient, portable toolbox without polluting the host system.

## Usage

To run a tool, pass the command as arguments to the container:

```bash
docker run --rm media-toolbelt ffmpeg -version
```

However, the enclosed tools are only useful when they can access media files. Use a volume mount to make your local files available inside the container:

```bash
docker run --rm -v /mnt/user/media:/mnt media-toolbelt rg-albums /mnt
```

If no command is provided, this README is displayed.

## Notable Programs

* `ffmpeg` – versatile audio/video encoder, converter and processing tool
* `loudgain` – ReplayGain 2.0 scanner and tagger
* `whipper` – accurate audio CD ripper (Python-based)
* `sacd_extract` – extracts audio from SACD images
* `fd` – modern replacement for `find`
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

## Included Scripts

* `rg-albums <directory>`
  Calculates R128 loudness (ReplayGain) for each subdirectory separately, treating each as its own album. Tags are written in-place.

* `rg-album <directory>`
  Like `rg-albums`, but treats all subdirectories as a single album.

## License & Disclaimer

This project is licensed under the BSD 2-Clause License. Use at your own risk. No liability is accepted for any damage or data loss resulting from use of this image.
