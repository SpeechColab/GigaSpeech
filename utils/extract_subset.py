import sys
import os
import argparse
import json


def get_args():
    parser = argparse.ArgumentParser(description="""
      This script is used to process raw json dataset of GigaSpeech
      to download selected subset.
      """)
    parser.add_argument('subset', type=str, choices=[
                        'DEV', 'TEST', 'XL', 'L', 'M', 'S', 'XS'], default='XL', help="""Subset to download""")
    parser.add_argument('input_json', help="""Input json file of Gigaspeech""")
    parser.add_argument(
        'subset_path', help="""Output file with subset path of Gigaspeech""")
    args = parser.parse_args()
    return args


def meta_analysis(input_json, subset, subset_path):
    if not os.path.exists(input_json):
        sys.exit(f'Failed to load input json file: {input_json}')

    subset = '{' + subset + '}'
    with open(input_json, 'r') as injson:
        json_data = json.load(injson)
        if json_data['audios'] is not None:
            with open(subset_path, 'w') as f:
                for long_audio in json_data['audios']:
                    subsets = long_audio['subsets']
                    if subset in subsets:
                        long_audio_path = long_audio['path']
                        f.write(f'{long_audio_path}\n')


def main():
    args = get_args()

    meta_analysis(args.input_json, args.subset, args.subset_path)


if __name__ == '__main__':
    main()
