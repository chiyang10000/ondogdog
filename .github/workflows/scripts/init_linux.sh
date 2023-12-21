#!/bin/bash
set -e

df -h
free -h
lscpu



# Setup passphraseless ssh
test -f ~/.ssh/id_rsa || ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod go-w ~
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

tee -a ~/.ssh/config <<EOF_ssh_config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF_ssh_config

ssh -v localhost whoami

# Configure system kernel state
sudo tee /etc/sysctl.conf << EOF_sysctl
kernel.shmmax = 1000000000
kernel.shmmni = 4096
kernel.shmall = 4000000000
kernel.sem = 250 512000 100 2048
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_max_syn_backlog = 200000
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 10000 65535
net.core.netdev_max_backlog = 200000
net.netfilter.nf_conntrack_max = 524288
fs.nr_open = 3000000
kernel.threads-max = 798720
kernel.pid_max = 798720

net.core.rmem_max=2097152
net.core.wmem_max=2097152
net.core.somaxconn=4096
EOF_sysctl
sudo sysctl -p

# Add data folder
sudo install -o $USER -d /tmp/db_data/

# RPM BASH for [[ ???
sudo chsh -s /bin/bash root
sudo chsh -s /bin/bash
getent group oushu  || sudo groupadd -r oushu
getent passwd oushu || sudo /usr/sbin/useradd -M -r -g oushu oushu # XXX: skip RPM %pre error

# check RPM util
if ! command -v rpm; then
  if command -v apt-get; then
    sudo apt-get install rpm
  fi
fi
