#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)

# Aliyun official Command Line Interface(CLI) for oss storage service. It is
# open sourced at https://github.com/aliyun/ossutil


set -e
set -o pipefail

[ ! -d tools/downloader ] && mkdir -p tools/downloader

if [ `uname -s` == 'Linux' ]; then
  wget -O tools/downloader/ossutil64 \
    http://gosspublic.alicdn.com/ossutil/1.7.1/ossutil64 || exit 1
  chmod 755 tools/downloader/ossutil64
elif [ `uname -s` == 'Darwin' ]; then
  curl -o tools/downloader/ossutilmac64 \
    http://gosspublic.alicdn.com/ossutil/1.7.1/ossutilmac64 || exit 1
  chmod 755 tools/downloader/ossutilmac64
fi

echo "$0: Done"
