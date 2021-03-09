# this is user-specified directory to store GigaSpeech dataset
export GIGA_SPEECH_RELEASE_URL=oss://speechcolab/GigaSpeech/release/GigaSpeech
export GIGA_SPEECH_LOCAL_ROOT=/Users/jerry/work/git/GigaSpeech # this path needs to have at least XXX G free space

export PATH=$PATH:$PWD/toolkits/kaldi
# You'll want to change this if you're not on the Xiaomi's grid.
export cmd="queue.pl -q w1v6.q,cpu.q --mem 2G"
#export cmd="run.pl"
export nj=300
