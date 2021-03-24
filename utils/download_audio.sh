#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech audio collection. We"
  echo "suggest having at least 600G of free space in local dir."
  echo "If audios are updated, you can just re-run this script for "
  echo "incremental downloading, downloader will only download updates"
  echo "After downloading, you may run utils/check_audio_consistency.sh"
  echo "to make sure everything is consistent with official release."
  exit 1
fi

. ./env_vars.sh || exit 1
if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "ERROR: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

dir=$1

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $dir/audio || exit 1

echo "$0: Done"
