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

## Included Programs

* `ffmpeg` – versatile audio/video encoder, converter and processing tool
* `loudgain` – ReplayGain 2.0 scanner and tagger
* `whipper` – accurate audio CD ripper (Python-based)
* `sacd_extract` – extracts audio from SACD images
* `fd` – modern replacement for `find`

## Included Scripts

* `rg-albums <directory>`
  Calculates R128 loudness (ReplayGain) for each subdirectory separately, treating each as its own album. Tags are written in-place.

* `rg-album <directory>`
  Like `rg-albums`, but treats all subdirectories as a single album.

## License & Disclaimer

This project is licensed under the BSD 2-Clause License. Use at your own risk. No liability is accepted for any damage or data loss resulting from use of this image.
