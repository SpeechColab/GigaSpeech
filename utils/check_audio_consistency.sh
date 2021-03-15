#!/usr/bin/env bash
# Copyright 2021  Jiayu DU

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-local-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script check audio consistency between your download and release"
  echo "by checking your local audios' md5 and their expected md5 in GigaSpeech.json"
  exit 1
fi

gigaspeech_dataset_dir=$1

utils/ls_md5.sh $gigaspeech_dataset_dir > $gigaspeech_dataset_dir/md5.list || exit 1

cd $gigaspeech_dataset_dir
md5sum -c md5.list >& md5_check.log || exit 1
echo "$0: Done md5 consistency checking, log generated in $gigaspeech_dataset_dir/md5_check.log"
cd -
