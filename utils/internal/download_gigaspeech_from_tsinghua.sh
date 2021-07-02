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
  echo "This script downloads the entire GigaSpeech Dataset from Tsinghua host."
  echo "We suggest having at least 1.2T of free space in local dir."
  echo "If dataset resources are updated, you can just re-run this script for "
  echo "incremental downloading, downloader will only download updates"
  exit 1
fi

gigaspeech_dataset_dir=$1

# Check operating system
if [ `uname -s` != 'Linux' ]; then
  echo "Tsinghua host supports *linux only*"
  exit 1
fi

# Check release URL
. ./env_vars.sh || exit 1
if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "Error: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

# Check credential
if [ ! -f SAFEBOX/password ]; then
  echo "Error: make sure you have download credential: SAFEBOX/password"
  exit 1
fi
PASSWORD=`cat SAFEBOX/password 2>/dev/null`
if [ -z "$PASSWORD" ]; then
  echo "SAFEBOX/password is empty?"
exit 1

# Check downloading tools
if ! which wget >/dev/null; then
  echo "$0: Error, please make sure you have wget installed."
  exit 1
fi
if ! which openssl >/dev/null; then
  echo "$0: Error, please make sure you have openssl installed."
  exit 1
fi

# Download agreement
if [ $stage -le 1 ]; then
  echo "Start to download GigaSpeech user agreement"
  wget -c -P $gigaspeech_dataset_dir $GIGA_SPEECH_RELEASE_URL/TERMS_OF_ACCESS
  echo "=============== GIGASPEECH DATASET TERMS OF ACCESS ==============="
  cat $gigaspeech_dataset_dir/TERMS_OF_ACCESS
  echo "=================================================================="
fi

# Download metadata
if [ $stage -le 2 ]; then
  echo "Start to download GigaSpeech Metadata"
  wget -c -P $gigaspeech_dataset_dir $GIGA_SPEECH_RELEASE_URL/GigaSpeech.json.tgz.aes
  tar -zxf $gigaspeech_dataset_dir/GigaSpeech.json.tgz -C $gigaspeech_dataset_dir/
fi

# Download audio
if [ $stage -le 3 ]; then
  echo "Start to download GigaSpeech cached audio collection"
  for domain in youtube podcast audiobook; do
    for part in `grep -v '^#' misc/${domain}.list`; do
      part_dir=$gigaspeech_dataset_dir/$part
      mkdir -p $part_dir

      cmd="wget -c -P $(dirname $part_dir) ${GIGA_SPEECH_RELEASE_URL}/${part}.tgz.aes"
      echo $cmd
      eval $cmd
      
      cmd="openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in ${part_dir}.tgz.aes | tar xzf - -C $part_dir"
      echo $cmd
      eval $cmd
    done
  done
fi

# Download optional dictionary and pretrained g2p model
if [ $stage -le 4 ]; then
  if [ $with_dict == true ]; then
    cmd="wget -c -P $gigaspeech_dataset_dir ${GIGA_SPEECH_RELEASE_URL}/dict.tgz.aes"
    echo $cmd
    eval $cmd

    mkdir -p $gigaspeech_dataset_dir/dict
    cmd="openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $gigaspeech_dataset_dir/dict.tgz.aes | tar xzf - -C $gigaspeech_dataset_dir/dict"
    echo $cmd
    eval $cmd
  fi
fi

# check audio md5
if [ $stage -le 5 ]; then
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $gigaspeech_dataset_dir || exit 1
fi

echo "$0: Done"
