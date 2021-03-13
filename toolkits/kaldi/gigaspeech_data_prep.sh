#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <use-pipe> <data-dir> [<subset-prefix>]"
  echo " e.g.: $0 true data/ gigaspeech"
  exit 1
fi

use_pipe=$1
data_dir=$2
prefix=
if [ $# -eq 3 ]; then
  prefix=${3}_
fi

stage=1

declare -A subsets
subsets=([train]="XL" [dev]="DEV" [test]="TEST")

meta_dir=$data_dir/${prefix}corpus/meta
if [ $stage -le 1 ]; then
  # Sanity check.
  [ ! -f $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json ] &&\
    echo "$0: Please Download the GigaSpeech.json file!" && exit 1
  [ ! -d $GIGA_SPEECH_LOCAL_ROOT/audio ] &&\
    echo "$0: Please Download the audio collection!" && exit 1

  [ ! -d $meta_dir ] && mkdir -p $meta_dir

  # Files to be created:
  # wav.scp reco2md5 utt2spk text and segments utt2dur reco2durare
  if [ "$use_pipe" = true ]; then
    python3 utils/analyze_meta.py \
      --pipe-format $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir || exit 1
  else
    python3 utils/analyze_meta.py \
      $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json $meta_dir || exit 1
    toolkits/kaldi/run_opus2wav.sh --grid-engine $meta_dir/wav.scp || exit 1
  fi
fi

if [ $stage -le 2 ]; then
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

if [ $stage -le 3 ]; then
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
