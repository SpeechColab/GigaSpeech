# Copyright 2021 Xiaomi (Author:Yongqing Wang)

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
  parser.add_argument("input_json", help="Input json file of Gigaspeech")
  parser.add_argument("output_dir", help="Output dir for prepared data")

  args = parser.parse_args()
  return args

def prepare_kaldi_format(input_json, output_dir):
  input_dir = os.path.dirname(input_json)

  if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

  try:
    with open(args.input_json, 'r') as injson:
      json_data = json.load(injson)
  except:
    sys.exit("Failed to load input json file: {0}".format(args.input_json))
  else:
    if json_data["audios"] is not None:
      with open(args.output_dir + '/utt2spk', 'w') as utt2spk, \
            open(args.output_dir + '/text', 'w') as utt2text, \
            open(args.output_dir + '/segments', 'w') as segments, \
            open(args.output_dir + '/wav.scp', 'w') as wavscp:
        for long_audio in json_data["audios"]:
          try:
            long_audio_path = os.path.realpath(os.path.join(input_dir,long_audio["path"]))
            fname, fename = os.path.splitext(long_audio["path"])
            utt = os.path.basename(fname)
            segments_dicts = long_audio["segments"]
            assert(os.path.exists(long_audio_path))
            assert("opus" == long_audio["format"])
            assert("16k" == long_audio["sample_rate"])
          except:
            print("Warning: something is wrong, maybe the error path: {0}".format(long_audio_path))
            continue
          else:
            wavscp.write(utt + '\t' + long_audio_path + '\n')
            for segment_file in segments_dicts:
              try:
                uuid = segment_file["uuid"]
                start_time = segment_file["begin_time"]
                end_time = segment_file["end_time"]
                text =  segment_file["text_tn"]
              except:
                print("Warning: {0} is something error, skipping".format(segment_file))
                continue
              else:
                utt2spk.write(uuid + '\t' + uuid + '\n')
                utt2text.write(uuid + '\t' + text + '\n')
                segments.write(uuid + '\t' + utt + '\t' + start_time + '\t' + end_time + '\n') 

def main():
  args = get_args()

  prepare_kaldi_format(args.input_json, args.output_dir) 

if __name__ == '__main__':
  main()
