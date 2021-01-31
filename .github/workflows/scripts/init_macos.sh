#!/bin/bash
set -e



# Setup passphraseless ssh
sudo systemsetup -setremotelogin on
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

tee -a ~/.ssh/config <<EOF_ssh_config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF_ssh_config

ssh -v localhost whoami

# Configure system kernel state
sudo tee /etc/sysctl.conf << EOF
kern.sysv.shmmax=2147483648
kern.sysv.shmmin=1
kern.sysv.shmmni=64
kern.sysv.shmseg=16
kern.sysv.shmall=524288
kern.maxfiles=65535
kern.maxfilesperproc=65536
kern.corefile=/cores/core.%N.%P
EOF
</etc/sysctl.conf xargs sudo sysctl

# Add data folder
sudo install -o $USER -d /tmp/db_data/
