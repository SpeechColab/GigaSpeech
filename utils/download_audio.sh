#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech audio collection. We"
  echo "suggest having at least 600G of free space under <gigaspeech-dataset-local-dir>."
  exit 1
fi

dir=$1

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $dir/audio || exit 1

echo "$0: Done"
