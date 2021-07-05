#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e
set -o pipefail

stage=0
with_dict=false

. ./utils/parse_options.sh || exit 1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech Dataset from Aliyun."
  echo "This tool is used for our collaborator, not for public users."
  echo "We suggest having at least 600G of free space in local dir."
  echo "If dataset resources are updated, you can just re-run this script for "
  echo "incremental downloading, downloader will only download updates"
  exit 1
fi

gigaspeech_dataset_dir=$1

. ./env_vars.sh || exit 1
if [ -z "${GIGASPEECH_RELEASE_URL}" ]; then
  echo "$0: Error, variable GIGASPEECH_RELEASE_URL(in env_vars.sh) is empty."
  exit 1
fi

if [ ! -f SAFEBOX/aliyun_ossutil.cfg ]; then
  echo "$0: Error, make sure you have: SAFEBOX/aliyun_ossutil.cfg"
  exit 1
fi

# install downloader (Official client for ALIYUN Objects-Storage-Service)
ossbin=tools/downloader/oss
if [ $stage -le 0 ]; then
  [ ! -d tools/downloader ] && mkdir -p tools/downloader
  if [ `uname -s` == 'Linux' ]; then
    wget -O $ossbin \
      http://gosspublic.alicdn.com/ossutil/1.7.1/ossutil64 || exit 1
  elif [ `uname -s` == 'Darwin' ]; then
    curl -o $ossbin \
      http://gosspublic.alicdn.com/ossutil/1.7.1/ossutilmac64 || exit 1
  fi
  chmod 755 $ossbin
fi

if [ $stage -le 1 ]; then
  echo "$0: Skip downloading TERM_OF_ACCESS, our co-authors don't need this"
fi

# Download metadata
if [ $stage -le 2 ]; then
  echo "$0: Start to download GigaSpeech Metadata"
  $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
    cp -u ${GIGASPEECH_RELEASE_URL}/GigaSpeech.json $gigaspeech_dataset_dir/ || exit 1
fi

# Download audio
if [ $stage -le 3 ]; then
  echo "$0: Start to download GigaSpeech cached audio collection"
  $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
    cp -ur ${GIGASPEECH_RELEASE_URL}/audio/ $gigaspeech_dataset_dir/audio || exit 1
fi

# Download optional dictionary and pretrained g2p model
if [ $stage -le 4 ]; then
  if [ $with_dict == true ]; then
    $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
      cp -u ${GIGASPEECH_RELEASE_URL}/dict/cmudict.0.7a \
      $gigaspeech_dataset_dir/dict/cmudict.0.7a || exit 1
    $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
      cp -ur ${GIGASPEECH_RELEASE_URL}/dict/g2p $gigaspeech_dataset_dir/dict/ || exit 1
  fi
fi

# Check audio md5
if [ $stage -le 5 ]; then
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $gigaspeech_dataset_dir || exit 1
fi

echo "$0: Done"
