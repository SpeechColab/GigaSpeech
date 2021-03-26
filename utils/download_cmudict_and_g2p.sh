#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the CMU dictionary and its corresponding Sequitur"
  echo "G2P models."
  exit 1
fi

. ./env_vars.sh || exit 1
if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "ERROR: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

gigaspeech_dataset_dir=$1

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -u ${GIGA_SPEECH_RELEASE_URL}/dict/cmudict.0.7a \
  $gigaspeech_dataset_dir/dict/cmudict.0.7a || exit 1
$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -ur ${GIGA_SPEECH_RELEASE_URL}/dict/g2p $gigaspeech_dataset_dir/dict/ || exit 1

echo "$0: Done"
