
if [ `uname -s` == 'Linux' ]; then
  # this only works for Debian & Ubuntu for now
  sudo apt-get install jq
elif [ `uname -s` == 'Darwin' ]; then
  brew install jq
fi