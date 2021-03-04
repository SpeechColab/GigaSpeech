#!/usr/bin/env bash

. ./env_vars.sh

sh utils/setup_oss_for_downloading.sh

sh utils/download_meta.sh

# this currently download entire dataset, we may improve to support subset downloading
sh utils/download_audio.sh
