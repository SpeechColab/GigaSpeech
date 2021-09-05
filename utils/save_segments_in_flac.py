# Copyright 2021  SpeechColab Authors

import argparse
from pathlib import Path
from importlib.util import find_spec

from speechcolab.datasets.gigaspeech import GigaSpeech

if find_spec('audioread') is not None:
    import audioread
else:
    raise ImportError('Need optional dependency: pip install audioread')

if find_spec('soundfile') is not None:
    import numpy as np
    import soundfile as sf
else:
    raise ImportError('Need optional dependency: pip install soundfile')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Save the audio segments into flac files.')
    parser.add_argument('corpus', help='The corpus directory')
    parser.add_argument('output', help='The output directory')
    parser.add_argument('--subset', default='{XL}', help='The subset name')
    args = parser.parse_args()

    gigaspeech = GigaSpeech(args.corpus)
    for audio in gigaspeech.audios(args.subset):
        output_audio_dir = (Path(args.output) / audio['path']).with_suffix('')
        output_audio_dir.mkdir(parents=True, exist_ok=True)

        with audioread.audio_open(f'{args.corpus}/{audio["path"]}') as input_file:
            data = b''.join(list(input_file.read_data()))
            for seg in audio['segments']:
                sr_native = input_file.samplerate
                sr_target = 16000
                n_channels = input_file.channels
                s_start = int(round(sr_native * 2 * seg['begin_time'])) * n_channels
                duration = seg['end_time'] - seg['begin_time']
                s_end = min(len(data), s_start + (int(round(sr_native * 2 * duration)) * n_channels))
                sf.write(
                    file=str(output_audio_dir / f'{seg["sid"]}.flac'),
                    data=np.frombuffer(data[s_start:s_end:int(sr_native/sr_target)], 'short'),
                    samplerate=sr_target,
                    format='FLAC'
                )
