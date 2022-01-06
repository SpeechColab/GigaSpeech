#!/usr/bin/env python3
# coding=utf8
# Copyright 2022  Jiayu DU

import os, sys
import argparse
import csv
from speechcolab.datasets.gigaspeech import GigaSpeech
import torchaudio

gigaspeech_punctuations = ['<COMMA>', '<PERIOD>', '<QUESTIONMARK>', '<EXCLAMATIONPOINT>']
gigaspeech_garbage_utterance_tags = ['<SIL>', '<NOISE>', '<MUSIC>', '<OTHER>']

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Save the audio segments into flac files.')
    parser.add_argument('--subset', choices = ['XS', 'S', 'M', 'L', 'XL', 'DEV', 'TEST'], default='XS', help='The subset name')
    parser.add_argument('gigaspeech_dataset_dir', help='The corpus directory')
    parser.add_argument('dst_dir', help='The dst_dir directory')
    args = parser.parse_args()

    os.makedirs(args.dst_dir, exist_ok = True)

    gigaspeech = GigaSpeech(args.gigaspeech_dataset_dir)
    subset = '{' + args.subset + '}'
    with open(os.path.join(args.dst_dir, 'metadata.tsv'), 'w+', encoding='utf8') as fo:
        csv_header_fields = ['ID', 'AUDIO', 'DURATION', 'TEXT']
        csv_writer = csv.DictWriter(fo, delimiter='\t', fieldnames=csv_header_fields, lineterminator='\n')
        csv_writer.writeheader()
        for audio in gigaspeech.audios(subset):
            aid = audio['aid']
            audio_path = os.path.join(args.gigaspeech_dataset_dir, audio["path"])

            audio_info = torchaudio.info(audio_path)
            opus_sample_rate = audio_info.sample_rate
            assert opus_sample_rate == 48000
            nc = audio_info.num_channels
            assert nc == 1

            sample_rate = 16000
            long_waveform, _ = torchaudio.load(audio_path)
            long_waveform = torchaudio.transforms.Resample(opus_sample_rate, sample_rate)(long_waveform)

            for segment in audio['segments']:
                sid = segment['sid']

                if subset not in segment['subsets']:
                    continue

                text = segment['text_tn']
                for punctuation in gigaspeech_punctuations:
                    text = text.replace(punctuation, '').strip()
                    text = ' '.join(text.split())

                if text in gigaspeech_garbage_utterance_tags:
                    continue

                begin = segment['begin_time']
                duration = segment['end_time'] - segment['begin_time']
                frame_offset = int(begin    * sample_rate)
                num_frames   = int(duration * sample_rate)

                waveform = long_waveform[0][frame_offset : frame_offset + num_frames] # mono

                segment_path = os.path.join('audio', aid, f'{sid}.wav')
                os.makedirs(os.path.join(args.dst_dir, os.path.dirname(segment_path)), exist_ok = True)
                torchaudio.save(
                    os.path.join(args.dst_dir, segment_path),
                    waveform.unsqueeze(0),
                    sample_rate = sample_rate,
                    format = 'wav',
                    encoding = 'PCM_S',
                    bits_per_sample = 16,
                )

                utt = {'ID': segment['sid'], 'AUDIO': segment_path, 'DURATION': f'{duration:.3f}', 'TEXT': text }
                csv_writer.writerow(utt)

