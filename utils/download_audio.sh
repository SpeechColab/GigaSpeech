#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
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

gigaspeech_dataset_dir=$1

if [[ "$GIGA_SPEECH_RELEASE_URL" == oss* ]]; then
  echo "Start to downloading audio from Aliyun OSS"

  [ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
  [ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

  $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
    cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $gigaspeech_dataset_dir/audio || exit 1

elif [[ "$GIGA_SPEECH_RELEASE_URL" == *tsinghua* ]]; then

  echo "Start to downloading audio from Tsinghua Host"

  [ `uname -s` != 'Linux' ] && echo "Linux supported only" && exit 1
  [ ! -f SAFEBOX/password ] && echo "SAFEBOX/password required" && exit 1

  PASSWORD=`cat SAFEBOX/password 2>/dev/null`
  [ -z "$PASSWORD" ] && echo "SAFEBOX/password is empty?" && exit 1

  for domain in youtube podcast audiobook; do
    for part in `cat list/${domain}.list | grep -v '#'`; do
      part_dir=$gigaspeech_dataset_dir/$part
      mkdir -p $part_dir

      cmd="wget -c -P $(dirname $part_dir) ${GIGA_SPEECH_RELEASE_URL}/${part}.tgz.aes"
      echo $cmd
      eval $cmd
      
      cmd="openssl aes-256-cbc -d -salt -k $PASSWORD -pbkdf2 -in ${part_dir}.tgz.aes | tar xzf - -C $part_dir"
      echo $cmd
      eval $cmd
    done
  done

else
  echo "unsupported release URL: $GIGA_SPEECH_RELEASE_URL"
  exit 1
fi

echo "$0: Done"
