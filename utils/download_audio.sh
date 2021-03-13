#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-src>"
  echo " e.g.: $0 ~/gigaspeech_data"
  echo ""
  echo "This script downloads the entire GigaSpeech audio collection. We"
  echo "suggest having at least 900G of free space under <gigaspeech-src>."
  exit 1
fi

gigaspeech_src=$1

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $gigaspeech_src/audio || exit 1

echo "$0: Done"
