#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)

set -e

. ./env_vars.sh

stage=0

pipe_format=true
meta_dir=$GIGA_SPEECH_LOCAL_ROOT/data/meta

if [ $stage -le 0 ]; then
  utils/setup_oss_for_downloading.sh
fi

if [ $stage -le 1 ]; then
  # Download meta and audio
  utils/download_meta.sh
  # this currently download entire dataset, we may improve to support subset downloading
  utils/download_audio.sh

  # Download cmudict and g2p model
  utils/download_cmudict_and_g2p.sh
fi


if [ $stage -le 2 ]; then
  # Analyze meta
  
  [ ! -f $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json ] && echo "Please Download GigaSpeech.json first!" && exit 1
  [ ! -d $GIGA_SPEECH_LOCAL_ROOT/audio ] && echo "Please Download audio first!" && exit 1

  # Default: wav.scp audio2md5 utt2spk text and segments utt2dur are generated
  if $pipe_format; then
    python3 utils/analyze_meta.py --pipe-format $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir
  else
    python3 utils/analyze_meta.py $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir
    toolkits/kaldi/run_opus2wav.sh --grid-engine $meta_dir/wav.scp
  fi
fi

if [ $stage -le 3 ]; then
  #Check data size or md5
  echo "Please add scripts for checking data"
fi
