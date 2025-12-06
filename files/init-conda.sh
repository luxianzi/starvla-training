#!/bin/bash
set -e

curl -LO https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
chmod a+x Miniforge3-Linux-x86_64.sh
./Miniforge3-Linux-x86_64.sh -b
rm Miniforge3-Linux-x86_64.sh
~/miniforge3/bin/conda init
