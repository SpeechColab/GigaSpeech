#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU

set -e
set -o pipefail

stage=0
with_dict=false

. ./utils/parse_options.sh || exit 1

if [ $# -ne 2 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir> <host>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech tsinghua/speechocean"
  echo ""
  echo "This script downloads the entire GigaSpeech dataset"
  echo "to your local dir <gigaspeech-dataset-dir>. "
  echo "options:"
  echo "  --with-dict true|false(default) download cmudict & g2p model"
  echo "  --stage stage(default 0) specifies from which stage to start with"
  exit 1
fi

gigaspeech_dataset_dir=$1
host=$2

. ./env_vars.sh || exit 1

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
    $gigaspeech_dataset_dir $host || exit 1;
elif [[ "$host" == *speechocean* ]]; then
  # This is for public release, need 1.2T free space
  echo "$0: Downloading from the Speechocean host..."
  utils/internal/download_gigaspeech_from_speechocean.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir $host || exit 1;
else
  echo "$0: Unsupported release URL: $GIGASPEECH_RELEASE_URL"
  exit 1
fi

echo "$0: Done"
