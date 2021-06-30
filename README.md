# GigaSpeech
This is the official repository of the GigaSpeech dataset. For details of how we created the dataset, please refer to our Interspeech paper: *"GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio"*. [Preprint available on arxiv](https://arxiv.org/abs/2106.06909).


# GigaSpeech Leaderboard

| **Contributor**| **Toolkit**       | **Train**         | **Inference**     |**Dev/Test WER**    |
|:---------------|:------------------|:------------------|:------------------|:------------------|
|||||
| <em>Baseline</em>   | [Athena](https://github.com/athena-team/athena)            | [Transformer-AED + RNNLM](https://github.com/athena-team/athena/tree/master/examples/asr/gigaspeech) | [model](https://drive.google.com/drive/folders/1HUUKzfnqqVfQR3epUVnnOWw9EEFpulVM) <u>example</u> | 13.60 / 12.70 | 
| <em>Baseline</em>    | [Espnet](https://github.com/espnet/espnet) | [Conformer/Transformer-AED](https://github.com/espnet/espnet/tree/master/egs2/gigaspeech/asr1) | [model](https://zenodo.org/record/4630406) [example](https://github.com/espnet/espnet_model_zoo#asr) | 10.90 / 10.80 |
| <em>Baseline</em>    | [Kaldi](https://github.com/kaldi-asr/kaldi) | [Chain + RNNLM](https://github.com/kaldi-asr/kaldi/tree/master/egs/gigaspeech/s5/) | <u>model</u> <u>example</u> | 14.78 / 14.84 |
| <em>Baseline</em>    | [Pika](https://github.com/tencent-ailab/pika) | [RNN-T](https://github.com/tencent-ailab/pika/tree/) | <u>model</u> <u>example</u> | 12.30 / 12.30 |
|||||
| Mobvoi               | [Wenet](https://github.com/wenet-e2e/wenet) | [](https://github.com/wenet-e2e/wenet/tree/main/examples/gigaspeech/s0) | [model](http://mobvoi-speech-public.ufile.ucloud.cn/public/wenet/gigaspeech/20210618_conformer_exp.tar.gz) <u>example</u> | |



## Data Source
* Language: English
* 40,000+ hours for unsupervised/semi-supervised learning.
* 10,000 hours with high-quality human transcriptions for supervised learning.

| Audio Source   | Transcribed Hours | Total Hours    | Acoustic Condition |
|:---------------|:-----------------:|:---------------|:-------------------|
| Audiobook      |  2,655            |                | <li>Reading</li><li>Various ages and accents</li> |
| Podcast        |  3,498            |                | <li>Clean or background music</li><li>Indoor</li><li>Near-field</li><li>Spontaneous</li><li>Various ages and accents</li>|
| Youtube        |  3,845            |                | <li>Clean and noisy</li><li>Indoor and outdoor</li><li>Near- and far-field</li><li>Reading and spontaneous</li><li>Various ages and accents</li> |
| ***total***    |  ***10,000***     ||


## Supervised Training Subsets
| Subset   | Notation |    Size(Hours)    |  Target Use  |
|:---------------|:-------------:|:-------------:|:-------------|
| eXtra Small | XS        |  10        |pipeline/recipe coding & debugging, gradient/loss playground |
| Small | S        |  250        |quick research experiment for new ideas |
| Medium | M      |  1000        | serious research experiment / quick industrial experiment |
| Large | L      |  2500        | serious industrial experiment |
| eXtra Large | XL      |  10000        | industrial system building|

{`XL` includes {`L` includes {`M` includes {`S` includes {`XS`}}}}}


## Dev Set (~12 hours)
* all audio files are randomly drawn from crawled podcast & youtube data


## Test Set (~40 hours)
* some audio files are randomly drawn from crawled podcast & youtube data
* some audio files are manually collected by GigaSpeech authors from internet(independent to crawling process), including podcasts & videos, to cover wider scenarios & domains.

(Dev + Test) sets are labeled by **payed professional human annotators**.


## Dataset Download
For public:
uploading dataset to several free hosts, need some time, please wait.

## Dataset Pre-processing Guidelines
We maintain data preparation scripts for different speech recognition toolkits
in this repository so that when we update the dataset (note, this is an evolving
dataset), we don't have to update the scripts in the downstream toolkits. Data
preparation scripts for different speech recognition toolkits are maintained in
the `toolkits/` folder, e.g., `toolkits/kaldi` for the Kaldi speech recognition
toolkit.

### Preparation Scripts Usage
To use the data preparation scripts, do the following in your toolkit (here we
use Kaldi as an example)
```bash
git clone https://github.com/SpeechColab/GigaSpeech.git

cd GigaSpeech
utils/gigaspeech_download.sh /disk1/audio_data/gigaspeech
toolkits/kaldi/gigaspeech_data_prep.sh --train-subset XL /disk1/audio_data/gigaspeech ../data
cd ..
```

### Notes on Text Processing
1. By design we have `punctuations` in labels. This could enable E2E endpointer & punctuator research. To be specific, 4 punctuations may appear in utterance's `text_tn` section, they are:
    ```
    <COMMA>
    <PERIOD>
    <QUESTIONMARK>
    <EXCLAMATIONPOINT>
    ```

2. `Grabage utterance tags`:
   DEV/TEST sets are labeled by human annotators, they are instructed to label entire audio without "gap". So for segments that are not human speech, *garbage utterance tags* are used as labels. We recommend to discard these utterances in preprocessing. A *complete table* of these tags are:
    ```
    <SIL>
    <MUSIC>
    <NOISE>
    <OTHER>
    ```

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh` and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.


# Citation
Please cite our paper if you find this work useful:

```bibtext
@inproceedings{GigaSpeech2021,
  title={GigaSpeech: An Evolving, Multi-domain ASR Corpus with 10,000 Hours of Transcribed Audio},
  booktitle={Proc. Interspeech 2021},
  year=2021,
  author={Guoguo Chen, Shuzhou Chai, Guanbo Wang, Jiayu Du, Wei-Qiang Zhang, Chao Weng, Dan Su, Daniel Povey, Jan Trmal, Junbo Zhang, Mingjie Jin, Sanjeev Khudanpur, Shinji Watanabe, Shuaijiang Zhao, Wei Zou, Xiangang Li, Xuchen Yao, Yongqing Wang, Yujun Wang, Zhao You, Zhiyong Yan}
}
```


