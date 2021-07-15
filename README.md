# GigaSpeech
This is the official repository of the GigaSpeech dataset. For details of how we created the dataset, please refer to our Interspeech paper: *"GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio"*. [Preprint available on arxiv](https://arxiv.org/abs/2106.06909).

GigaSpeech version: 1.0.0 (07/05/2021)

## Download
Please fill out the Google Form [here](https://forms.gle/UuGQAPyscGRrUMLq6) and follow the instructions to download the GigaSpeech dataset.

## Leaderboard

| **Contributor**| **Toolkit**       | **Train Recipe**     | **Train Data** | **Inference**     |**Dev/Test WER**    |
|:---------------|:------------------|:------------------|:------------------|:------------------|:------------------:|
|||||
| <em>Baseline</em>   | [Athena](https://github.com/athena-team/athena)            | [Transformer-AED + RNNLM](https://github.com/athena-team/athena/tree/master/examples/asr/gigaspeech) | GigaSpeech v1.0.0 XL | [model](https://drive.google.com/drive/folders/1HUUKzfnqqVfQR3epUVnnOWw9EEFpulVM) [example](https://github.com/athena-team/athena/blob/e704884ec6a3a947769d892aa267578038e49ecb/examples/asr/gigaspeech/run.sh#L85) | 13.60 / 12.70 | 
| <em>Baseline</em>    | [Espnet](https://github.com/espnet/espnet) | [Conformer/Transformer-AED](https://github.com/espnet/espnet/tree/master/egs2/gigaspeech/asr1) | GigaSpeech v1.0.0 XL | [model](https://zenodo.org/record/4630406) [example](https://github.com/espnet/espnet_model_zoo#asr) | 10.90 / 10.80 |
| <em>Baseline</em>    | [Kaldi](https://github.com/kaldi-asr/kaldi) | [Chain + RNNLM](https://github.com/kaldi-asr/kaldi/tree/master/egs/gigaspeech/s5/) | GigaSpeech v1.0.0 XL | <u>model</u> <u>example</u> | 14.78 / 14.84 |
| <em>Baseline</em>    | [Pika](https://github.com/tencent-ailab/pika) | [RNN-T](https://github.com/tencent-ailab/pika/tree/) | GigaSpeech v1.0.0 XL | <u>model</u> <u>example</u> | 12.30 / 12.30 |
|||||
| Mobvoi               | [Wenet](https://github.com/wenet-e2e/wenet) | [Conformer-AED](https://github.com/wenet-e2e/wenet/tree/main/examples/gigaspeech/s0) | GigaSpeech v1.0.0 XL | [model](http://mobvoi-speech-public.ufile.ucloud.cn/public/wenet/gigaspeech/20210705_conformer_bidecoder_exp.tar.gz) [example](https://github.com/wenet-e2e/wenet/blob/main/runtime/server/x86/README.md) | 11.00 / 10.90 |


## Dataset

### Audio Source
* Language: English
* 33,000+ hours for unsupervised/semi-supervised learning
* 10,000 hours with high-quality human transcriptions for supervised learning

| Audio Source   | Transcribed Hours | Total Hours    | Acoustic Condition |
|:---------------|:-----------------:|:--------------:|:-------------------|
| Audiobook      |  2,655            | 11,982         | <li>Reading</li><li>Various ages and accents</li> |
| Podcast        |  3,498            | 9,254          | <li>Clean or background music</li><li>Indoor</li><li>Near-field</li><li>Spontaneous</li><li>Various ages and accents</li>|
| YouTube        |  3,845            | 11,768         | <li>Clean and noisy</li><li>Indoor and outdoor</li><li>Near- and far-field</li><li>Reading and spontaneous</li><li>Various ages and accents</li> |
| ***total***    |  ***10,000***     | ***33,005***         ||


### Transcribed Training Subsets
| Subset    |    Hours    |  Remarks  |
|:---------------:|:-------------:|:-------------|
| XS |  10        | System building and debugging |
| S  |  250        | Quick research experiments |
| M  |  1,000      | Large-scale research experiments |
| L  |  2,500      | Medium-scale industrial experiments |
| XL |  10,000    | Large-scale industrial experiments |

Larger subsets are supersets of smaller subsets, e.g., subset `L` contains all the data from subset `M`.


### Transcribed Evaluation Subsets
| Subset | Hours | Remarks |
|:------:|:-----:|:--------|
| Dev    | 12    | Randomly selected from the crawled Podcast and YouTube Data |
| Test   | 40    | Part of the subset was randomly selected from the crawled Podcast and YouTube data; part of it was manually collected through other channels to have better coverage. |

Evaluation subsets are annotated by ***professional human annotators***


## Data Preparation Guidelines
We maintain data preparation scripts for different speech recognition toolkits
in this repository so that when we update the dataset (note, this is an evolving
dataset), we don't have to update the scripts in the downstream toolkits. Data
preparation scripts for different speech recognition toolkits are maintained in
the `toolkits/` folder, e.g., `toolkits/kaldi` for the Kaldi speech recognition
toolkit.

### Preparation Scripts
To use the data preparation scripts, do the following in your toolkit (here we
use Kaldi as an example)
```bash
git clone https://github.com/SpeechColab/GigaSpeech.git

cd GigaSpeech
utils/download_gigaspeech.sh /disk1/audio_data/gigaspeech
toolkits/kaldi/gigaspeech_data_prep.sh --train-subset XL /disk1/audio_data/gigaspeech ../data
cd ..
```

### Metadata walkthrough

We save all the metadata information to a single JSON file named
GigaSpeech.json. Below is a snip of this file:

```json
{
  "dataset": "GigaSpeech",
  "language": "EN",
  "version": "v1.0.0",
  ... ...
  "audios": [
    {
      "title": "The Architect of Hollywood",
      "url": "https://99percentinvisible.org/episode/the-architect-of-hollywood/download",
      "path": "audio/podcast/P0001/POD0000000025.opus",
      ... ...
      "segments": [
        {
          "sid": "POD0000000025_S0000103",
          "speaker": "N/A",
          "begin_time": 780.31,
          "end_time": 783.13,
          "text_tn": "FOUR O'CLOCK TOMORROW AFTERNOON <COMMA> SAID WILLIAMS <PERIOD>",
          "subsets": [
            "{XL}",
            "{L}"
          ]
        },
        ... ...
      ],
      ... ...
    },
    ... ...
  ]
}
```
To use the corpus, users are expected to extract the relevant information from GigaSpeech.json. For example, for the speech recognition task, one should first follow the "audios" entry, and work out a list of audio files. One can then follow the "url" entry to download the original audio file, or "path" if preprocessed audio files have been downloaded to the disk. After that, for each audio file, one can follow the "segments" entry, and work out the trainable audio segments, as well as their corresponding transcripts. Of course, we also have various supplementary entries, such as "subsets", "md5", which will also be helpful for your task.

The metadata file GigaSpeech.json is version controlled, and is supposed to get updated over the time. In future releases, we plan to add speaker information to the metadata file, so that it will be suitable for speaker identification/verification tasks. We also plan to add more data from different sources to increase the diversity.

We also provide some convenient command-line tools based on [jq](https://stedolan.github.io/jq/), e.g.,  [utils/ls_audio.sh](utils/ls_audios.sh), [utils/show_segment_info.sh](utils/show_segment_info.sh), [utils/ls_md5.sh](utils/ls_md5.sh).


### Audio Processing
* `Resampling`: GigaSpeech audio files are resampled at 16 kHz sampling rate, and are compressed with the Opus format. The Opus compression, however, does not depend on the input sample rate; it uses the bandwidth instead. Timestamps are measured in 48 kHz units even if the full bandwidth is not used. Likewise, the output sample rate may be freely chosen. For example, audio can be input at 16 kHz yet be set to encode only narrowband audio. For this reason, we recommend our users to explicitly resample the decoded audio to 16 kHz sampling rate before training & testing. For opus-to-wav conversion, refer to our exampler tool [utils/opus_to_wav.py](utils/opus_to_wav.py)

### Text Pre-Processing
* `Punctuations`: We keep 4 punctuations in the normalized text (see the `text_tn` entry in GigaSpeech.json)
    ```
    <COMMA>
    <PERIOD>
    <QUESTIONMARK>
    <EXCLAMATIONPOINT>
    ```
    This allows researchers to explore directions such as end-to-end endpointing and punctuation restoration. If you don't need these, you can remove them for your own training.

* `Grabage Utterance Tags`: The Dev/Test evaluation sets are annotated by human annotators. They are instructed to label the entire audio file without "gaps". So for non-speech segments, *garbage utterance tags* are used instead. We recommend our users to discard these utterances in your training. A *complete list* of these tags are:
    ```
    <SIL>
    <MUSIC>
    <NOISE>
    <OTHER>
    ```

### Text Post-Processing (before scoring)
* `Conversational Fillers`: Spontaneous/Conversational speech contains conversational fillers such as:
  ```
  'UH', 'UHH', 'UM', 'EH', 'MM', 'HM', 'AH', 'HUH', 'HA', 'ER'
  ```
  We recommend our users to remove these fillers from both hypothese and reference text before WER scoring, so that we will have apple-to-apple performance comparisons across different toolkits. See discussion on post-processing [here](https://github.com/SpeechColab/GigaSpeech/issues/24). We also provide a scoring tool [utils/gigaspeech_scoring.py](utils/gigaspeech_scoring.py) and this tool is used by all the toolkits reported in above leaderboard section.

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh` and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.

## Collaboration
We are a group of volunteers trying to make speech technologies easier to use. We welcome any kind of contributions. Currently we are exploring the following directions. If you are interested in one of the directions, and you think you will be able to help, please contact gigaspeech@speechcolab.org.

* Inference architecture for different pre-trained models
* Adding diverse audio source
* Benchmarking speech algorithms/services
* Building and releasing pre-trained models
* Supporting more languages
* Supporting more tasks through GigaSpeech.json (e.g., speaker ID)
* Making new datasets with permissive licenses

## Institutional Contributors
|  Institution | Contribution |
|:------|:-----|
| [Speechocean](http://en.speechocean.com/)                  | Evaluation data annotation; Data host mirror |
| [IEIT, Tsinghua University](http://www.tsinghua-ieit.com/) | Computing power; Data host |
| [Xiaomi Corporation](https://www.mi.com/global/)           | Computing power |

## Citation
Please cite our paper if you find this work useful:

```bibtext
@inproceedings{GigaSpeech2021,
  title={GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio},
  booktitle={Proc. Interspeech 2021},
  year=2021,
  author={Guoguo Chen, Shuzhou Chai, Guanbo Wang, Jiayu Du, Wei-Qiang Zhang, Chao Weng, Dan Su, Daniel Povey, Jan Trmal, Junbo Zhang, Mingjie Jin, Sanjeev Khudanpur, Shinji Watanabe, Shuaijiang Zhao, Wei Zou, Xiangang Li, Xuchen Yao, Yongqing Wang, Yujun Wang, Zhao You, Zhiyong Yan}
}
```

## Contact
If you have any concerns, please contact gigaspeech@speechcolab.org.
