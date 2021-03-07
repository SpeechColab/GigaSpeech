#!/usr/bin/env bash
# Copyright 2021 Yongqing Wang

set -e

. ./env_vars.sh

stage=0

[ ! -d $data_dst ] && mkdir -p $data_dst

if [ $stage -le 0 ]; then
  sh utils/setup_oss_for_downloading.sh
fi

if [ $stage -le 1 ]; then
  # Download meta and audio
  
  sh utils/download_meta.sh
  # this currently download entire dataset, we may improve to support subset downloading
  sh utils/download_audio.sh
fi

if [ $stage -le 2 ]; then
  # Prepare gigaspeech dataset
  
  [ ! -f $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json ] && echo "Please Download GigaSpeech.json first!" && exit 1
  [ ! -d $GIGA_SPEECH_LOCAL_ROOT/audio ] && echo "Please Download audio first!" && exit 1

  # Default: wav.scp utt2spk text and segments are generated
  python utils/prepare_data.py $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $GIGA_SPEECH_LOCAL_ROOT/data/train
fi

if [ $stage -le 3 ]; then
  # Download cmudict and g2p model
  sh utils/download_cmudict_and_g2p.sh
fi
