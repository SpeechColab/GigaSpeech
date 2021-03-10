#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)

# This script untar opus audio into wav, and please run kaldi path.sh first.
set -e

. env_vars.sh

remove_opus=
if [ "$1" == --remove-opus ]; then
  remove_opus='--remove-opus'
  shift
fi

grid_engine=false
if [ "$1" == --grid-engine ]; then
  grid_engine=true
  shift
fi

if [ $# != 1 ]; then
   echo "Usage: "
   echo "  $0 [--remove-opus] [--grid-engine] <opus-scp>"
   exit 1
fi

wav_scp=$1

stage=1

dir=`dirname $wav_scp`
file_name=`basename $wav_scp`

if [ $stage -le 1 ]; then
  #split scp
  for n in `seq $nj`; do
    mkdir -p $dir/split${nj}/$n
    split_data+=`echo "$dir/split${nj}/$n/$file_name "`
  done
  split_scp.pl $wav_scp $split_data
fi

if [ $stage -le 2 ]; then
  #opus2wav
  echo -e "===START convet opus to wav|current time : `date +%Y-%m-%d-%T`==="
  if $grid_engine:
    $cmd JOB=1:$nj $dir/log/opus2wav.JOB.log \
             python3 utils/opus2wav.py $remove_opus $dir/split${nj}/JOB/$file_name
  else:
    for n in `seq $nj`; do
    (
      python3 utils/untar_opus2wav.py $remove_opus $dir/split${nj}/$n/$file_name
    ) &
    done

  sed -i 's|.opus|.wav|' $wav_scp
  echo -e "===END convet opus to wav|current time : `date +%Y-%m-%d-%T`==="
fi
