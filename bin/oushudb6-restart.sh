#!/bin/bash

perl -i -pe 's|.*OUSHUDB_CONF=.*|export OUSHUDB_CONF=/usr/local/oushu/conf/oushudb6|' /usr/local/gpdb/greenplum_path.sh
perl -i -pe 's|.*OUSHUDB_LOG_PATH=.*|export OUSHUDB_LOG_PATH=/usr/local/oushu/log/oushudb6|' /usr/local/gpdb/greenplum_path.sh
grep 'dependency-6.0' /usr/local/gpdb/greenplum_path.sh ||
  echo 'test ! -f /opt/dependency-6.0/package/env.sh || source /opt/dependency-6.0/package/env.sh' >>/usr/local/gpdb/greenplum_path.sh

export COORDINATOR_DATA_DIRECTORY=$HOME/db_data/oushudb6/qddir/data-1
ls -ltr $COORDINATOR_DATA_DIRECTORY
source /usr/local/gpdb/greenplum_path.sh
pkill -9 -f postgres
oushudb restart cluster
# gpstop -a
# gpstart -a

psql -Xc 'select * from gp_segment_configuration'
