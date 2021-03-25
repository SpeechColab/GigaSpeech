#!/usr/bin/env bash
# Copyright 2021  Jiayu DU
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script tries to detect errors in the downloaded audio files "
  echo "by comparing your local audio files' md5 with those in GigaSpeech.json"
  exit 1
fi

gigaspeech_dataset_dir=$1

failed=false
utils/ls_md5.sh $gigaspeech_dataset_dir | (while read line; do
  echo $line | md5sum -c --strict --quiet --status 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "$0: md5 verification failed for: \"$line\""
    failed=true
  fi
done

if [ "$failed" = true ]; then
  echo "$0: md5 verification failed, check the above logs."
  exit 1
fi) || exit 1

echo "$0: Done md5 verification."
