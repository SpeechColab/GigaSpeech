#!/usr/bin/env bash
# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Jiayu DU
#                 Tsinghua University (Author: Shuzhou Chai)

set -e
set -o pipefail

stage=0
with_dict=false

# Support hosts:
# 1. oss
# 2. tsinghua
# 3. speechocean
# 4. magicdata
host=
subset={XL}  # unavailable for oss
download_eval=true

. ./env_vars.sh || exit 1
. ./utils/parse_options.sh || exit 1


if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech dataset"
  echo "to your local dir <gigaspeech-dataset-dir>. "
  echo "options:"
  echo "  --with-dict true|false(default) download cmudict & g2p model"
  echo "  --stage stage(default 0) specifies from which stage to start with"
  echo "  --host tsinghua|speechocean|magicdata|oss specifies the host"
  echo "  --subset subset(default {XL}) specifies the subset to download"
  echo "  --download-eval true(default)|false download {DEV} and {TEST} subsets"
  exit 1
fi

gigaspeech_dataset_dir=$1
mkdir -p $gigaspeech_dataset_dir || exit 1;

# Check credentials.
if [ ! -f SAFEBOX/password ]; then
  echo -n "$0: Please apply for the download credentials (see the \"Download\""
  echo " section in README) and it to SAFEBOX/password."
  exit 1;
fi
PASSWORD=`head -1 SAFEBOX/password | md5sum | cut -d ' ' -f 1 2>/dev/null`
if [[ $PASSWORD != "dfbf0cde1a3ce23749d8d81e492741b8" ]]; then
  echo "$0: Error, invalid SAFEBOX/password."
  exit 1;
fi

# Check downloading tools
if ! which wget >/dev/null; then
  echo "$0: Error, please make sure you have wget installed."
  exit 1
fi

# Set up speed test.
test_local_file="GigaSpeech.json.gz.aes"
check_download_speed() {
  # Downloading for 30 seconds.
  rm -f "/tmp/$test_local_file"
  local duration=30
  eval "$1 &" || exit 1;
  local jobid=$!
  trap "kill $jobid; rm -f /tmp/$test_local_file; exit 1" INT

  # Wait for $duration seconds, but exit if the job finishes earlier.
  for t in `seq 1 $duration`; do
    if ! ps -p $jobid > /dev/null; then
      if [[ -f "/tmp/$test_local_file" ]]; then
        local file_size="$(du -sk /tmp/$test_local_file | cut -f1)"
        rm -f "/tmp/$test_local_file"
        local speed="$(echo "scale=3; $file_size/1024/$duration" | bc)"
        echo "$speed"
        return 0
      else
        echo "0"
        return 0
      fi
    fi
    sleep 1
  done

  # Check if the jobs is still alive, if yes, then kill it.
  if ps -p $jobid > /dev/null; then
    kill $jobid || exit 1;
    # Check file size.
    if [[ -f "/tmp/$test_local_file" ]]; then
      local file_size="$(du -sk /tmp/$test_local_file | cut -f1)"
      rm -f "/tmp/$test_local_file"
      local speed="$(echo "scale=3; $file_size/1024/$duration" | bc)"
      echo "$speed"
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

if [ -z "$host" ];then
  # Default download host.
  host=tsinghua
  speed=0

  # Check all available hosts and choose the fastest one.
  echo "$0: Testing Tsinghua host speed..."
  wget_cmd="wget -c -t 20 -T 90 -P /tmp"
  wget_cmd="$wget_cmd $GIGASPEECH_RELEASE_URL_TSINGHUA/GigaSpeech.json.gz.aes"
  speed=$(check_download_speed "$wget_cmd")
  echo; echo "$0: The Tsinghua host speed: $speed MB/s."; echo;

  echo "$0: Testing speechocean host speed..."
  wget_cmd="wget -c  -t 20 -T 90 -P /tmp"
  wget_cmd="$wget_cmd --ftp-user=GigaSpeech --ftp-password=$PASSWORD"
  wget_cmd="$wget_cmd $GIGASPEECH_RELEASE_URL_SPEECHOCEAN/"
  wget_cmd="${wget_cmd}GigaSpeech.json.gz.aes"
  speechocean_speed=$(check_download_speed "$wget_cmd")
  if [ $(echo "$speed < $speechocean_speed" | bc) = 1 ]; then
    host=speechocean
    speed=$speechocean_speed
  fi
  echo; echo "$0: The speechocean host speed: $speechocean_speed MB/s."; echo;

  echo "$0: Testing Magic Data host speed..."
  wget_cmd="wget -c  -t 20 -T 90 -P /tmp"
  wget_cmd="$wget_cmd $GIGASPEECH_RELEASE_URL_MAGICDATA/GigaSpeech.json.gz.aes"
  magicdata_speed=$(check_download_speed "$wget_cmd")
  if [ $(echo "$speed < $magicdata_speed" | bc) = 1 ]; then
    host=magicdata
    speed=$magicdata_speed
  fi
  echo; echo "$0: The Magic Data host speed: $magicdata_speed MB/s."; echo;

  # Check if there is available host.
  if [ $(echo "$speed == 0" | bc) = 1 ]; then
    echo "$0: All hosts are down..."
    exit 1;
  fi
  echo; echo "$0: Using $host host, speed is $speed MB/s."; echo;
fi

if [[ "$host" == "oss" ]]; then
  # This is for SpeechColab collaborators, need 500G free space
  echo "$0: Downloading from the oss host..."
  utils/internal/download_gigaspeech_from_oss.sh \
    --stage $stage --with-dict $with_dict \
    $gigaspeech_dataset_dir || exit 1;
elif [[ "$host" == "tsinghua" || "$host" == "speechocean" || "$host" == "magicdata" ]]; then
  # This is for public release, need 1.0T free space
  echo "$0: Downloading with PySpeechColab..."
  utils/internal/download_gigaspeech_with_pyspeechcolab.sh \
    --host $host --subset $subset --with-dict $with_dict \
    --download-eval $download_eval \
    $gigaspeech_dataset_dir || exit 1;
else
  echo "$0: Unsupported host: $host"
  exit 1
fi

echo "$0: Done"
