#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e

. ./env_vars.sh || exit 1

stage=0

pipe_format=true
meta_dir=$GIGA_SPEECH_LOCAL_ROOT/data/meta

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
  # Sanity check.
  [ ! -f $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json ] &&\
    echo "$0: Please Download the GigaSpeech.json file!" && exit 1
  [ ! -d $GIGA_SPEECH_LOCAL_ROOT/audio ] &&\
    echo "$0: Please Download the audio collection!" && exit 1

  # Files to be created:
  # wav.scp reco2md5 utt2spk text and segments utt2dur reco2durare
  if $pipe_format; then
    python3 utils/analyze_meta.py \
      --pipe-format $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir || exit 1
  else
    python3 utils/analyze_meta.py \
      $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir || exit 1
    toolkits/kaldi/run_opus2wav.sh --grid-engine $meta_dir/wav.scp || exit 1
  fi
fi

if [ $stage -le 3 ]; then
  # Verify the data size or md5.
  echo "$0: Please add scripts for checking data"
fi

echo "$0: Done"
