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
| eXtra Small | XS        |  10        |coding/debugging for pipeline/recipe |
| Small | S        |  250        |quick research experiment for new ideas |
| Medium | M      |  1000        | serious research experiment / quick industrial experiment |
| Large | L      |  2500        | serious industial-scale experiment |
| eXtra Large | XL      |  10000        | industrial-scale system building|

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
toolkits/kaldi/gigaspeech_data_prep.sh /disk1/audio_data/gigaspeech ../data true gigaspeech
cd ..
```
#### Some Notes on text processing
1. In labels(text), by design we have punctuations support, becasue:
   * we believe this is an essential feature towards a real e2e system
   * endpoint detection is a pain for e2e system, incorporating punctuations into training data may open a new gate for better solutions.

To be specific, in utterance's `text_tn` section, there are possibly 4 punctuations:
```
<COMMA>
<PERIOD>
<QUESTIONMARK>
<EXCLAMATIONPOINT>
```

1. meta tags in DEV/TEST sets:
our DEV/TEST sets are labelled by human annotators, they are required to label every single piece of the entire audio. So when some piece of the audio are not human speech, they label it with a set of meta tags.
A *complete table* of meta tags are listed below:
```
<SIL> # silence segment
<MUSIC> # music segment
<NOISE> # noise segment
<OTHER> # something else, that human annotators can't tell what it is, i.e. garbage
```
Normally, utterances with these tags are not supposed to be used in ASR system, so our recommendation is to discard these utterances in downstream training/testing.
The reason why we keep these tags is to keep the integrity of human labels, so there is no "gap" inside DEV/TEST labels.

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh`and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.
