
if [ `uname -s` == 'Linux' ]; then
  if [ "`grep "NAME" /etc/os-release | grep Ubuntu`" != "" ] || [ "`grep "NAME" /etc/os-release | grep Debian`" != "" ]; then
    apt-get install jq
  elif [ "`grep NAME /etc/os-release | grep CentOS`" != "" ]
    yum install jq
  else
    echo 'Unknown platform.'; exit -1
  fi
elif [ `uname -s` == 'Darwin' ]; then
  brew install jq
fi