# Building a Virtuoso Open-Source Edition Reference Docker Image

_Copyright (C) 2026 OpenLink Software <vos.admin@openlinksw.com>_

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Introduction](#introduction)
- [Downloading and Building the Docker Image](#downloading-and-building-the-docker-image)
- [Configuring the Build](#configuring-the-build)
- [How OpenLink Builds Official Images](#how-openlink-builds-official-images)
- [See Also](#see-also)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

This git repository illustrates how to build a reference Virtuoso Open-Source (VOS) Docker image for a single architecture.

This image is functionally equivalent to the version distributed via [the official OpenLink repository on Docker Hub](https://hub.docker.com/repository/docker/openlink/virtuoso-opensource-7/general).

Testing covers Ubuntu 18.04 (x86_64) and macOS Big Sur 11.6 (x86_64 and Apple Silicon).

Most modern Linux distributions provide Docker packages. For Apple macOS and Microsoft Windows, Docker installers are found at the [Docker website](https://docker.com/products).

**Note**: Please install `git`, `docker` and `docker compose` before running build steps.


## Downloading and Building the Docker Image

1. Clone the git repository:

```
$ git clone https://github.com/openlink/vos-reference-docker
```

2. Build the Docker image:

```
$ ./build.sh

======================================================================
  BUILD STARTED: Fri May 23 09:49:31 AM UTC 2025
======================================================================

 * Pulling docker image

 * Building docker image
   (this may take around 20-30 minutes on current hardware)

======================================================================
  BUILD FINISHED: Fri May 23 10:07:07 AM UTC 2025
======================================================================
```

3. Check the Docker image version:

```
$ docker run -i -t vos-reference version

[vos-reference/v7.2.15]

This Docker image contains this Virtuoso version:

```
Virtuoso Open Source Edition (Column Store) (multi threaded)
Version 7.2.15.3241-pthreads as of May 23 2025 (bae7c13)
Compiled for Linux (x86_64-pc-linux-gnu)
Copyright (C) 1998-2026 OpenLink Software
```

## Configuring the Build

The `build.sh` script uses a small set of environment variables to control build behavior.

The `GIT_TAG` variable in the script specifies the VOS tree state to check out:

```
#
#  Build using a specific git tag, branch or commit ID
#
export GIT_TAG=v7.2.15
#export GIT_TAG=stable/7
#export GIT_TAG=bae7c13af8f4cb5ca0ecbaa9c4cda7f1b5f47f07
```

The `DOCKER_TAG` variable sets the output image tag:

```
export DOCKER_TAG=vos-reference
```

## How OpenLink Builds Official Images

The difference between this reference image and the official images published by OpenLink is simple: official images are built with [Docker multi-arch support](https://docs.docker.com/desktop/multi-arch/) to run natively on ARM64-based systems (macOS on Apple Silicon, cloud-based ARM instances, Raspberry Pi and similar systems) and Intel/AMD 64-bit systems supporting Docker containers.

OpenLink also provides VOS images based on Ubuntu or Alpine, for a total of four internal builds.

Building official images with the method in this reference image requires half of those builds to run through an emulator, which is slow. A native build usually takes 20-30 minutes on a matching CPU. The same build for a different CPU architecture through an emulator takes about 4-5 hours. Total build time across both distributions and architectures is about 10 hours.

OpenLink already builds and tests Virtuoso Open Source on multiple platforms to validate behavior with different operating systems, development tools and libraries. This is equivalent to the `vos-build` steps in this reference `Dockerfile`.

These builds run in parallel on separate native platforms. A tarball containing binary installation artifacts is then stored on an internal server. The Docker build process then collates the four builds into one location, extracts files and uses the `COPY` command as in the second part of this `Dockerfile`.


## See Also
  * [License](LICENSE.md)
  * [Copying](COPYING.md)
  * [OpenLink repository on Docker Hub](https://hub.docker.com/repository/docker/openlink/virtuoso-opensource-7/general)
  * [Virtuoso Docker Reference Guide](https://community.openlinksw.com/t/virtuoso-enterprise-edition-reference-guide-for-docker-deployment/286)
  * [How to Bulkload data into a Virtuoso docker instance](https://community.openlinksw.com/t/how-to-bulk-load-data-into-a-virtuoso-docker-instance/3248)
