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

if [ -f "/tmp/db_data/hawq-data-directory/segmentdd/postmaster.pid" ]; then
  # restart segment
  echo "Restart Segment"
  oushudb restart segment -a
else
  # init segment
  rm -rf /tmp/db_data/hawq-data-directory/*/*
  install -d /tmp/db_data/hawq-data-directory/segmentdd

  echo "Init Segment"
  oushudb init segment -a
fi

tail -f $(ls -1rt /usr/local/oushu/log/oushudb/segment/*.csv)
