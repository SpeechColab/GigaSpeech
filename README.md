# GigaSpeech
A Large, modern and evolving dataset for automatic speech recognition.

| Audio Source   |      Hours    |
|:---------------|:-------------:|
| Podcast        |  3,498        |
| Youtube        |  3,845        |
| Audiobook      |  2,655        |
| ***total***    |  ***10,000*** |

## Subsets & Target usage
We organize the entire dataset via 5 subsets, targeting on different users.

| Subset   |    Size(Hours)    |  Target Usage  |
|:---------------|:-------------:|:-------------:|
| XS        |  10        | coding/debugging for pipeline/recipe |
| S        |  250        | quick research experiment for new ideas |
| M      |  1000        | serious research experiment / quick industrial experiment |
| L      |  2500        | serious industial-scale experiment |
| XL      |  10000        | building industrial-scale system |

(`XL` includes (`L` includes (`M` includes (`S` includes `XS`)))) 


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

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_data_prep.sh`and add similar scripts for your own
toolkit. For example, for ESPnet2, you would add
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.
