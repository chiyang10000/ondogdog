#!/bin/bash

export USER=$(whoami)

cp -r /home/oushu/conf/oushudb/* /usr/local/oushu/conf/oushudb

cp /home/oushu/conf/.bashrc /home/oushu/.bashrc
source /home/oushu/.bashrc

echo "if [ -f ~/.bashrc ]; then
source ~/.bashrc
fi" >> ~/.bash_profile

# ssh configure
sudo /usr/sbin/sshd-keygen -A
sudo /usr/sbin/sshd
sudo su - oushu
oushudb ssh-exkeys -f ~/oushuhostfile
sudo su oushu

if [ -f "/tmp/db_data/hawq-data-directory/magma_segment/magma.node" ]; then
  # restart magma
  echo "magma restart cluster"
  magma restart cluster
else
  # init magma
  rm -rf /tmp/db_data/hawq-data-directory/*/*
  install -d /tmp/db_data/hawq-data-directory/magma_master
  install -d /tmp/db_data/hawq-data-directory/magma_segment

  sudo pkill -9 magma
  rm -rf /tmp/magma_{data,catalog} ~/hawq-data-directory
  mkdir -p /tmp/magma_{data,catalog}

  echo "magma start cluster"
  magma start cluster
  echo "magma create vcluster --vc=vsc_catalog"
  magma create vscluster --vsc=vsc_catalog
  echo "magma create vcluster --vc=vsc_default"
  magma create vscluster --vsc=vsc_default
fi

tail -f /dev/null
