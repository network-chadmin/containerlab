# Lab images

- `network-host-1.0/`: the original host image, kept unchanged for older labs.
- `network-host-2.0/`: current host image, built on Ubuntu 24.04.
- `seamart-web/`: the SeaMart portal page, used only by the `seamart-server` node. Built on network-host 2.0.

## Build order

Build and push `network-host:2.0` first, then `seamart-web:2.0`, since seamart-web is built on top of it.

Multi-architecture builds with `--push` go straight to Docker Hub and aren't loaded locally. To test on your own machine first, build a single-architecture image:

    docker build -t networkchadmin/network-host:2.0 images/network-host-2.0
    docker run -d --name test-host networkchadmin/network-host:2.0
    docker exec test-host ip -br addr

Then push both images with `buildx` as shown in each Dockerfile header.
