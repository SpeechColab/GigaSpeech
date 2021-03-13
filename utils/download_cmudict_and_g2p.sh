#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-src>"
  echo " e.g.: $0 ~/gigaspeech_data"
  echo ""
  echo "This script downloads the CMU dictionary and its corresponding Sequitur"
  echo "G2P models."
  exit 1
fi


gigaspeech_src=$1

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp ${GIGA_SPEECH_RELEASE_URL}/dict/cmudict.0.7a \
  $gigaspeech_src/dict/cmudict.0.7a || exit 1
$ossbin -c SAFEBOX/aliyun_ossutil.cfg \
  cp -r ${GIGA_SPEECH_RELEASE_URL}/dict/g2p $gigaspeech_src/dict/ || exit 1

echo "$0: Done"
