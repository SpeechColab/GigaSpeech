#!/usr/bin/env bash
# this script downloads GigaSpeech meta file(aka GigaSpeech.json),
# containing audio sources, segmentation info, labels ... 

[ `uname -s` == 'Linux' ]  && ossbin=ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg  cp  ${GIGA_SPEECH_RELEASE_URL}/GigaSpeech.json  $GIGA_SPEECH_LOCAL_ROOT/GigaSpeech.json
