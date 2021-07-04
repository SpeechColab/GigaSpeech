# GigaSpeech
This is the official repository of the GigaSpeech dataset. For details of how we created the dataset, please refer to our Interspeech paper: *"GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio"*. [Preprint available on arxiv](https://arxiv.org/abs/2106.06909).

GigaSpeech version: 1.0.0 (07/01/2021)

## Download
Please fill out the Google Form [here]() and follow the instructions to download the GigaSpeech dataset.

## Leaderboard

| **Contributor**| **Toolkit**       | **Train Recipe**     | **Train Data** | **Inference**     |**Dev/Test WER**    |
|:---------------|:------------------|:------------------|:------------------|:------------------|:------------------:|
|||||
| <em>Baseline</em>   | [Athena](https://github.com/athena-team/athena)            | [Transformer-AED + RNNLM](https://github.com/athena-team/athena/tree/master/examples/asr/gigaspeech) | GigaSpeech v1.0.0 XL | [model](https://drive.google.com/drive/folders/1HUUKzfnqqVfQR3epUVnnOWw9EEFpulVM) [example](https://github.com/athena-team/athena/blob/e704884ec6a3a947769d892aa267578038e49ecb/examples/asr/gigaspeech/run.sh#L85) | 13.60 / 12.70 | 
| <em>Baseline</em>    | [Espnet](https://github.com/espnet/espnet) | [Conformer/Transformer-AED](https://github.com/espnet/espnet/tree/master/egs2/gigaspeech/asr1) | GigaSpeech v1.0.0 XL | [model](https://zenodo.org/record/4630406) [example](https://github.com/espnet/espnet_model_zoo#asr) | 10.90 / 10.80 |
| <em>Baseline</em>    | [Kaldi](https://github.com/kaldi-asr/kaldi) | [Chain + RNNLM](https://github.com/kaldi-asr/kaldi/tree/master/egs/gigaspeech/s5/) | GigaSpeech v1.0.0 XL | <u>model</u> <u>example</u> | 14.78 / 14.84 |
| <em>Baseline</em>    | [Pika](https://github.com/tencent-ailab/pika) | [RNN-T](https://github.com/tencent-ailab/pika/tree/) | GigaSpeech v1.0.0 XL | <u>model</u> <u>example</u> | 12.30 / 12.30 |
|||||
| Mobvoi               | [Wenet](https://github.com/wenet-e2e/wenet) | [Conformer-AED](https://github.com/wenet-e2e/wenet/tree/main/examples/gigaspeech/s0) | GigaSpeech v1.0.0 XL | [model](http://mobvoi-speech-public.ufile.ucloud.cn/public/wenet/gigaspeech/20210618_conformer_exp.tar.gz) [example](https://github.com/wenet-e2e/wenet/blob/main/runtime/server/x86/README.md) | 11.10 / 11.00 |


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
| S  |  250        | Qucik research experiments |
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

### Audio Processing
* `Resampling`: Audio files in GigaSpeech are encoded in `OPUS`, with bandwith conforming to 16k sample rate. However some Python/C libraries may have bugs that they don't honor the sample rate encoded in OPUS, and directly extract 48kHz wavs.  We recommend our users explicitly resample opus to 16k wav before training & testing (this could be done on-the-fly or offline). For opus-to-wav conversion, refer to our exampler tool [here](utils/opus_to_wav.py).

### Text Pre-Processing
* `Punctuations`: By design we keep 4 punctuations in labels(utterance's `text_tn` section)
    ```
    <COMMA>
    <PERIOD>
    <QUESTIONMARK>
    <EXCLAMATIONPOINT>
    ```
    This could enable E2E endpointer & punctuator research. If you don't want these, just remove these punctuations in your text preprocessing.

* `Grabage Utterance Tags`:
   DEV/TEST sets are labeled by human annotators, they are instructed to label entire audio without "gap". So for segments that are not human speech, *garbage utterance tags* are used as labels. We recommend to discard these utterances in preprocessing. A *complete table* of these tags are:
    ```
    <SIL>
    <MUSIC>
    <NOISE>
    <OTHER>
    ```

### Text Post-Processing(before word-error-rate scoring)
* `Conversational Fillers`: Spontaneous/Conversational speeches contain conversational fillers such as:
  ```
  'UH', 'UHH', 'UM', 'EH', 'MM', 'HM', 'AH', 'HUH', 'HA', 'ER'
  ```
  these fillers are everywhere, meaningless, and impractical to be transcribed in unified froms. So we highly recommend to remove these fillers from hypothese and reference text before WER scoring, for apple-to-apple scoring comparisons. See discussion [here](https://github.com/SpeechColab/GigaSpeech/issues/24). We provide scoring tool [here](utils/gigaspeech_scoring.py), and this tool is used by all toolkits reported in above leaderboard section.

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh` and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.


## Collaboration
We are a group of volunteers trying to make speech technologies easier to use. We welcome any kind of contributions. Currently we are exploring the following directions. If you are interested in one of the directions, and you think you will be able to help, please contact info@speechcolab.org.

* Inference architecture for different pre-trained models
* Adding diverse audio source
* Benchmarking speech algorithms/services
* Building and releasing pre-trained models
* Supporting more languages
* Making new datasets with permissive licenses

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


