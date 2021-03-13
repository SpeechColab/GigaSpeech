#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <data-dir> [<subset-prefix>]"
  echo " e.g.: $0 data/ gigaspeech"
  exit 1
fi

data_dir=$1
prefix=
if [ $# -eq 2 ]; then
  prefix=${2}_
fi

stage=1

meta_dir=$GIGA_SPEECH_LOCAL_ROOT/data/meta
declare -A subsets
subsets=([train]="XL" [dev]="DEV" [test]="TEST")

if [ $stage -le 1 ]; then
  # All data.
  [ ! -d $data_dir/${prefix}corpus ] && mkdir -p $data_dir/${prefix}corpus

  for f in utt2spk wav.scp text segments utt2dur reco2dur; do
    [ -f $meta_dir/$f ] && cp $meta_dir/$f $data_dir/${prefix}corpus/
  done

  utt2spk=$data_dir/${prefix}corpus/utt2spk
  spk2utt=$data_dir/${prefix}corpus/spk2utt
  utt2spk_to_spk2utt.pl <$utt2spk >$spk2utt ||\
    (echo "$0: Error: utt2spk to spk2utt" && exit 1)

  # Delete <*> tag
  sed -i '/<MUSIC>/d' $data_dir/${prefix}corpus/text || exit 1
  sed -i '/<NOISE>/d' $data_dir/${prefix}corpus/text || exit 1
  sed -i "s|<[^>]*>||g" $data_dir/${prefix}corpus/text || exit 1
  sed -i 's/[ ][ ]*/ /g' $data_dir/${prefix}corpus/text || exit 1
fi

if [ $stage -le 2 ]; then
  # Split data to train, dev and test.
  [ ! -f $meta_dir/utt2subsets ] &&\
    echo "$0: Error: No such file $meta_dir/utt2subsets!" && exit 1
  for subset in ${!subsets[*]}; do
    [ ! -d $data_dir/${prefix}$subset ] && mkdir -p $data_dir/${prefix}$subset
    tag=${subsets[$subet]}
    grep "{$tag}" $meta_dir/utt2subsets |\
      subset_data_dir.sh --utt-list - \
      $data_dir/${prefix}corpus $data_dir/${prefix}$subset || exit 1
  done
fi

echo "$0: Done"
