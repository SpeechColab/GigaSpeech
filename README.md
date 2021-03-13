# GigaSpeech
A Large, modern and evolving dataset for automatic speech recognition.

| Audio Source   |      Hours    |
|:---------------|:-------------:|
| Podcast        |  3,498        |
| Youtube        |  3,845        |
| Audiobook      |  2,655        |
| ***total***    |  ***10,000*** |


## Dataset Download
To download the dataset, do the following steps:
1. Put aliyun_ossutil.cfg in the `SAFEBOX` folder
2. Edit env_vars.sh
    ```bash
    # User-specified directory to store the GigaSpeech dataset. It needs at least
    # 900G of free space.
    export GIGA_SPEECH_LOCAL_ROOT=~/GigaSpeech
    ```
3. Run the following steps for downloading the dataset only
   ```bash
   . ./env_vars.sh
   utils/setup_oss_for_downloading.sh
   utils/download_meta.sh
   utils/download_audio.sh
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
toolkits/kaldi/gigaspeech_download.sh
toolkits/kaldi/gigaspeech_data_prep.sh ../data gigaspeech
cd ..
```

### Add Support for a New Toolkit
To add data preparation support for a new toolkit, please follow
`toolkits/kaldi/gigaspeech_download.sh` and `toolkits/kaldi/gigaspeech_data_prep.sh`,
and add similar scripts for your own toolkit. For example, for ESPnet2, you
would add `toolkits/espnet2/gigaspeech_download.sh` to download the data, and
`toolkits/espnet2/gigaspeech_data_prep.sh` to prepare the dataset, and all
other related scripts should be maintained under `toolkits/espnet2`.
