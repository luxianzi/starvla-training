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

# Set Aliyun CLI keys
if [[ -n "$ALICLOUD_KEY_ID" && -n "$ALICLOUD_KEY" && -n "$ALICLOUD_REGION" ]]; then
    ALICLOUD_CONFIG_PATH=/home/DUMMY_USERNAME/.aliyun
    ALICLOUD_CONFIG_FILE="$ALICLOUD_CONFIG_PATH/config.json"
    mkdir -p "$ALICLOUD_CONFIG_PATH"
    printf "{" > "$ALICLOUD_CONFIG_FILE"
    printf "\t\"current\": \"default\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\"profiles\": [\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t{\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"name\": \"default\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"mode\": \"AK\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"access_key_id\": \"$ALICLOUD_KEY_ID\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"access_key_secret\": \"$ALICLOUD_KEY\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"region_id\": \"cn-beijing\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"output_format\": \"json\",\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t\t\"language\": \"en\"\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\t}\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t],\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "\t\"meta_path\": \"\"\n" >> "$ALICLOUD_CONFIG_FILE"
    printf "}\n" >> "$ALICLOUD_CONFIG_FILE"
    chmod 600 "$ALICLOUD_CONFIG_FILE"
    chown DUMMY_USERNAME:DUMMY_USERNAME "$ALICLOUD_CONFIG_FILE"
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
