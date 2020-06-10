#!/bin/bash
set -e

export path="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" && pwd)"
sql_template="$path/../sql/clickhouse.sql"
ls "$sql_template"

hawq sql --version
clickhouse-client --version

hawq_db=postgres
hawq_schema=public
clickhouse_db=native
parallel_num=$(nproc)
clickhouse_engine="MergeTree order by tuple()"

tpc_h_tables="nation region part supplier partsupp customer orders lineitem"

load_clickhouse_by_hdfs() {

  hdfs_prefix="hdfs://$(psql --no-align --tuples-only --command 'show hawq_dfs_url')/"

  echo $hdfs_prefix
  clickhouse-client -d hdfs --time --multiline --multiquery --echo --query "$(cat $sql_template | sed "s|hdfs://localhost:8020/hawq_default/|$hdfs_prefix|")"
  clickhouse-client -d $clickhouse_db --multiline --multiquery --echo --query "$(cat $sql_template | sed "s|engine = .*;|engine = ${clickhouse_engine};|")"

  for table in $tpc_h_tables; do
    clickhouse-client -d $clickhouse_db --multiline --multiquery --echo <<CMD
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
