#!/usr/bin/env bash
# this script downloads entire gigaspeech audio files 

[ `uname -s` == 'Linux' ]  && ossbin=ossutil64
[ `uname -s` == 'Darwin' ] && ossbin=ossutilmac64

$ossbin -c SAFEBOX/aliyun_ossutil.cfg  cp ${GIGA_SPEECH_RELEASE_URL}/dict/cmudict.0.7a  $GIGA_SPEECH_LOCAL_ROOT/dict/cmudict.0.7a
$ossbin -c SAFEBOX/aliyun_ossutil.cfg  cp -r ${GIGA_SPEECH_RELEASE_URL}/dict/g2p  $GIGA_SPEECH_LOCAL_ROOT/dict/