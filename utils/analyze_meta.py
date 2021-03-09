# Copyright 2021  Xiaomi Corporation (Author: Yongqing Wang)

import sys
import os
import argparse
import json


def get_args():
  parser = argparse.ArgumentParser(description="""
      This script is used to process raw json dataset of GigaSpeech,
      where the long wav is splitinto segments and
      data of kaldi format is generated.
      """)
  parser.add_argument('--pipe-format', action='store_true', default='False',
      help="""If true, wav.scp is generated with pipeline format""")
  parser.add_argument('input_json', help="""Input json file of Gigaspeech""")
  parser.add_argument('output_dir', help="""Output dir for prepared data""")

  args = parser.parse_args()
  return args


def meta_analysis(input_json, output_dir, pipe):
  input_dir = os.path.dirname(input_json)

  if not os.path.exists(output_dir):
    os.makedirs(output_dir)

  try:
    with open(input_json, 'r') as injson:
      json_data = json.load(injson)
  except:
    sys.exit(f'Failed to load input json file: {input_json}')
  else:
    if json_data['audios'] is not None:
      with open(f'{output_dir}/utt2spk', 'w') as utt2spk, \
           open(f'{output_dir}/text', 'w') as utt2text, \
           open(f'{output_dir}/segments', 'w') as segments, \
           open(f'{output_dir}/wav.scp', 'w') as wavscp, \
           open(f'{output_dir}/file2md5', 'w') as file2md5:
        for long_audio in json_data['audios']:
          try:
            long_audio_path = os.path.realpath(os.path.join(input_dir, long_audio['path']))
            fname, fename = os.path.splitext(long_audio['path'])
            file_utt = os.path.basename(fname)
            md5str = long_audio['md5']
            segments_dicts = long_audio['segments']
            assert(os.path.exists(long_audio_path))
            assert('opus' == long_audio['format'])
            assert('16k' == long_audio['sample_rate'])
          except AssertionError:
            print(f'Warning: {file_utt} something is wrong, maybe AssertionError, skipped')
            continue
          except:
            print(f'Warning: {file_utt} something is wrong, maybe the error path: {long_audio_path}, skipped')
            continue
          else:
            if pipe is True:
              wavscp.write(f'{file_utt}\tffmpeg -i {long_audio_path} -f wav pipe:1 |\n')
            else:
              wavscp.write(f'{file_utt}\t{long_audio_path}\n')
            file2md5.write(f'{file_utt}\t{md5str}\n')
            for segment_file in segments_dicts:
              try:
                uuid = segment_file['uuid']
                start_time = segment_file['begin_time']
                end_time = segment_file['end_time']
                text = segment_file['text_tn']
              except:
                print(f'Warning: {segment_file} something is wrong, skipped')
                continue
              else:
                utt2spk.write(f'{uuid}\t{uuid}\n')
                utt2text.write(f'{uuid}\t{text}\n')
                segments.write(f'{uuid}\t{file_utt}\t{start_time}\t{end_time}\n')


def main():
  args = get_args()

  meta_analysis(args.input_json, args.output_dir, args.pipe_format)


if __name__ == '__main__':
  main()
