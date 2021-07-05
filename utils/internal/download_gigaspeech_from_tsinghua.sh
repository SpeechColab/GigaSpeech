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
if [ `uname -s` != 'Linux' ] && [ `uname -s` != 'Darwin' ]; then
  echo "$0: The Tsinghua host downloader only supports Linux and Mac OS."
  exit 1
fi

# Check release URL
. ./env_vars.sh || exit 1
if [ -z "${GIGASPEECH_RELEASE_URL}" ]; then
  echo "$0: Error, variable GIGASPEECH_RELEASE_URL (in env_vars.sh) is not set."
  exit 1
fi

# Check credential
if [ ! -f SAFEBOX/password ]; then
  echo "$0: Please apply for the download credentials (see the \"Download\""
  echo "$0: section in README) and it to SAFEBOX/password."
  exit 1
fi
PASSWORD=`cat SAFEBOX/password 2>/dev/null`
if [ -z "$PASSWORD" ]; then
  echo "$0: Error, SAFEBOX/password is empty."
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

openssl_distro=`openssl version | awk '{print $1}'`
required_distro="OpenSSL"
if [[ "$openssl_distro" != "$required_distro" ]]; then
  echo "$0: Unsupported $openssl_distro detected, please use $required_distro"
  echo "$0: On mac, you should try: brew install openssl"
  exit 1
fi

openssl_version=`openssl version|sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/g'`
required_version="1.1.1"
older_version=$(printf "$required_version\n$openssl_version\n"|sort -V|head -n1)
if [[ "$older_version" != "$required_version" ]]; then
  echo "$0: The script requires openssl version $required_version or newer."
  echo "$0: Please download the openssl source code, and install openssl"
  echo "$0: version $required_version"
  exit 1
fi

download_object_from_release() {
  local obj=$1
  echo "$0: Downloading $obj"
  local remote_obj=${GIGASPEECH_RELEASE_URL}/$obj
  local location=$(dirname ${gigaspeech_dataset_dir}/$obj)

  mkdir -p $location
  # -T seconds timeout, -t number of tries
  wget -c -t 20 -T 90 -P $location $remote_obj || exit 1;
}

process_downloaded_object() {
  local obj=$1
  echo "$0: Processing $obj"
  local path=${gigaspeech_dataset_dir}/$obj
  local location=$(dirname $path)

  if [[ $path == *.tgz.aes ]]; then
    # encrypted-gziped-tarball contains contents of a GigaSpeech sub-directory
    local subdir_name=$(basename $path .tgz.aes)
    mkdir -p $location/$subdir_name
    openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path \
      | tar xzf - -C $location/$subdir_name || exit 1;
  elif [[ $path == *.gz.aes ]]; then
    # encripted-gziped object represents a regular GigaSpeech file
    local file_name=$(basename $path .gz.aes)
    mkdir -p $location
    openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path \
      | gunzip -c > $location/$file_name || exit 1;
  else
    # keep the object as it is
    :
  fi
}


# User agreement
if [ $stage -le 0 ]; then
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

# Metadata
if [ $stage -le 1 ]; then
  echo "$0: Start to download GigaSpeech metadata"
  for obj in `grep -v '^#' misc/tsinghua/metadata.list`; do
    download_object_from_release $obj || exit 1;
  done
fi

if [ $stage -le 2 ]; then
  echo "$0: Start to process the downloaded metadata"
  for obj in `grep -v '^#' misc/tsinghua/metadata.list`; do
    process_downloaded_object $obj || exit 1;
  done
fi

# Audio
if [ $stage -le 3 ]; then
  echo "$0: Start to download GigaSpeech cached audio files"
  for audio_source in youtube podcast audiobook; do
    for obj in `grep -v '^#' misc/tsinghua/${audio_source}.list`; do
      download_object_from_release $obj || exit 1;
    done
  done
fi

if [ $stage -le 4 ]; then
  echo "$0: Start to process the downloaded audio files"
  for audio_source in youtube podcast audiobook; do
    for obj in `grep -v '^#' misc/tsinghua/${audio_source}.list`; do
      process_downloaded_object $obj || exit 1;
    done
  done
fi

# Optional dictionary & pretrained g2p model
if [ $with_dict == true ]; then
  if [ $stage -le 5 ]; then
    echo "$0: Start to downloaded dictionary resources"
    for obj in `grep -v '^#' misc/tsinghua/dict.list`; do
      download_object_from_release $obj || exit 1;
    done
  fi

  if [ $stage -le 6 ]; then
    echo "$0: Start to process the downloaded dictionary resources"
    for obj in `grep -v '^#' misc/tsinghua/dict.list`; do
      process_downloaded_object $obj || exit 1;
    done
  fi
fi

# Check audio md5
if [ $stage -le 7 ]; then
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $gigaspeech_dataset_dir || exit 1
fi

echo "$0: Done"
