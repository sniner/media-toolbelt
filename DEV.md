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
