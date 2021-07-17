#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU

set -o pipefail

stage=0
with_dict=false
host=

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

. ./env_vars.sh || exit 1

PASSWORD=`cat SAFEBOX/password 2>/dev/null`

test_local_file="GigaSpeech.json.gz.aes"

check_download_speed() {
    file_stat="$(stat $test_local_file)"
    file_size="$(du -sm $test_local_file | cut -f1)"
    rm "$test_local_file"
    speed="$(echo "scale=3; $file_size/20" | bc | awk '{printf "%.3f", $0}' )"
}

if [ -z "$host" ];then
  #check differnet host and choose one with the fastest download speed
  if [ `uname -s` == 'Darwin' ]; then
    alias timeout=gtimeout
  fi

  timeout 20 wget -c -t 20 -T 90 http://www.tsinghua-ieit.com/dataset/GigaSpeech/GigaSpeech.json.gz.aes
  check_download_speed
  tsinghua_speed=$speed
  echo Speed of Tsinghua host is ${tsinghua_speed}MB/s
  
  timeout 20 wget -c  -t 20 -T 90 --ftp-user=GigaSpeech --ftp-password=$PASSWORD \
    ftp://124.207.81.184/GigaSpeech/GigaSpeech.json.gz.aes 
  check_download_speed
  speechocean_speed=$speed
  echo Speed of Speechocean host is ${speechocean_speed}MB/s

  if [ $(echo "$tsinghua_speed > $speechocean_speed" | bc) = 1 ];then
    host=tsinghua
  else
    host=speechocean
  fi
fi

if [[ "$host" == oss* ]]; then
  # This is for SpeechColab collaborators, need 600G free space
  echo "$0: Downloading from the oss host..."
  utils/internal/download_gigaspeech_from_oss.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
elif [[ "$host" == *tsinghua* ]]; then
  # This is for public release, need 1.2T free space
  echo "$0: Downloading from the Tsinghua University host..."
  utils/internal/download_gigaspeech_from_tsinghua.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
elif [[ "$host" == *speechocean* ]]; then
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
