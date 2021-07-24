#!/usr/bin/env bash
# Copyright 2021  Jiayu DU
#                 Seasalt AI, Inc (Author: Guoguo Chen)


set -e
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script tries to detect errors in the downloaded meta data "
  echo "by checking the md5 value. You can find the expected md5 value in"
  echo "misc/meta_versions.txt."
  exit 1
fi

gigaspeech_dataset_dir=$1

if [ ! -f $gigaspeech_dataset_dir/GigaSpeech.json ]; then
  echo "$0: Metadata $gigaspeech_dataset_dir/GigaSpeech.json does not exist."
  exit
fi

verified="false"
local_version=$(utils/meta_version.sh $gigaspeech_dataset_dir)
if [[ `uname -s` == "Linux" ]]; then
  if ! which md5sum >/dev/null; then
    echo "$0: Please install md5sum"
    exit 1
  fi
  local_md5=$(md5sum $gigaspeech_dataset_dir/GigaSpeech.json | awk '{print $1}')
elif [[ `uname -s` == "Darwin" ]]; then
  if ! which md5 >/dev/null; then
    echo "$0: Please install md5"
    exit 1
  fi
  local_md5=$(md5 -r $gigaspeech_dataset_dir/GigaSpeech.json | awk '{print $1}')
else
  echo "$0: only supports Linux and Mac OS"
  exit 1
fi

grep -v '^#' misc/meta_versions.txt | (while read line; do
  version=$(echo $line | awk '{print $1}')
  md5=$(echo $line | awk '{print $2}')
  if [[ "$local_version" == "$version" ]]; then
    if [[ "$local_md5" == "$md5" ]]; then
      echo "$0: Successfully verified meta version:$version, md5:$md5"
      verified="true"
    else
      echo "$0: ERROR, $local_version expects md5=$md5, got $local_md5"
      exit 1;
    fi
  fi
done

if [[ "$verified" == "false" ]]; then
  echo "$0: md5 verification failed for unknown version $local_version"
  exit 1
fi) || exit 1;

echo "$0: Done md5 verification."
