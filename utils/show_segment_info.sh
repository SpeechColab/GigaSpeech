#!/usr/bin/env bash

. env_vars.sh

# need `jq` installed, refer to utils/install_jq.sh if you don't have it
if [ $# -eq 1 ]; then
  cat $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json | jq --arg query_uuid "$1" '.audios[].segments[] | select(.uuid == $query_uuid)'
else
  echo "usage: $0 <segment_uuid>"
fi