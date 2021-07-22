#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Tsinghua University (Author: Shuzhou Chai)

set -e
set -o pipefail

stage=0
with_dict=false

. ./env_vars.sh || exit 1
. ./utils/parse_options.sh || exit 1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech Dataset from Tsinghua host."
  echo "We suggest having at least 1.2T of free space in the target directory."
  echo "If dataset resources are updated, you can re-run this script for "
  echo "incremental download."
  exit 1
fi

gigaspeech_dataset_dir=$1
mkdir -p $gigaspeech_dataset_dir || exit 1;

# Check operating system
if [ `uname -s` != 'Linux' ] && [ `uname -s` != 'Darwin' ]; then
  echo "$0: The Tsinghua host downloader only supports Linux and Mac OS."
  exit 1
fi

# Check release URL
if [ -z "$GIGASPEECH_RELEASE_URL_TSINGHUA" ]; then
  echo "$0: Error, variable GIGASPEECH_RELEASE_URL_TSINGHUA (in env_vars.sh)"
  echo "$0: is not set."
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
  local remote_md5=$1
  local obj=$2
  echo "$0: Downloading $obj remote_md5=$remote_md5"

  local remote_obj=$GIGASPEECH_RELEASE_URL_TSINGHUA/$obj
  local local_obj=${gigaspeech_dataset_dir}/$obj

  local location=$(dirname $local_obj)
  mkdir -p $location || exit 1;

  if [ -f $local_obj ]; then
    local_md5=$(md5 -r $local_obj | awk '{print $1}')
    if [ "$local_md5" == "$remote_md5" ]; then
      echo "$0: Skipping $local_obj, successfully retrieved already."
    else
      echo "$0: $local_obj needs re-downloading due to inconsistent MD5."
      rm $local_obj
      wget -t 20 -T 90 -P $location $remote_obj || exit 1;
    fi
  else
    wget -t 20 -T 90 -P $location $remote_obj || exit 1;
  fi

  echo "$0: $obj Done"
}

process_downloaded_object() {
  local obj=$2
  echo "$0: Processing $obj"
  local path=${gigaspeech_dataset_dir}/$obj
  local location=$(dirname $path)

  if [[ $path == *.tgz.aes ]]; then
    # encrypted-gziped-tarball contains contents of a GigaSpeech sub-directory
    local subdir_name=$(basename $path .tgz.aes)
    mkdir -p $location/$subdir_name || exit 1;
    openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path |\
      tar xzf - -C $location/$subdir_name || exit 1;
  elif [[ $path == *.gz.aes ]]; then
    # encripted-gziped object represents a regular GigaSpeech file
    local file_name=$(basename $path .gz.aes)
    mkdir -p $location || exit 1;
    openssl aes-256-cbc -d -salt -pass pass:$PASSWORD -pbkdf2 -in $path |\
      gunzip -c > $location/$file_name || exit 1;
  else
    # keep the object as it is
    :
  fi
}


# User agreement
if [ $stage -le 0 ]; then
  echo "$0: Start to download GigaSpeech user agreement"
  wget -c -P $gigaspeech_dataset_dir \
    $GIGASPEECH_RELEASE_URL_TSINGHUA/TERMS_OF_ACCESS || exit 1;
  GREEN='\033[0;32m'
  NC='\033[0m'       # No Color
  echo -e "${GREEN}"
  echo -e "BY PROCEEDING YOU AGREE TO THE FOLLOWING GIGASPEECH TERMS OF ACCESS:"
  echo -e ""
  echo -e "=============== GIGASPEECH DATASET TERMS OF ACCESS ==============="
  cat $gigaspeech_dataset_dir/TERMS_OF_ACCESS
  echo -e "=================================================================="
  echo -e "$0: GigaSpeech downloading will start in 5 seconds"
  echo -e ""

  for t in $(seq 5 -1 1); do
    echo "$t"
    sleep 1
  done
  echo -e "${NC}"
fi

# Metadata
if [ $stage -le 1 ]; then
  echo "$0: Start to download GigaSpeech metadata"
  grep -v '^#' misc/tsinghua/metadata.list | (while read line; do
    download_object_from_release $line || exit 1;
  done) || exit 1;
fi

if [ $stage -le 2 ]; then
  echo "$0: Start to process the downloaded metadata"
  grep -v '^#' misc/tsinghua/metadata.list | (while read line; do
    process_downloaded_object $line || exit 1;
  done) || exit 1;
fi

# Audio
if [ $stage -le 3 ]; then
  echo "$0: Start to download GigaSpeech cached audio files"
  for audio_source in youtube podcast audiobook; do
    grep -v '^#' misc/tsinghua/${audio_source}.list | (while read line; do
      download_object_from_release $line || exit 1;
    done) || exit 1;
  done
fi

if [ $stage -le 4 ]; then
  echo "$0: Start to process the downloaded audio files"
  for audio_source in youtube podcast audiobook; do
    grep -v '^#' misc/tsinghua/${audio_source}.list | (while read line; do
      process_downloaded_object $line || exit 1;
    done) || exit 1;
  done
fi

# Optional dictionary & pretrained g2p model
if [ $with_dict == true ]; then
  if [ $stage -le 5 ]; then
    echo "$0: Start to downloaded dictionary resources"
    grep -v '^#' misc/tsinghua/dict.list | (while read line; do
      download_object_from_release $line || exit 1;
    done) || exit 1;
  fi

  if [ $stage -le 6 ]; then
    echo "$0: Start to process the downloaded dictionary resources"
    grep -v '^#' misc/tsinghua/dict.list | (while read line; do
      process_downloaded_object $line || exit 1;
    done) || exit 1;
  fi
fi

# Check audio md5
if [ $stage -le 7 ]; then
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $gigaspeech_dataset_dir || exit 1
fi

echo "$0: Done"
