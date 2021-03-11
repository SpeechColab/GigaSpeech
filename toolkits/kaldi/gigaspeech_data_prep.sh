#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)

set -e

if [ $# != 2 ]; then
  echo "Usage: "
  echo "  $0 <meta-dir> <data-dir>"
  exit 1
fi

meta_dir=$1
data_dir=$2

stage=1

declare -A dic_sets
dic_sets=([train]="XL" [dev]="DEV" [test]="TEST")

if [ $stage -le 1 ]; then
  # all corpus
  [ ! -d $data_dir/corpus ] && mkdir -p $data_dir/corpus

  for f in utt2spk wav.scp text segments utt2dur; do
    [ -f $meta_dir/$f ] && cp $meta_dir/$f $data_dir/corpus/ || exit 1
  done

  utt2spk=$data_dir/corpus/utt2spk
  spk2utt=$data_dir/corpus/spk2utt
  utt2spk_to_spk2utt.pl <$utt2spk >$spk2utt || exit 1
fi

if [ $stage -le 2 ]; then
  # train dev test
  [ ! -f $meta_dir/utt2subsets ] && echo "No such file $meta_dir/utt2subsets!" && exit 1
  for sub in ${!dic_sets[*]}; do
    [ ! -d $data_dir/$sub ] && mkdir -p $data_dir/$sub
    tag=${dic_sets[$sub]}
    grep "{$tag}" $meta_dir/utt2subsets | subset_data_dir.sh --utt-list - $data_dir/corpus $data_dir/$sub
  done

fi
