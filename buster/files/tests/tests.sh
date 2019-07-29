#!/bin/bash
#
# Shell script to test the Debian Docker image.
#
# Copyright 2016-2019, Frederico Martins
#   Author: Frederico Martins <http://github.com/fscm>
#
# SPDX-License-Identifier: MIT
#
# This program is free software. You can use it and/or modify it under the
# terms of the MIT License.
#

# Variables
DEBIAN_FRONTEND=noninteractive

/bin/echo "=== Docker Build Test ==="

/bin/echo -n "[TEST] Check if apt command is installed... "
dpkg -s apt &>/dev/null
if [[ "$?" -eq "0" ]]; then
  /bin/echo 'OK'
else
  /bin/echo 'Failed'
  exit 1
fi

/bin/echo -n "[TEST] Check package installation with apt... "
apt-get -qq update && apt-get -y -qq install less &>/dev/null && less --help &>/dev/null
if [[ "$?" -eq "0" ]]; then
  /bin/echo 'OK'
else
  /bin/echo 'Failed'
  exit 2
fi

/bin/echo -n "[TEST] Check if debootstrap dir was removed... "
if [[ ! -e /debootstrap ]]; then
  /bin/echo 'OK'
else
  /bin/echo 'Failed'
  exit 3
fi

/bin/echo -n "[TEST] Check if packages are correctly installed... "
MISSING=$(apt-get -qq -s install $(dpkg-query -W -f "\${Package} ") | wc -l)
if [[ "${MISSING}" -eq "0" ]]; then
  /bin/echo 'OK'
else
  /bin/echo 'Failed'
  exit 4
fi

exit 0
