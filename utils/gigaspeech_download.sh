#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU


set -e
set -o pipefail

stage=0

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech dataset"
  echo "to your local dir<gigaspeech-dataset-local-dir>. "
  echo "We suggest at least 600G of free space under <gigaspeech-dataset-local-dir>."
  exit 1
fi

dir=$1

if [ $stage -le 0 ]; then
  echo "$0: Setting up downloader."
  utils/setup_oss_for_downloading.sh || exit 1
fi

if [ $stage -le 1 ]; then
  # Download the metadata.
  echo "$0: Downloading GigaSpeech.json"
  utils/download_meta.sh $dir || exit 1

  # Download the audio data. Currently it downloads the entire audio collection,
  # but this can be improved to only download a certain part of the collection.
  echo "$0: Downloading the audio collection"
  utils/download_audio.sh $dir || exit 1

  # Download the CMU dictionary and the corresponding G2P model.
  echo "$0: Downloading the CMU dictionary and the corresponding G2P model."
  utils/download_cmudict_and_g2p.sh $dir || exit 1
fi

if [ $stage -le 2 ]; then
  # Verify the data size or md5.
  echo "$0: Checking md5 of downloaded audio files"
  utils/check_audio_md5.sh $dir || exit 1
fi

echo "$0: Done"
