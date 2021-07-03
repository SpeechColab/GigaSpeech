#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU

set -e
set -o pipefail

stage=0
with_dict=false

. ./utils/parse_options.sh || exit 1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech dataset"
  echo "to your local dir <gigaspeech-dataset-dir>. "
  echo "options:"
  echo "  --with-dict true|false(default) download cmudict & g2p model"
  echo "  --stage 0|1|2|3|4|5 specifies from which stage to start with"
  echo "    0: env/downloader prepare & check"
  echo "    1: user agreement"
  echo "    2: metadata"
  echo "    3: audio"
  echo "    4: optional dictionary and g2p models"
  echo "    5: md5 check on downloaded audio files"
  exit 1
fi

gigaspeech_dataset_dir=$1

. ./env_vars.sh || exit 1

if [[ "$GIGASPEECH_RELEASE_URL" == oss* ]]; then
  # This is for SpeechColab collaborators, need 600G free space
  utils/internal/download_gigaspeech_from_oss.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir

elif [[ "$GIGASPEECH_RELEASE_URL" == *tsinghua* ]]; then
  # This is for public release, need 1.2T free space
  utils/internal/download_gigaspeech_from_tsinghua.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir

else
  echo "$0: unsupported release URL: $GIGASPEECH_RELEASE_URL"
  exit 1
fi

echo "$0: Done"
