#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir> <segment-id>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech POD1000000004_S0000000"
  echo ""
  echo "This script extracts information from GigaSpeech.json for the given"
  echo "segment."
  exit 1
fi

gigaspeech_src=$1
segment_id=$2

if ! which jq >/dev/null; then
  >&2 echo "$0: You have to get jq installed in order to use this. See"
  >&2 echo "$0: utils/install_jq.sh"
  exit 1
fi

cat $gigaspeech_src/GigaSpeech.json |\
  jq --arg query_uuid "$segment_id" \
  '.audios[].segments[] | select(.uuid == $query_uuid)' || exit 1

echo "$0: Done"
