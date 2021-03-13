#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e

. ./env_vars.sh || exit 1

stage=0

if [ $stage -le 0 ]; then
  utils/setup_oss_for_downloading.sh || exit 1
fi

if [ $stage -le 1 ]; then
  # Download the metadata.
  utils/download_meta.sh || exit 1

  # Download the audio data. Currently it downloads the entire audio collection,
  # but this can be improved to only download a certain part of the collection.
  utils/download_audio.sh || exit 1

  # Download the CMU dictionary and the corresponding G2P model.
  utils/download_cmudict_and_g2p.sh || exit 1
fi

if [ $stage -le 2 ]; then
  # Verify the data size or md5.
  echo "$0: Please add scripts for checking data"
fi

echo "$0: Done"
