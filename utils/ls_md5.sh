#!/usr/bin/env bash
# Copyright 2021  SpeechColab Authors


set -e
set -o pipefail

. ./env_vars.sh || exit 1
. ./utils/parse_options.sh || exit 1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script lists md5 for all audio files in dataset"
  echo "can be used in data consistency check"
  exit 1
fi

gigaspeech_dataset_dir=$1

if ! which jq >/dev/null; then
  echo "$0: You have to get jq installed in order to use this."
  utils/install_jq.sh || exit 1
fi

if [ -f $gigaspeech_dataset_dir/GigaSpeech.json ]; then
  cat $gigaspeech_dataset_dir/GigaSpeech.json |\
    jq -r '.audios[] | "\(.md5) \(.path)"' |\
    awk -v prefix="$gigaspeech_dataset_dir" '{print $1" "prefix"/"$2}' || exit 1
else
  >&2 echo "$0: ERROR, couldn't find $gigaspeech_dataset_dir/GigaSpeech.json"
  exit 1
fi
