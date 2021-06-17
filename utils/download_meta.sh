#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the GigaSpeech meta file (a.k.a 'GigaSpeech.json)'"
  echo "to your local <gigaspeech-dataset-dir>/GigaSpeech.json."
  echo "Meta file contains audio sources, segmentation information, labels, etc."
  exit 1
fi

. ./env_vars.sh || exit 1
if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "ERROR: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

gigaspeech_dataset_dir=$1

if ! which wget >/dev/null; then
  echo "$0: Error, please make sure wget is installed."
  exit 1
fi

wget -c -P $gigaspeech_dataset_dir $GIGA_SPEECH_RELEASE_URL/GigaSpeech.json

echo "$0: Done"
