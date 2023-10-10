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

if [ -f "/tmp/db_data/hawq-data-directory/masterdd/postmaster.pid" ]; then
  # restart main
  magma status |grep healthy
  ERR=$?
  while [ $ERR -ne 0 ]
  do sleep 1
  magma status |grep healthy
  ERR=$?
  done

  magma status |grep unhealthy
  ERR=$?
  while [ $ERR -eq 0 ]
  do sleep 1
  magma status |grep unhealthy
  ERR=$?
  done

  until magma status | grep serving; do
    sleep 1
  done
  magma status
  echo "Restart Main"
  oushudb restart main -a
else
  # init main
  magma status |grep healthy
  ERR=$?
  while [ $ERR -ne 0 ]
  do sleep 1
  magma status |grep healthy
  ERR=$?
  done

  magma status |grep unhealthy
  ERR=$?
  while [ $ERR -eq 0 ]
  do sleep 1
  magma status |grep unhealthy
  ERR=$?
  done

  until magma status | grep serving; do
    sleep 1
  done
  magma status

  rm -rf /tmp/db_data/hawq-data-directory/*/*
  install -d /tmp/db_data/hawq-data-directory/masterdd

  sudo pkill -9 postgres

  echo "Init Main"
  oushudb init main -a
fi

tail -f $(ls -1rt /usr/local/oushu/log/oushudb/master/*.csv)
