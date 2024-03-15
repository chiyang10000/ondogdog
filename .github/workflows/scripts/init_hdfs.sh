#!/bin/bash
set -e



test -n "$HADOOP_HOME"
export HDFS_DATA="$HOME/db_data/hdfs/"

# Configure
tee $HADOOP_HOME/etc/hadoop/core-site.xml << EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:8020</value>
    </property>
    <property>
         <name>hadoop.proxyuser.admin.hosts</name>
         <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.admin.groups</name>
        <value>*</value>
    </property>
</configuration>
EOF
tee $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOF
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${HDFS_DATA}/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${HDFS_DATA}/data</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.client.read.shortcircuit</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.domain.socket.path</name>
        <value>/var/lib/hadoop-hdfs/dn_socket</value>
    </property>
</configuration>
EOF
tee -a $HADOOP_HOME/etc/hadoop/hadoop-env.sh << EOF
export HADOOP_OPTS="\$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native/"
EOF

# Initialize
sudo install -o $USER -d /var/lib/hadoop-hdfs/
install -d ${HDFS_DATA}/name ${HDFS_DATA}/data
hadoop checknative || true #FIXME: Abort trap: 6 ???
hdfs namenode -format

# Start
$HADOOP_HOME/sbin/start-dfs.sh

# Connect
hdfs dfsadmin -report
hdfs dfs -ls /
hdfs dfs -touchz /touchz
