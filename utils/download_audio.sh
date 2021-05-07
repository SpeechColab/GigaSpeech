#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Tsinghua University (Author: Shuzhou Chai)

set -e
set -o pipefail


subset=XL
gigaSpeech_meta=

. ./utils/parse_options.sh || exit 1;

if [ $# -ne 1 ]; then
  echo "Usage: $0 [options] <gigaspeech-dataset-dir>"
  echo " e.g.: $0 --subset XL --gigaSpeech_meta /disk1/audio_data/gigaspeech/GigaSpeech.json"
  echo " /disk1/audio_data/gigaspeech "
  echo ""
  echo "This script downloads the entire GigaSpeech audio collection. We"
  echo "suggest having at least 600G of free space in local dir."
  echo "If audios are updated, you can just re-run this script for "
  echo "incremental downloading, downloader will only download updates"
  echo "You may choose a specific subset to download, including XS, S,"
  echo "M, L, XL, DEV, TEST and the default subset is XL."
  echo "After downloading, you may run utils/check_audio_consistency.sh"
  echo "to make sure everything is consistent with official release."
  exit 1
fi

. ./env_vars.sh || exit 1;


if [ -z "${GIGA_SPEECH_RELEASE_URL}" ]; then
  echo "ERROR: env variable GIGA_SPEECH_RELEASE_URL is empty(check env_vars.sh?)"
  exit 1
fi

gigaspeech_dataset_dir=$1

if [ -z "$gigaSpeech_meta" ]; then
  gigaSpeech_meta=$gigaspeech_dataset_dir/GigaSpeech.json
fi

[ `uname -s` == 'Linux' ] && ossbin=tools/downloader/ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=tools/downloader/ossutilmac64

if [ "$subset" == "XL" ]; then
  $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
    cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $gigaspeech_dataset_dir/audio/ || exit 1
else
  python3 utils/extract_subset.py \
    $subset $gigaSpeech_meta $gigaspeech_dataset_dir/subset_path_${subset} || exit ;
  for line in `cat $gigaspeech_dataset_dir/subset_path_${subset}`; do
    $ossbin -c SAFEBOX/aliyun_ossutil.cfg \
      cp -ur ${GIGA_SPEECH_RELEASE_URL}/$line $gigaspeech_dataset_dir/$line || exit 1
  done
fi

echo "$0: Done"
