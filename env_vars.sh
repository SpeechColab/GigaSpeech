# Download URL.
# Distribution channel 1: Aliyun Object Storage Service, for invited paper collaborators
#export GIGASPEECH_RELEASE_URL=oss://speechcolab/GigaSpeech/release/GigaSpeech

# Distribution Channel 2: Tsinghua Host
#export GIGASPEECH_RELEASE_URL=http://www.tsinghua-ieit.com/dataset/GigaSpeech

# Distribution Channel 3: Haitian Host
#export GIGASPEECH_RELEASE_URL=

# Distribution Channel 4: MagicData Host

# Distribution Channel 5: From IPFS
declare -A GIGASPEECH_RELEASE_URL
GIGASPEECH_RELEASE_URL=([tsinghua]='http://www.tsinghua-ieit.com/dataset/GigaSpeech' [speechocean]='124.207.81.184')
export GIGASPEECH_RELEASE_URL

export PATH=$PWD:$PATH
