#!/bin/bash
set -e

main_host=$(hostname)
num_segment=1

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
rm -rf $HOME/gpAdminLogs/*
rm -rf ${OUSHU_DATA_DIR}
mkdir -p ${OUSHU_DATA_DIR}

for segIdx in `seq 1 $((num_segment-1))`; do
  SEG_DATA_DIRECTORY="$SEG_DATA_DIRECTORY ${OUSHU_DATA_DIR}/seg"
  SEG_LIST="${SEG_LIST}m1,"
done
SEG_DATA_DIRECTORY="$SEG_DATA_DIRECTORY ${OUSHU_DATA_DIR}/seg"
SEG_LIST="${SEG_LIST}m1"
echo $SEG_DATA_DIRECTORY
echo $SEG_LIST

tee >${OUSHU_DATA_DIR}/nodeConfig <<EOF_conf
# This file must exist in the same directory that you execute gpinitsystem in
MACHINE_LIST_FILE=${OUSHU_DATA_DIR}/hostfile

# Name of host on which to setup the QD
# Name of directory on that host in which to setup the QD
COORDINATOR_HOSTNAME=${main_host}
COORDINATOR_DIRECTORY=${OUSHU_DATA_DIR}/qddir
COORDINATOR_PORT=5432
COORDINATOR_MAX_CONNECT=100

# This names the data directories for the Segment Instances and the Entry Postmaster
# This is the port at which to contact the resulting Greenplum database, e.g.
#   psql -p $PORT_BASE -d template1
SEG_PREFIX=data
PORT_BASE=7002

# Array of data locations for each hosts Segment Instances, the number of directories in this array will
# set the number of segment instances per host
declare -a DATA_DIRECTORY=(${SEG_DATA_DIRECTORY})
EOF_conf
echo localhost >${OUSHU_DATA_DIR}/hostfile



perl -i -pe 's|.*OUSHUDB_CONF.*|export OUSHUDB_CONF=/usr/local/oushu/conf/oushudb6|' /usr/local/gpdb/greenplum_path.sh
perl -i -pe 's|.*OUSHUDB_LOG_PATH.*|export OUSHUDB_LOG_PATH=/usr/local/oushu/log/oushudb6|' /usr/local/gpdb/greenplum_path.sh
grep 'dependency-6.0' /usr/local/gpdb/greenplum_path.sh ||
  echo 'test ! -f /opt/dependency-6.0/package/env.sh || source /opt/dependency-6.0/package/env.sh' >>/usr/local/gpdb/greenplum_path.sh
source /usr/local/gpdb/greenplum_path.sh
mkdir -p $OUSHUDB_CONF $OUSHUDB_LOG_PATH
cp -a -n /usr/local/gpdb/conf.empty/* $OUSHUDB_CONF || true
gpssh -f ${OUSHU_DATA_DIR}/hostfile 'source /usr/local/gpdb/greenplum_path.sh ; postgres -V'



pkill -SIGKILL -f magma_server || true
rm -rf /tmp/magma_catalog /tmp/magma_data
mkdir -p /tmp/magma_catalog /tmp/magma_data
mkdir -p ${OUSHU_DATA_DIR}/magma_catalog ${OUSHU_DATA_DIR}/magma_data
magma start cluster && magma create vscluster
magma status



pkill -SIGKILL -f postgres || true
rm -rf /tmp/.s.PGSQL.*.lock ${OUSHU_DATA_DIR}/qddir ${OUSHU_DATA_DIR}/seg
mkdir -p ${OUSHU_DATA_DIR}/qddir ${OUSHU_DATA_DIR}/seg
rm -rf ${OUSHU_DATA_DIR}/qedir && mkdir -p ${OUSHU_DATA_DIR}/qedir
# mkdir -p ${OUSHU_DATA_DIR}/qddir/data-1/log
# gpinitsystem --locale=C --lc-ctype=C -ac ${OUSHU_DATA_DIR}/nodeConfig || err=1
perl -i -pe "s|/tmp|${OUSHU_DATA_DIR}|" $OUSHUDB_CONF/oushudb-site.xml
perl -i -pe "s|7000|5432|" $OUSHUDB_CONF/oushudb-site.xml
perl -i -pe "s|m1,m1.*|${SEG_LIST}|" $OUSHUDB_CONF/oushudb-topology.yaml
oushudb init cluster -a

if [[ -n $err ]]; then
  ls -ltr $HOME/gpAdminLogs/
  cat $HOME/gpAdminLogs/*.log
fi



psql -c 'select * from gp_segment_configuration;'

psql -c "create tablespace magma_default location 'magma://oushu/vsc_default';" || true
psql -c "grant all on tablespace magma_default to public;" || true
#export COORDINATOR_DATA_DIRECTORY=${OUSHU_DATA_DIR}/qddir/data-1
# gpconfig -c default_tablespace -v magma_default
# gpconfig -c temp_tablespaces -v magma_default
# gpconfig --skipvalidation -c timezone -v 'Asia/Shanghai'  # TestType.TestNoStorageDate
# gpconfig -c max_connections -v 128 --masteronly
# gpstop -a && gpstart -a

oushudb config --skipvalidation -c max_connections -v 128 || true
oushudb config --skipvalidation -c default_tablespace -v magma_default || true
oushudb config --skipvalidation -c temp_tablespaces -v magma_default || true
oushudb restart cluster -a

# psql -c 'alter database postgres set default_tablespace = magma_default;'
# psql -c 'alter database postgres set temp_tablespaces = magma_default;'
# psql -c 'ALTER database postgres set default_table_access_method = magmaap;'
psql -d postgres -a <<sql_EOF
alter database postgres set timezone_abbreviations to 'Default';
alter database postgres set timezone to 'PST8PDT';
alter database postgres set datestyle to 'postgres,MDY';
alter database postgres set max_parallel_workers_per_gather = 4;
sql_EOF

psql -ac 'alter database postgres set gp_enable_explain_allstat = on;'
psql -ac "alter database postgres set max_statement_mem = '8GB';"
psql -ac "alter database postgres set statement_mem = '4GB';"
psql -ac 'create table test(i int); select * from test;'
psql -ac 'create table t as select generate_series(1, 10) k, generate_series(10, 10, -1) v;'
psql -ac 'explain analyze select * from t;'
