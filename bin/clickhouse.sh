#!/bin/bash
set -e

export path="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" && pwd)"
sql_template="$path/../sql/clickhouse.sql"
tpc_h_schema_sql="$path/../sql/clickhouse-tpc-h-schema.sql"
ls "$sql_template"

export hawq_db=postgres
export hawq_db=hawq_feature_test_db
export hawq_schema=testtpch_testorc_newqe_10g
export clickhouse_db=native

hawq-client() {
  hawq sql --host chiyang-linux --port 5432 "$@"
}
hawq-client-dump() {
  test ! -f /usr/local/hawq/greenplum_path.sh || source /usr/local/hawq/greenplum_path.sh
  pg_dump --host chiyang-linux --port 5432 $hawq_db -t "$*" -s | sed -n '/CREATE/,$ p' | sed '/WITH/,$ d'
}
clickhouse-client() {
  ~/Downloads/clickhouse --client --host chiyang-linux --port 9000 "$@"
}
hawq-client --version
clickhouse-client --version


parallel_num=$(nproc)
clickhouse_engine="MergeTree order by tuple()"

tpc_h_tables="nation region part supplier partsupp customer orders lineitem"

load_clickhouse_by_hdfs() {

  hdfs_prefix="hdfs://$(hawq-client --no-align --tuples-only --command 'show hawq_dfs_url')/"

  echo $hdfs_prefix

  # clickhouse-client -d $clickhouse_db --multiline --multiquery --echo --query "$(cat $sql_template | sed "s|engine = .*;|engine = ${clickhouse_engine};|")"
  clickhouse-client -d $clickhouse_db --multiline --multiquery --echo --query "$(cat $tpc_h_schema_sql)"

  for table in $tpc_h_tables; do
    hdfs_uri=$(hawq-client -d $hawq_db --tuples-only --command "select hornet_helper.ls_hdfs_table_location('${table}')" | tr -d ' ')/*
    table_ddl="$(hawq-client-dump $table) engine = HDFS('${hdfs_uri}', 'ORC');"
    echo $table_ddl

    # clickhouse-client -d hdfs --time --multiline --multiquery --echo --query "$(cat $sql_template | sed "s|hdfs://localhost:8020/hawq_default/[^']*|${hdfs_uri}|")"
    clickhouse-client -d hdfs --time --multiline --multiquery --echo --query "drop table if exists $table"
    clickhouse-client -d hdfs --time --multiline --multiquery --echo --query "$table_ddl"
    clickhouse-client -d $clickhouse_db --time --multiline --multiquery --echo <<CMD
    insert into ${clickhouse_db}.${table} select * from hdfs.${table}
CMD
  done
}

load_clickhouse_by_hawq() {
  # clean and setup database
  psql -d $hawq_db --echo-all --command "drop schema if exists clickhouse cascade; create schema clickhouse;"
  clickhouse-client --multiquery --echo --query "drop database if exists $clickhouse_db; create database $clickhouse_db;"
  clickhouse-client -d $clickhouse_db --multiline --multiquery --echo --query "$(cat $sql_template | sed "s|engine = .*;|engine = ${clickhouse_engine};|")"

  # create external table
  for table in $tpc_h_tables; do
    psql -d $hawq_db --echo-all <<CMD
      create writable external web table clickhouse.${table} (like $hawq_schema.${table})
      execute 'clickhouse-client --query="insert into ${clickhouse_db}.${table} format TabSeparated"'
      on ${parallel_num} FORMAT 'TEXT';
CMD
  done

  # load
  for table in $tpc_h_tables; do
    psql -d $hawq_db --echo-queries <<CMD
    \timing on
    insert into clickhouse.${table} select * from ${hawq_schema}.${table}
CMD
  done
}

load_clickhouse_by_hdfs

clickhouse-client -d native --time --multiline --multiquery --query "$(cat $path/../sql/count.sql)"
