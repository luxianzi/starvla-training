#!/bin/bash
set -e

# Activate Miniforge environment
source /home/$USERNAME/miniforge3/etc/profile.d/conda.sh

# Create training environment
conda env create -f starvla.yml
conda activate starvla
# FIXME: flash-attn requires torch, but we cannot guarantee PyTorch will be installed before other pacakges
# solely through the YAML file
pip install flash-attn==2.8.3
pip cache purge
conda clean --all -y
