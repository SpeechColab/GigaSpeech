#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script lists all audio files in dataset release."
  exit 1
fi

gigaspeech_dataset_local_dir=$1

if ! which jq >/dev/null; then
  echo "$0: You have to get jq installed in order to use this. See"
  echo "$0: utils/install_jq.sh"
  exit 1
fi

cat $gigaspeech_dataset_local_dir/GigaSpeech.json \
  | jq -r '.audios[].path' || exit 1
