#!/bin/bash

export path="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" && pwd)"
ls "$path/../sql/clickhouse.sql"

create() {
  set -ex
  hawq sql --version
  clickhouse-client --version

  sql_template="$path/../sql/clickhouse.sql"
  hdfs_prefix="hdfs://$(psql --no-align --tuples-only --command 'show hawq_dfs_url')/"

  echo $hdfs_prefix
  clickhouse-client -d hdfs --multiline --multiquery --query "$(cat $sql_template | sed "s|hdfs://localhost:8020/hawq_default/|$hdfs_prefix|")"
  clickhouse-client -d native --time --multiline --multiquery --query "$(cat $path/../sql/count.sql)"
}

create