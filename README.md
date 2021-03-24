# GigaSpeech
A Large, modern and evolving dataset for automatic speech recognition.

| Audio Source   |      Hours    |
|:---------------|:-------------:|
| Podcast        |  3,498        |
| Youtube        |  3,845        |
| Audiobook      |  2,655        |
| ***total***    |  ***10,000*** |

## Training Set
We organize the entire dataset via 5 subsets, targeting on different users.

| Subset   | Notation |    Size(Hours)    |  Target Usage  |
|:---------------|:-------------:|:-------------:|:-------------|
| eXtra Small | XS        |  10        |pipeline/recipe coding & debugging |
| Small | S        |  250        |quick research experiment for new ideas |
| Medium | M      |  1000        | serious research experiment / quick industrial experiment |
| Large | L      |  2500        | serious industrial experiment |
| eXtra Large | XL      |  10000        | industrial system building|

{`XL` includes {`L` includes {`M` includes {`S` includes {`XS`}}}}}


## Dev/Testing Set


## Dataset Download
To download the dataset, do the following steps:
1. Put aliyun_ossutil.cfg in the `SAFEBOX` folder
2. Run the following steps for downloading the dataset only
   ```bash
   utils/gigaspeech_download.sh
   ```

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
2. Grabage meta tags in DEV/TEST sets:
   our DEV/TEST sets are labelled by human annotators, they are instructed to label every single piece of the entire audio. So if part of audio is not human speech, they label it with a set of garbage meta tags.
   A *complete table* of garbage meta tags are listed below:
   ```
   <SIL>
   <MUSIC>
   <NOISE>
   <OTHER>
   ```
   Garbage meta tags are utterance level, meaning these utterances are not considered to be valid speech. So our recommendation is to discard these utterances in downstream training/testing. The reason why we keep these tags is to keep the integrity of human labels, so there is no "gap" inside DEV/TEST labels.

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh`and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.
