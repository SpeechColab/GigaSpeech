#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU
#                 Tsinghua University (Author: Shuzhou Chai)

set -e
set -o pipefail

stage=0
with_dict=false

# Support hosts:
# 1. oss
# 2. tsinghua
# 3. speechocean
host=

. ./env_vars.sh || exit 1
. ./utils/parse_options.sh || exit 1


if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech dataset"
  echo "to your local dir <gigaspeech-dataset-dir>. "
  echo "options:"
  echo "  --with-dict true|false(default) download cmudict & g2p model"
  echo "  --stage stage(default 0) specifies from which stage to start with"
  exit 1
fi

gigaspeech_dataset_dir=$1
mkdir -p $gigaspeech_dataset_dir || exit 1;

# Check credentials.
if [ ! -f SAFEBOX/password ]; then
  echo "$0: Please apply for the download credentials (see the \"Download\""
  echo "$0: section in README) and it to SAFEBOX/password."
  exit 1;
fi
PASSWORD=`cat SAFEBOX/password 2>/dev/null`
if [ -z "$PASSWORD" ]; then
  echo "$0: Error, SAFEBOX/password is empty."
  exit 1;
fi

# Check downloading tools
if ! which wget >/dev/null; then
  echo "$0: Error, please make sure you have wget installed."
  exit 1
fi

# Set up speed test.
test_local_file="GigaSpeech.json.gz.aes"
check_download_speed() {
  # Downloading for 30 seconds.
  rm -f "/tmp/$test_local_file"
  local duration=30
  eval "$1 &" || exit 1;
  local jobid=$!
  trap "kill $jobid; rm -f /tmp/$test_local_file; exit 1" INT
  sleep $duration
  kill $jobid || exit 1;

  # Check file size.
  local file_size="$(du -sk /tmp/$test_local_file | cut -f1)"
  rm -f "/tmp/$test_local_file"
  local speed="$(echo "scale=3; $file_size/1024/$duration" | bc)"
  echo "$speed"
}

if [ -z "$host" ];then
  # Check all available hosts and choose the fastest one.
  echo "$0: Testing Tsinghua host speed..."
  wget_cmd="wget -c -t 20 -T 90 -P /tmp"
  wget_cmd="$wget_cmd $GIGASPEECH_RELEASE_URL_TSINGHUA/GigaSpeech.json.gz.aes"
  tsinghua_speed=$(check_download_speed "$wget_cmd")
  echo "$0: Speed of the Tsinghua host is ${tsinghua_speed}MB/s"
  
  echo "$0: Testing speechocean host speed..."
  wget_cmd="wget -c  -t 20 -T 90 -P /tmp"
  wget_cmd="$wget_cmd --ftp-user=GigaSpeech --ftp-password=$PASSWORD"
  wget_cmd="$wget_cmd $GIGASPEECH_RELEASE_URL_SPEECHOCEAN/"
  wget_cmd="${wget_cmd}GigaSpeech.json.gz.aes"
  speechocean_speed=$(check_download_speed "$wget_cmd")
  echo "$0: Speed of the speechocean host is ${speechocean_speed}MB/s"

  if [ $(echo "$tsinghua_speed > $speechocean_speed" | bc) = 1 ];then
    host=tsinghua
  else
    host=speechocean
  fi
fi

if [[ "$host" == "oss" ]]; then
  # This is for SpeechColab collaborators, need 600G free space
  echo "$0: Downloading from the oss host..."
  utils/internal/download_gigaspeech_from_oss.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
elif [[ "$host" == "tsinghua" ]]; then
  # This is for public release, need 1.2T free space
  echo "$0: Downloading from the Tsinghua University host..."
  utils/internal/download_gigaspeech_from_tsinghua.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
elif [[ "$host" == "speechocean" ]]; then
  # This is for public release, need 1.2T free space
  echo "$0: Downloading from the Speechocean host..."
  utils/internal/download_gigaspeech_from_speechocean.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
else
  echo "$0: Unsupported host: $host"
  exit 1
fi

echo "$0: Done"
