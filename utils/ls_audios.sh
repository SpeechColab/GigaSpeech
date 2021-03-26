#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script lists all audio files in dataset release."
  exit 1
fi

gigaspeech_dataset_dir=$1

if ! which jq >/dev/null; then
  >&2 echo "$0: You have to get jq installed in order to use this. See"
  >&2 echo "$0: utils/install_jq.sh"
  exit 1
fi

cat $gigaspeech_dataset_dir/GigaSpeech.json \
  | jq -r '.audios[].path' |\
  awk -v prefix="$gigaspeech_dataset_dir" '{print prefix"/"$1}' || exit 1
