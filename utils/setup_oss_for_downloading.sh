# Aliyun official Command Line Interface(CLI) for oss storage service
# it is open sourced at https://github.com/aliyun/ossutil
if [ `uname -s` == 'Linux' ]; then
  wget http://gosspublic.alicdn.com/ossutil/1.7.1/ossutil64
  chmod 755 ossutil64
elif [ `uname -s` == 'Darwin' ]; then
  curl -o ossutilmac64 http://gosspublic.alicdn.com/ossutil/1.7.1/ossutilmac64
  chmod 755 ossutilmac64
fi
