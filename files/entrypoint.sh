#!/bin/bash

set -e

# Create the SSH directory
mkdir -p /home/DUMMY_USERNAME/.ssh
chown DUMMY_USERNAME:DUMMY_USERNAME /home/DUMMY_USERNAME/.ssh

# Create SSH public key file
if [ -n "$SSH_USER_PUBLIC_KEY" ]; then
    SSH_AUTHORIZED_KEYS_FILE=/home/DUMMY_USERNAME/.ssh/authorized_keys
    echo "$SSH_USER_PUBLIC_KEY" > "$SSH_AUTHORIZED_KEYS_FILE"
    chmod 600 "$SSH_AUTHORIZED_KEYS_FILE"
    chown DUMMY_USERNAME:DUMMY_USERNAME "$SSH_AUTHORIZED_KEYS_FILE"
    /usr/sbin/sshd
fi

# Set AWS CLI keys
if [[ -n "$AWS_KEY_ID" && -n "$AWS_KEY" && -n "$AWS_REGION" ]]; then
    AWS_CONFIG_PATH=/home/DUMMY_USERNAME/.aws
    AWS_CREDENTIAL_FILE="$AWS_CONFIG_PATH/credentials"
    AWS_CONFIG_FILE="$AWS_CONFIG_PATH/config"
    mkdir -p "$AWS_CONFIG_PATH"
    echo "[default]" > "$AWS_CREDENTIAL_FILE"
    echo "aws_access_key_id = $AWS_KEY_ID" >> "$AWS_CREDENTIAL_FILE"
    echo "aws_secret_access_key = $AWS_KEY" >> "$AWS_CREDENTIAL_FILE"
    echo "[default]" > "$AWS_CONFIG_FILE"
    echo "region = $AWS_REGION" >> "$AWS_CONFIG_FILE"
    echo "output = json" >> "$AWS_CONFIG_FILE"
    chmod 600 "$AWS_CREDENTIAL_FILE"
    chown DUMMY_USERNAME:DUMMY_USERNAME "$AWS_CREDENTIAL_FILE"
    chown DUMMY_USERNAME:DUMMY_USERNAME "$AWS_CONFIG_FILE"
fi

# Fix cuda library issue on some hosts
if [ ! -f "/usr/lib/x86_64-linux-gnu/libcuda.so" ]; then
    ln -s /usr/lib/x86_64-linux-gnu/libcuda.so.1 /usr/lib/x86_64-linux-gnu/libcuda.so
fi

# Handle empty run command
if [ $# -eq 0 ]; then
    set -- bash
fi

exec gosu DUMMY_USERNAME "$@"
