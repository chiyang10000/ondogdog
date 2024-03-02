#!/bin/bash
test ! -f /usr/local/hawq/greenplum_path.sh || source /usr/local/hawq/greenplum_path.sh
test ! -f /usr/local/oushu/oushudb/oushudb_path.sh || source /usr/local/oushu/oushudb/oushudb_path.sh
test ! -f /usr/local/gpdb/greenplum_path.sh || source /usr/local/gpdb/greenplum_path.sh
exec gpdiff.pl $@
