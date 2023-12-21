#!/bin/bash
set -e

main_host=$(hostname)

ssh ${main_host} 'echo hello' || tee >/usr/local/gpdb/bin/ssh <<EOF_ssh
#!/bin/bash
unset LD_LIBRARY_PATH
unset LD_PRELOAD
echo "CMD \$0 \${@}" 1>&2
exec /usr/bin/ssh "\$@"
EOF_ssh
test ! -f /usr/local/gpdb/bin/ssh || chmod +x /usr/local/gpdb/bin/ssh

which ssh
hash ssh
type ssh
ssh ${main_host} 'echo test ssh passphraseless'



# echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
# main_host=localhost
# cat /etc/hosts

OUSHU_DATA_DIR=$HOME/db_data/oushudb6
rm -rf ${OUSHU_DATA_DIR}
mkdir -p ${OUSHU_DATA_DIR}

tee >${OUSHU_DATA_DIR}/nodeConfig <<EOF_conf
# This file must exist in the same directory that you execute gpinitsystem in
MACHINE_LIST_FILE=${OUSHU_DATA_DIR}/hostfile

# Name of host on which to setup the QD
# Name of directory on that host in which to setup the QD
COORDINATOR_HOSTNAME=${main_host}
COORDINATOR_DIRECTORY=${OUSHU_DATA_DIR}/qddir
COORDINATOR_PORT=5432

# This names the data directories for the Segment Instances and the Entry Postmaster
# This is the port at which to contact the resulting Greenplum database, e.g.
#   psql -p $PORT_BASE -d template1
SEG_PREFIX=data
PORT_BASE=7002

# Array of data locations for each hosts Segment Instances, the number of directories in this array will
# set the number of segment instances per host
declare -a DATA_DIRECTORY=(${OUSHU_DATA_DIR}/seg)
EOF_conf
echo ${main_host} >${OUSHU_DATA_DIR}/hostfile



perl -i -pe 's|.*OUSHUDB_CONF.*|export OUSHUDB_CONF=/usr/local/oushu/conf/oushudb6|' /usr/local/gpdb/greenplum_path.sh
perl -i -pe 's|.*OUSHUDB_LOG_PATH.*|export OUSHUDB_LOG_PATH=/usr/local/oushu/log/oushudb6|' /usr/local/gpdb/greenplum_path.sh
grep 'dependency-6.0' /usr/local/gpdb/greenplum_path.sh ||
  echo 'test ! -f /opt/dependency-6.0/package/env.sh || source /opt/dependency-6.0/package/env.sh' >>/usr/local/gpdb/greenplum_path.sh
source /usr/local/gpdb/greenplum_path.sh
mkdir -p $OUSHUDB_CONF $OUSHUDB_LOG_PATH
cp -a -n /usr/local/gpdb/conf.empty/* $OUSHUDB_CONF || true
gpssh -f ${OUSHU_DATA_DIR}/hostfile 'source /usr/local/gpdb/greenplum_path.sh ; postgres -V'



pkill -SIGKILL magma_server || true
rm -rf /tmp/magma_catalog /tmp/magma_data
mkdir -p /tmp/magma_catalog /tmp/magma_data
magma start cluster && magma create vscluster
magma status



pkill -SIGKILL postgres || true
rm -rf /tmp/.s.PGSQL.*.lock ${OUSHU_DATA_DIR}/qddir ${OUSHU_DATA_DIR}/seg
mkdir -p ${OUSHU_DATA_DIR}/qddir ${OUSHU_DATA_DIR}/seg
gpinitsystem --locale=C --lc-ctype=C -ac ${OUSHU_DATA_DIR}/nodeConfig



psql -c 'select * from gp_segment_configuration;'
psql -c 'alter database postgres set default_tablespace = magma_catalog;'
