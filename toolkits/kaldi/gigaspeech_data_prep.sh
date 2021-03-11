#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)

set -e

. env_vars.sh

if [ $# != 2 ]; then
  echo "Usage: "
  echo "  $0 <meta-dir> <data-dir>"
  exit 1
fi

meta_dir=$1
data_dir=$2

#train
[ ! -d $data_dir/train ] && mkdir -p $data_dir/train

for f in utt2spk wav.scp text segments; do
  [ -f $meta_dir/$f ] && cp $meta_dir/$f $data_dir/train/ || exit 1
done

utt2spk=$data_dir/train/utt2spk
spk2utt=$data_dir/train/spk2utt
utt2spk_to_spk2utt.pl <$utt2spk >$spk2utt || exit 1

#dev

#test
