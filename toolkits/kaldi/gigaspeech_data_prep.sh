#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)

set -e
stage=1

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir> <data-dir> <use-pipe> [<subset-prefix>]"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech data/ true gigaspeech"
  echo ""
  echo "This script takes the GigaSpeech source directory, and prepares the"
  echo "Kaldi format data directory. When <use-pipe> is true, it decodes the"
  echo "OPUS audio format through a pipe; Otherwise it writes the decoded"
  echo "output to wav files. <subset-prefix> is an optional prefix for Kaldi"
  echo "data directories."
  exit 1
fi

gigaspeech_dir=$1
data_dir=$2
use_pipe=$3
prefix=
if [ $# -eq 4 ]; then
  prefix=${3}_
fi

declare -A subsets
subsets=([train]="XL" [dev]="DEV" [test]="TEST")

meta_dir=$data_dir/${prefix}corpus/meta
if [ $stage -le 1 ]; then
  # Sanity check.
  [ ! -f $gigaspeech_dir/GigaSpeech.json ] &&\
    echo "$0: Please download $gigaspeech_dir/GigaSpeech.json!" && exit 1
  [ ! -d $gigaspeech_dir/audio ] &&\
    echo "$0: Please download $gigaspeech_dir/audio!" && exit 1

  [ ! -d $meta_dir ] && mkdir -p $meta_dir

  # Files to be created:
  # wav.scp reco2md5 utt2spk text and segments utt2dur reco2durare
  if [ "$use_pipe" = true ]; then
    python3 utils/analyze_meta.py \
      --pipe-format $gigaspeech_dir/GigaSpeech.json $meta_dir || exit 1
  else
    python3 utils/analyze_meta.py \
      $gigaspeech_dir/GigaSpeech.json $meta_dir || exit 1
    toolkits/kaldi/opus_to_wav.sh --grid-engine $meta_dir/wav.scp || exit 1
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
    tag=${subsets[$subset]}
    grep "{$tag}" $meta_dir/utt2subsets |\
      subset_data_dir.sh --utt-list - \
      $data_dir/${prefix}corpus $data_dir/${prefix}$subset || exit 1
  done
fi

echo "$0: Done"
