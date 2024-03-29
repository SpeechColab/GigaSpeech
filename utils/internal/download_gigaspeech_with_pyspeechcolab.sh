#!/usr/bin/env bash
# Copyright 2021  Jiayu Du
#                 Seasalt AI, Inc (Author: Guoguo Chen)
#                 Tsinghua University (Author: Shuzhou Chai)
#                 Xiaomi Corporation (Author: Junbo Zhang)

set -e
set -o pipefail

with_dict=false
host=tsinghua
subset={XL}
download_eval=true

. ./utils/parse_options.sh || exit 1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <gigaspeech-dataset-dir>"
  echo " e.g.: $0 /disk1/audio_data/gigaspeech"
  echo ""
  echo "This script downloads the entire GigaSpeech Dataset from Tsinghua host."
  echo "We suggest having at least 1.0T of free space in the target directory."
  echo "If dataset resources are updated, you can re-run this script for "
  echo "incremental download."
  exit 1
fi

gigaspeech_dataset_dir=$1
mkdir -p $gigaspeech_dataset_dir || exit 1;

# Check dependency
python3 -c "import speechcolab" 2> /dev/null || \
  (echo "$0: This recipe needs the package speechcolab installed.";
   echo "To install:"
   echo "    pip install speechcolab"; exit 1)

# Check credential
if [ ! -f SAFEBOX/password ]; then
  echo "$0: Please apply for the download credentials (see the \"Download\""
  echo "$0: section in README) and it to SAFEBOX/password."
  exit 1
fi
PASSWORD=`cat SAFEBOX/password 2>/dev/null`
if [ -z "$PASSWORD" ]; then
  echo "$0: Error, SAFEBOX/password is empty."
  exit 1
fi

# false -> False, true -> True
with_dict=$(echo $with_dict | sed "s/\b\(.\)/\u\1/g")

# Download with PySpeechColab
python3 << END
from speechcolab.datasets.gigaspeech import GigaSpeech
gigaspeech = GigaSpeech('$gigaspeech_dataset_dir')
if '$download_eval' and '$subset' != '{DEV}' and '$subset' != '{TEST}':
    gigaspeech.download('$PASSWORD', subset='{DEV}', host='$host', with_dict=$with_dict)
    gigaspeech.download('$PASSWORD', subset='{TEST}', host='$host', with_dict=$with_dict)
gigaspeech.download('$PASSWORD', subset='$subset', host='$host', with_dict=$with_dict)
END


echo "$0: Done"
