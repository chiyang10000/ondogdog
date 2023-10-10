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

if [ -f "/home/oushu/hadoop/data/in_use.lock" ] && [ -f "/home/oushu/hadoop/name/in_use.lock" ]; then
  # restart hdfs
  echo "restart hdfs"
  stop-dfs.sh
  hdfs --daemon start namenode
  hdfs --daemon start datanode
  hdfs dfsadmin -report
else
  # init hdfs
  echo "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
  cp /home/oushu/conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
  cp /home/oushu/conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
  rm -rf $HADOOP_HOME/name $HADOOP_HOME/data
  mkdir $HADOOP_HOME/name $HADOOP_HOME/data

  echo "start hdfs"
  hdfs namenode -format
  hdfs --daemon start namenode
  hdfs --daemon start datanode
  hdfs dfsadmin -report
fi

tail -f /dev/null