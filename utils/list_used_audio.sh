#!/usr/bin/env bash

. env_vars.sh
# need `jq` installed, refer to utils/install_jq.sh if you don't have it
cat $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json | jq -r '.audios[].path'