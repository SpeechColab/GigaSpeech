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
mkdir -p $gigaspeech_dataset_dir

# Check operating system
if [ `uname -s` != 'Linux' ]; then
  echo "$0: Tsinghua host supports *linux only*"
  exit 1
fi

# Check release URL
. ./env_vars.sh || exit 1
if [ -z "${GIGASPEECH_RELEASE_URL}" ]; then
  echo "$0: Error, variable GIGASPEECH_RELEASE_URL(in env_vars.sh) is empty."
  exit 1
fi

# Check credential
if [ ! -f SAFEBOX/password ]; then
  echo "$0: Please apply for the credentials (see README) and add it to SAFEBOX/password"
  exit 1
fi
PASSWORD=`cat SAFEBOX/password 2>/dev/null`
if [ -z "$PASSWORD" ]; then
  echo "$0: Error, SAFEBOX/password is empty"
  exit 1
fi

# Check downloading tools
if ! which wget >/dev/null; then
  echo "$0: Error, please make sure you have wget installed."
  exit 1
fi
if ! which openssl >/dev/null; then
  echo "$0: Error, please make sure you have openssl installed."
  exit 1
fi

download_and_process() {
  local obj=$1

  # download object
  echo "$0: downloading $obj"
  local remote_path=${GIGASPEECH_RELEASE_URL}/$obj
  local path=${gigaspeech_dataset_dir}/$obj
  local location=$(dirname $path)
  mkdir -p $location && wget -c -P $location $remote_path

  # post processing (e.g. decryption & decompression)
  echo "$0: processing $obj"
  if [[ $path == *.tgz.aes ]]; then
    # encrypted-gziped-tarball contains contents of a GigaSpeech sub-directory
    local subdir_name=$(basename $path .tgz.aes)
    mkdir -p $location/$subdir_name \
      && openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path \
      | tar xzf - -C $location/$subdir_name
  elif [[ $path == *.gz.aes ]]; then
    # encripted-gziped object represents a regular GigaSpeech file
    local file_name=$(basename $path .gz.aes)
    openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path \
      | gunzip -c > $location/$file_name
  else
    :
  fi
}

# Download agreement
if [ $stage -le 1 ]; then
  echo "$0: Start to download GigaSpeech user agreement"
  wget -c -P $gigaspeech_dataset_dir $GIGASPEECH_RELEASE_URL/TERMS_OF_ACCESS
  echo "=============== GIGASPEECH DATASET TERMS OF ACCESS ==============="
  cat $gigaspeech_dataset_dir/TERMS_OF_ACCESS
  echo "=================================================================="
  echo "$0: GigaSpeech downloading will start in 5 seconds"
  for t in $(seq 5 -1 1); do
    echo "$t"
    sleep 1
  done
fi

# Download metadata
if [ $stage -le 2 ]; then
  echo "$0: Start to download GigaSpeech Metadata"
  for obj in `grep -v '^#' misc/tsinghua/metadata.list`; do
    download_and_process $obj
  done
fi

# Download audio
if [ $stage -le 3 ]; then
  echo "$0: Start to download GigaSpeech cached audio collection"
  for audio_source in youtube podcast audiobook; do
    for obj in `grep -v '^#' misc/tsinghua/${audio_source}.list`; do
      download_and_process $obj
    done
  done
fi

# Download optional dictionary and pretrained g2p model
if [ $stage -le 4 ]; then
  if [ $with_dict == true ]; then
    for obj in `grep -v '^#' misc/tsinghua/dict.list`; do
      download_and_process $obj
    done
  fi
fi

# Check audio md5
if [ $stage -le 5 ]; then
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $gigaspeech_dataset_dir || exit 1
fi

echo "$0: Done"
