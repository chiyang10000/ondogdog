export DEPENDENCY_PATH=/opt/dependency/package

export HADOOP_HOME=/home/oushu/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

ulimit -c 10000000000
export CC=clang
export CXX=clang++
export DEPENDENCY_PATH=/opt/dependency/package

source /usr/local/oushu/oushudb/oushudb_path.sh

export PGDATABASE=postgres
