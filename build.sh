#!/bin/bash
#
#  Creating a reference docker image
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
#  Build using a specific git tag, branch or commit id
#
export GIT_TAG=v7.2.14
#export GIT_TAG=develop/7
#export GIT_TAG=ffed4676dfa6df8932b6723d75043fcc8e1bbf61


#
#  By default use Ubuntu Focal Fossa (20.04) LTS
#
export OS_IMAGE=ubuntu:focal


#
#  Build environment
#
export TARGETPLATFORM=$( arch )
export DOCKER_TAG=vos-reference
export LOGFILE="build.log"
export NO_CACHE=${NO_CACHE-""}


#
#  Exit on error
#
#set -x
set -e -o pipefail -o errtrace


#
#  Redirect output to logfile
#
exec 3>&1 4>&2
exec 1>"$LOGFILE" 2>&1


#
#  support function(s)
#
SILENT=${SILENT-0}

ECHO()
{
    echo "$@"
    [ "$SILENT" = "0" ] &&  echo "$@" > /dev/tty
}

TRAPCTRLC()
{
    exec 1>&3

    echo ""
    echo "*** ABORTED: CTRL-C pressed during run"
    echo ""

    exit 1
}

trap "TRAPCTRLC" 2


TRAPERR()
{
   exec 1>&3

   echo ""
   echo "======================================================================"
   echo "*** ERROR:"
   tail -5 "$LOGFILE"
   echo "======================================================================"

   exit 1
}

trap "TRAPERR" ERR


#
#  Build a docker image
#
ECHO "======================================================================"
ECHO "  BUILD STARTED: `date`"
ECHO "======================================================================"

ECHO ""
ECHO " * Building docker image"
ECHO "   (this may take around 20-30 minutes on current hardware)"
time docker build \
	 $NO_CACHE \
	 --progress=plain \
	 --build-arg DOCKER_TAG=$DOCKER_TAG \
	 --build-arg GIT_TAG=$GIT_TAG \
	 --build-arg OS_IMAGE=$OS_IMAGE \
	 --build-arg TARGETPLATFORM=$TARGETPLATFORM \
	 -t $DOCKER_TAG \
	.
ECHO ""

ECHO "======================================================================"
ECHO "  BUILD FINISHED: `date`"
ECHO "======================================================================"



#
#  All done
#
exit 0
