#!/bin/bash

set -e
set -o pipefail

if [ `uname -s` == 'Linux' ]; then
  if [ "`grep NAME /etc/os-release | grep Ubuntu`" != "" ] ||\
    [ "`grep NAME /etc/os-release | grep Debian`" != "" ]; then
    apt-get install jq || exit 1
  elif [ "`grep NAME /etc/os-release | grep CentOS`" != "" ]; then
    yum install jq || exit 1
  else
    echo "$0: Unknown platform."
    exit 1
  fi
elif [ `uname -s` == 'Darwin' ]; then
  brew install jq || exit 1
fi

echo "$0: Done"
