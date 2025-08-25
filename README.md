# Linux From Scratch builder in Docker container

This repository is a collection of scripts created especially to
automate the build process of Linux From Scratch (LFS).

Currently used version of LFS is 12.4-rc1

## How to use

You need to install `docker` and `docker-compose` before you begin,
if you not have it yet.

* https://docs.docker.com/install/#supported-platforms
* https://docs.docker.com/compose/install/

### Normal usage

Clone from github and prepare the repository:

    git clone https://github.com/EvilFreelancer/docker-lfs-build.git
    cd docker-lfs-build

Start container:

    docker-compose up -d

Then login to LFS container:

    docker-compose exec lfs bash

Start building:

    /book/book.sh

Result of building will be in `dist` folder.

### Download from Docker Hub

    docker pull evilfreelancer/docker-lfs-build

### Create your custom `docker-compose.yml` file

```yml
version: '2'

services:
  lfs:
    restart: unless-stopped
    image: evilfreelancer/docker-lfs-build
    volumes:
      - ./dist:/dist
    # You can set any entrypoint what you like, for example "inf sleep"
    # by default here is ["/book/book.sh"]
    entrypoint: ["sleep", "inf"]
```
