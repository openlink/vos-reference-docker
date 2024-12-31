#
#  Dockerfile
#
#  Creating a reference Docker image
#
#  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
#  project.
#
#  Copyright (C) 2018-2023 OpenLink Software
#
#  This project is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; only version 2 of the License, dated June 1991.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#


#
#  By default use Ubuntu Noble Numbat (24.04) LTS
#
ARG OS_IMAGE=ubuntu:noble


# ======================================================================
#  Setup the development image for building VOS
# ======================================================================
FROM $OS_IMAGE as vos_build


#  From build.sh
ARG GIT_TAG
ARG TARGETPLATFORM


#
#  Versions of various required packages
#
ENV PROJ_VERSION=4.9.3
ENV GEOS_VERSION=3.5.1


#
#  Build environment
#
ENV VIRTUOSO_HOME	/opt/virtuoso-opensource
ENV LC_ALL		C.UTF-8
ENV DEBIAN_FRONTEND	noninteractive
ENV MAKE_FLAGS         -j4

#
#  Update the repository
#
RUN     apt-get update && apt upgrade -y


#
#  Development tools
#
RUN     apt-get install -y \
                build-essential \
                autoconf \
                automake \
                bison \
                flex \
                gawk \
                git \
                gperf \
                iproute2 \
                libtool \
                m4 \
                make \
                openssl \
                python3


#
#  Development libraries
#
RUN     apt-get install -y \
                libbz2-dev \
                libedit-dev \
                libldap2-dev \
                libssl-dev \
                lzma-dev 

#
#  Needed for the testsuite
#
RUN     apt-get install -y \
                curl \
                gzip \
                tar \
                unzip \
                wget

#
#  Download/build PROJ4
#
WORKDIR /src
RUN     curl "https://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz" | tar -xzC /src \
        && cd /src/proj-$PROJ_VERSION \
        && ./configure \
               --prefix=/usr/local \
               --disable-shared \
               --with-pic \
               --without-jni \
        && make "$MAKE_FLAGS" all \
        && make install


#
#  Download/build GEOS
#
WORKDIR /src
RUN    curl "https://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2" | tar -xjC /src \
       && cd /src/geos-$GEOS_VERSION \
       && ./configure \
               --prefix=/usr/local \
               --disable-shared \
               --with-pic \
       && make "$MAKE_FLAGS" all \
       && make install


#
#  Workdir for the build
#
WORKDIR /src/virtuoso-opensource
RUN     git init -q . \
	&& git remote add origin "https://github.com/openlink/virtuoso-opensource" \
	&& git fetch -q --depth 1 origin "$GIT_TAG" \
	&& git checkout -q FETCH_HEAD \
        && ./autogen.sh \
        && ./configure \
                --prefix="$VIRTUOSO_HOME" \
                --with-layout=openlink \
                --with-pthreads \
                --enable-fct-vad \
                --enable-dbpedia-vad \
                --enable-conductor-vad \
                --enable-isparql-vad \
                --enable-geos=/usr/local \
                --enable-proj4=/usr/local \
                --enable-shapefileio \
        && make "$MAKE_FLAGS" all \
        && make check || true \
        && make install \
        && mkdir "$VIRTUOSO_HOME"/installer \
        && mv "$VIRTUOSO_HOME"/database/virtuoso.ini "$VIRTUOSO_HOME"/installer/virtuoso.ini.sample \
        && rm -f "$VIRTUOSO_HOME"/lib/*.a \
        && rm -f "$VIRTUOSO_HOME"/lib/*.la \
        && rm -f "$VIRTUOSO_HOME"/hosting/*.a \
        && rm -f "$VIRTUOSO_HOME"/hosting/*.la


#
#  Copy the entrypoint script
#
COPY ./virtuoso-entrypoint.sh "$VIRTUOSO_HOME"/bin


# ======================================================================
#  Build the reference image
# ======================================================================

#
#  Setup the runtime image
#
FROM $OS_IMAGE


#
#  Arguments from build.sh
#
ARG DOCKER_TAG
ARG GIT_TAG
ARG OS_IMAGE
ARG TARGETPLATFORM


#
#  Global environment for the docker image
#
ENV DOCKER_TAG		"$DOCKER_TAG/$GIT_TAG"
ENV VIRTUOSO_HOME       /opt/virtuoso-opensource
ENV PATH                $VIRTUOSO_HOME/bin:$PATH
ENV TERM                xterm


#
#  Labels
#
LABEL   com.openlinksw.vendor="OpenLink Software"
LABEL   maintainer="OpenLink Support <support@openlinksw.com>"
LABEL   copyright="Copyright (C) 2023 OpenLink Software"
LABEL   version="$DOCKER_TAG/$GIT_TAG"
LABEL   description="OpenLink Virtuoso Open Source Edition ($GIT_TAG) -- Docker Image (Ubuntu/$TARGETPLATFORM)"
LABEL   docker_tag="$DOCKER_TAG"


#
#  Update the OS with all the runtime packages Virtuoso requires
#
RUN     apt-get         update \
        && apt-get      install -y ca-certificates less openssl pwgen wget netcat-traditional nano libedit2 libldap2 \
        && apt-get      remove --purge -y \
        && apt-get      autoremove -y \
        && apt-get      autoclean \
        && rm -rf       /var/lib/apt/* \
        && /usr/sbin/useradd virtuoso                                   \
                --system                                                \
                --no-log-init                                           \
                --create-home                                           \
                --user-group                                            \
                --home-dir "$VIRTUOSO_HOME"                             \
                --shell  /bin/bash                                      \
        && mkdir -p "$VIRTUOSO_HOME"/database                           \
        && mkdir -p "$VIRTUOSO_HOME"/settings                           \
        && mkdir -p "$VIRTUOSO_HOME"/initdb.d                           \
        && ln -s "$VIRTUOSO_HOME"/database /database                    \
        && ln -s "$VIRTUOSO_HOME"/settings /settings                    \
        && ln -s "$VIRTUOSO_HOME"/initdb.d /initdb.d                    \
        && ln -s "$VIRTUOSO_HOME"/bin/virtuoso-entrypoint.sh  /         \
        && chown -R virtuoso:virtuoso "$VIRTUOSO_HOME"


#
#  Install Virtuoso Open Source 7.x
#
COPY --from=vos_build "$VIRTUOSO_HOME" "$VIRTUOSO_HOME"


#
#  Default directory
#
VOLUME  [ "/database" ]
WORKDIR /database


#
#  The TCP ports that Virtuoso uses
#
EXPOSE  1111/tcp
EXPOSE  8890/tcp


#
#  Use SIGINT to gracefully stop this image
#
STOPSIGNAL      SIGINT


#
#  Wrapper
#
ENTRYPOINT [ "/virtuoso-entrypoint.sh" ]


#
#  Default command is start
#
CMD ["start"]
