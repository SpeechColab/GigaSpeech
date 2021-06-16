#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)

# Aliyun official Command Line Interface(CLI) for oss storage service. It is
# open sourced at https://github.com/aliyun/ossutil


set -e
set -o pipefail

[ ! -d tools/downloader ] && mkdir -p tools/downloader

if [[ "$GIGA_SPEECH_RELEASE_URL" == oss* ]]; then
  if [ `uname -s` == 'Linux' ]; then
    wget -O tools/downloader/ossutil64 \
      http://gosspublic.alicdn.com/ossutil/1.7.1/ossutil64 || exit 1
    chmod 755 tools/downloader/ossutil64
  elif [ `uname -s` == 'Darwin' ]; then
    curl -o tools/downloader/ossutilmac64 \
      http://gosspublic.alicdn.com/ossutil/1.7.1/ossutilmac64 || exit 1
    chmod 755 tools/downloader/ossutilmac64
  fi

elif [[ "$GIGA_SPEECH_RELEASE_URL" == *tsinghua* ]]; then

  if ! which wget >/dev/null; then
    echo "$0: Error, please make sure you have wget installed."
    exit 1
  fi

  if ! which openssl >/dev/null; then
    echo "$0: Error, please make sure you have wget installed."
    exit 1
  fi

else
  echo "unsupported release URL: $GIGA_SPEECH_RELEASE_URL"
  exit 1
fi

echo "$0: Done"
