#!/usr/bin/env bash
# this script downloads entire gigaspeech audio files 

[ `uname -s` == 'Linux' ] && ossbin=ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg cp -ur ${GIGA_SPEECH_RELEASE_URL}/audio/ $GIGA_SPEECH_LOCAL_ROOT/audio
