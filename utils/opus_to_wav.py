# Copyright 2021 Xiaomi (Author:Yongqing Wang)

import os
import argparse
import re


def get_args():
  parser = argparse.ArgumentParser(description="""
      This script is used to convert opus file into wav file.""")
  parser.add_argument('--remove-opus', action='store_true', default='False',
      help="""If true, remove opus files""")
  parser.add_argument('opus_scp', help="""Input opus scp file""")
  
  args = parser.parse_args()
  return args


def convert_opus2wav(opus_scp, rm_opus):
  with open(opus_scp, 'r') as oscp:
    for line in oscp:
      line = line.strip()
      utt, opus_path = re.split('\s+', line)
      wav_path = opus_path.replace('.opus', '.wav')
      cmd = f'ffmpeg -y -i {opus_path} -ac 1 -ar 16000 {wav_path}'
      try:
        os.system(cmd)
      except:
        sys.exit(f'Failed to run the cmd: {cmd}')
      if rm_opus is True:
        os.remove(opus_path)


def main():
  args = get_args()
  convert_opus2wav(args.opus_scp, args.remove_opus)


if __name__ == '__main__':
  main()
