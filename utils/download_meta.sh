#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the GigaSpeech meta file (a.k.a 'GigaSpeech.json)'"
  echo "to your local <gigaspeech-dataset-dir>/GigaSpeech.json."
  echo "Meta file contains audio sources, segmentation information, labels, etc."
  exit 1
fi

. ./env_vars.sh || exit 1
if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "ERROR: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

gigaspeech_dataset_dir=$1

if if [[ "$GIGA_SPEECH_RELEASE_URL" == oss* ]]; then

  [ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
  [ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

  $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
    cp -u ${GIGA_SPEECH_RELEASE_URL}/GigaSpeech.json \
    $gigaspeech_dataset_dir/GigaSpeech.json || exit 1

elif [[ "$GIGA_SPEECH_RELEASE_URL" == *tsinghua* ]]; then

  src=$GIGA_SPEECH_RELEASE_URL/GigaSpeech.json
  dst_dir=$gigaspeech_dataset_dir/
  cmd="wget -c -P $dst_dir $src"
  echo $cmd
  eval $cmd
  
else
  echo "unsupported release URL: $GIGA_SPEECH_RELEASE_URL"
  exit 1
fi

echo "$0: Done"
