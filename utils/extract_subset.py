import sys
import os
import argparse
import json


def get_args():
  parser = argparse.ArgumentParser(description="""
      This script is used to process raw json dataset of GigaSpeech
      to download selected subset.
      """)
  parser.add_argument('subset', type=str, choices=['DEV', 'TEST', 'XL', 'L', 'M', 'S', 'XS'], default='XL', help="""Subset to download""")
  parser.add_argument('input_json', help="""Input json file of Gigaspeech""")
  args = parser.parse_args()
  return args


def meta_analysis(input_json, subset):
    subset_list=['{XS}', '{S}', '{M}', '{L}', '{XL}', '{TEST}', '{DEV}']
    if not os.path.exists(input_json):
        sys.exit(f'Failed to load input json file: {input_json}')
    
    if not os.path.exists('log'):
        os.makedirs('log')
    subset='{'+subset+'}'
    print(subset)
    if subset in subset_list:
        with open(input_json, 'r') as injson:
            json_data = json.load(injson)
            if json_data['audios'] is not None:
                with open(f'log/subset_path', 'w') as subset_path:
                    for long_audio in json_data['audios']:
                        subsets = long_audio['subsets']
                        if subset in subsets:
                            print(subsets)
                            long_audio_path=long_audio['path']
                            subset_path.write(f'{long_audio_path}\n')
    else:
        sys.exit(f'Subset should be XS, S, M, L, XL, DEV, TEST')

def main():
  args = get_args()

  meta_analysis(args.input_json, args.subset)


if __name__ == '__main__':
  main()
