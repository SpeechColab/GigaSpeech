#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir> <segment-id>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech POD1000000004_S0000000"
  echo ""
  echo "This script extracts information from GigaSpeech.json for the given"
  echo "segment."
  exit 1
fi

gigaspeech_dataset_dir=$1
segment_id=$2

if ! which jq >/dev/null; then
  >&2 echo "$0: You have to get jq installed in order to use this. See"
  >&2 echo "$0: utils/install_jq.sh"
  exit 1
fi

cat $gigaspeech_dataset_dir/GigaSpeech.json |\
  jq --arg query "$segment_id" \
  '.audios[].segments[] | select(.sid == $query)' || exit 1

echo "$0: Done"
