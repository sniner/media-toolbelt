# Development hints

## Inspecting the image

For inspecting dependencies inside the container:

```bash
docker run --rm media-toolbelt ldd /usr/bin/loudgain
```

Or run the Python REPL:

```
docker run --rm -it media-toolbelt python
```

## Building the image

To build the image yourself:

```bash
docker build -t media-toolbelt .
```
