# Development hints

## Inspecting the image

For inspecting dependencies inside the container:

```bash
docker run --rm media-toolbelt ldd /usr/bin/loudgain
```

Or run the Python REPL for inspecting python packages:

```
docker run --rm -it media-toolbelt python
```

## Building the image

To build the image yourself:

```bash
docker buildx build -t media-toolbelt .
```

The image is built from Debian stable. To build against a newer package set,
override the base release:

```bash
docker buildx build --build-arg DEBIAN_RELEASE=sid -t media-toolbelt .
```

## Multi-architecture builds

Released images are published for `linux/amd64` and `linux/arm64`:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t media-toolbelt .
```

On an Apple silicon Mac, [Apple's `container`](https://github.com/apple/container)
builds the native variant without Docker:

```bash
container build --tag media-toolbelt .
container run --rm --volume .:/mnt media-toolbelt mediainfo --Version
```
