#!/bin/bash

set -e

# Create the SSH directory
mkdir /home/DUMMY_USERNAME/.ssh
chown DUMMY_USERNAME:DUMMY_USERNAME /home/DUMMY_USERNAME/.ssh

# Create public key file
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" > /home/DUMMY_USERNAME/.ssh/authorized_keys
    chmod 600 /home/DUMMY_USERNAME/.ssh/authorized_keys
    chown DUMMY_USERNAME:DUMMY_USERNAME /home/DUMMY_USERNAME/.ssh/authorized_keys
    /usr/sbin/sshd
fi

if [ $# -eq 0 ]; then
    set -- bash
fi

exec gosu DUMMY_USERNAME "$@"
