# GigaSpeech
A Large, modern and evolving dataset for automatic speech recognition.

InterSpeech 2021 Accepted paper, arXiv preprint link: ... 

---
## Data sources
* Language: English
* For unsupervised/semi-supervised learning: total 40000+ hours of audio collection.
* For supervised learning: 10000 hours with high-quality human transcriptions.

| Audio Source   |      Hours    | acoustic | domain |
|:---------------|:-------------:|:---------------|:---------------|
| Podcast        |  3,498        | near-field <br> indoor <br> spontaneous <br> clean or tender background music <br> genders, ages, accents | daily topics |
| Youtube        |  3,845        | near & far field <br> indoor & outdoor <br> reading & spontaneous <br> clean & noisy <br> genders, ages, accents | vast topics/domains coverage |
| Audiobook      |  2,655        | slow narrative reading | books, stories |
| ***total***    |  ***10,000*** |||

---
## Training Set
We organize the entire dataset via 5 subsets, targeting on different users.

| Subset   | Notation |    Size(Hours)    |  Target Usage  |
|:---------------|:-------------:|:-------------:|:-------------|
| eXtra Small | XS        |  10        |pipeline/recipe coding & debugging, gradient/loss playground |
| Small | S        |  250        |quick research experiment for new ideas |
| Medium | M      |  1000        | serious research experiment / quick industrial experiment |
| Large | L      |  2500        | serious industrial experiment |
| eXtra Large | XL      |  10000        | industrial system building|

{`XL` includes {`L` includes {`M` includes {`S` includes {`XS`}}}}}

Training set labels are processed/extracted/validated by our `long-form alignment-segmentation` pipeline, out of **human transcriptions, subtitles, manuscripts**. 

## Dev set (~12 hours)
* all audio files are randomly drawn from crawled podcast & youtube data

## Test set (~40 hours)
* some audio files are randomly drawn from crawled podcast & youtube data
* some audio files are manually collected by GigaSpeech authors from internet(independent to crawling process), including podcasts & videos, to cover wider scenarios & domains.

(Dev + Test) sets contain 50+ hours raw data, labeled by **payed professional human annotators**.

## Dataset download
To download the dataset, do the following steps:
1. Put aliyun_ossutil.cfg in `SAFEBOX` folder
2. Run the following steps for downloading the dataset only
   ```bash
   utils/gigaspeech_download.sh /download/destination/dir/for/GigaSpeechDataset
   ```
   Then the entire dataset will be downloaded to your local dir.

   If your network is interrupted or broken during downloading, you can just rerun above command, it will continue with previous downloading.

   You can also use above command to update your local GigaSpeech copy with newest GigaSpeech release.

## Toolkit Support
We maintain data preparation scripts for different speech recognition toolkits
in this repository so that when we update the dataset (note, this is an evolving
dataset), we don't have to update the scripts in the downstream toolkits. Data
preparation scripts for different speech recognition toolkits are maintained in
the `toolkits/` folder, e.g., `toolkits/kaldi` for the Kaldi speech recognition
toolkit.

### Data Preparation for Toolkits
To use the data preparation scripts, do the following in your toolkit (here we
use Kaldi as an example)
```bash
git clone https://github.com/SpeechColab/GigaSpeech.git

cd GigaSpeech
utils/gigaspeech_download.sh /disk1/audio_data/gigaspeech
toolkits/kaldi/gigaspeech_data_prep.sh --train-subset XL /disk1/audio_data/gigaspeech ../data
cd ..
```
#### Notes on Text Processing
1. By design we have punctuations in labels. To be specific, 4 punctuations may appear in utterance's `text_tn` section, they are:
   ```
   <COMMA>
   <PERIOD>
   <QUESTIONMARK>
   <EXCLAMATIONPOINT>
   ```

2. Grabage utterance tags in DEV/TEST sets:
   DEV/TEST sets are labelled by human annotators, they are instructed to label every single piece of the audio. So if part of audio is not human speech, they label it with a set of garbage utterance tags.
   A *complete table* of garbage meta tags are listed below:
   ```
   <SIL>
   <MUSIC>
   <NOISE>
   <OTHER>
   ```
   utterances with these garbage tags are not considered to be valid speech. We recommend to discard these utterances in preprocessing. The reason why we keep these tags is to keep the integrity of human labels.

## Baselines from invited speech toolkits/frameworks

| Toolkit   | recipe |
|:---------------|:---------------|
|Athena| https://github.com/athena-team/athena (to be released) |
|Espnet| https://github.com/espnet/espnet/tree/master/egs2/gigaspeech/asr1 |
|Kaldi| https://github.com/kaldi-asr/kaldi (to be released) |
|Pika | https://github.com/tencent-ailab/pika (to be released) |
|WeNet | https://github.com/wenet-e2e/wenet/tree/main/examples/gigaspeech/s0 |

* Above baselines are all trained with GigaSpeech XL set
* For most up-to-date results, please follow recipe links

## paper 
* link
* sitation

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh`and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.
