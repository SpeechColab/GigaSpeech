#!/usr/bin/env bash
# Copyright 2021  Jiayu DU

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script tries to detect errors in the downloaded audio files "
  echo "by comparing your local audio files' md5 with those in GigaSpeech.json"
  exit 1
fi

gigaspeech_dataset_dir=$1

utils/ls_md5.sh $gigaspeech_dataset_dir |\
  md5sum -c - || exit 1
echo "$0: Done md5 checking"
