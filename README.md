# Building a Virtuoso Open-Source Edition Reference Docker

_ Copyright (C) 2023 OpenLink Software <vos.admin@openlinksw.com>_

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Introduction](#introduction)
- [Downloading and building the docker image](#downloading-and-building-the-docker-image)
- [Configuring the build](#configuring-the-build)
- [How does Openlink build the official images it distributes?](#how-does-openlink-build-the-official-images-it-distributes)
- [See Also](#see-also)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

This Git tree exemplifies how to build a reference implementation
of the Virtuoso Open-Source (VOS) docker image for a single
architecture.

This image is functionally equivalent to the version we distribute
via
[the official OpenLink repository on Docker Hub](https://hub.docker.com/repository/docker/openlink/virtuoso-opensource-7/general).

It has been tested on both Ubuntu 18.04 (x86_64) and macOS Big Sur
11.6 (x86_64 and Apple Silicon).

Most modern Linux distributions provide docker packages as part of
their repository.

For Apple macOS and Microsoft Windows Docker installers can be
downloaded from the [Docker website](https://docker.com/products).

**Note**: Installing software like git, Docker and Docker Compose
is left as an exercise for the reader.


## Downloading and building the docker image

1. Clone the git tree to your own system using the following command:

```
$ git clone https://github.com/openlink/vos-reference-docker
```

2. Build the docker image using the following command:

```
$ ./build.sh

======================================================================
  BUILD STARTED: Tue Dec  5 12:13:17 CET 2023
======================================================================

 * Building docker image 
   (this may take around 20-30 minuts on current hardware)

======================================================================
  BUILD FINISHED: Tue Dec  5 12:36:31 CET 2023
======================================================================
```

3. Check the version number of this docker image:

```
$ docker run -i -t vos-reference version

[vos-reference/v7.2.11]

This Docker image is using the following version of Virtuoso:

Virtuoso Open Source Edition (Column Store) (multi threaded)
Version 7.2.11.3238-pthreads as of Dec  5 2023 (d89671f)
Compiled for Linux (aarch64-unknown-linux-gnu)
Copyright (C) 1998-2023 OpenLink Software

```

## Configuring the build

The `build.sh` script uses a handful of environment variables to
control the build.

The following setting in the script is used to checkout the exact
state of the VOS tree to use:

```
#
#  Build using a specific git tag, branch or commit id
#
export GIT_TAG=v7.2.11
#export GIT_TAG=develop/7
#export GIT_TAG=a1f22974f8fb8fc485e93c425c6bf727725016f3
```

The following setting is used to tag the image you build:

```
export DOCKER_TAG=vos-reference
```

## How does Openlink build the official images it distributes?

The difference between this reference image and the official images
that OpenLink publishes is that the official images are built with
[Docker multi-arch support](https://docs.docker.com/desktop/multi-arch/)
to run natively on ARM64-based systems (macOS on Apple Silicon,
cloud-based ARM instances, Raspberry Pi, etc.) as well as Intel/AMD
64bit-based systems that support the use of docker containers.

Additionally, OpenLink supplies VOS images based on either Ubuntu
or Alpine, making a total of 4 internal builds.

Building the official images using the method described in this
reference image would require half of these builds to be run via
an emulator which of course would be very slow.

While a native build takes around 20-30 minutes to complete for the
native CPU, performing the same build for the other CPU type using
an emulator takes about 4-5 hours.

The total build time for both distributions and architectures would
be around 10 hours.

OpenLink already builds and tests Virtuoso Open Source on a number
of platforms to ensure our software works using different versions
of operating systems, development tools and libraries.

This is the equivalent of the "vos-build" steps in this reference
`Dockerfile`.

These builds are performed in parallel on separate native platforms
and a tarball with the binary installation is stored on an internal
server.

Our docker build process then downloads the relevant 4 builds to
one location, extracts them and uses the `COPY` command exactly
like the second part of this Dockerfile.


## See Also
  * [License](LICENSE.md)
  * [Copying](COPYING.md)
  * [OpenLink repository on Docker Hub](https://hub.docker.com/repository/docker/openlink/virtuoso-opensource-7/general)
  * [Virtuoso Docker Reference Guide](https://community.openlinksw.com/t/virtuoso-enterprise-edition-reference-guide-for-docker-deployment/286)
  * [How to Bulkload data into a Virtuoso docker instance](https://community.openlinksw.com/t/how-to-bulk-load-data-into-a-virtuoso-docker-instance/3248)
