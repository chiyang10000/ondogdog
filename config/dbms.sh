#-------------------------------------------------------------------------------
#
# postgres/mysql/tidb/cockroachdb/greenplum/spark
#
# db-init/start/stop/sql-DBMS
#
#-------------------------------------------------------------------------------
postgres-start() {
  pg_ctl -D $HOME/postgres-data/ start
}
postgres-stop() {
  pg_ctl -D $HOME/postgres-data/ stop
}
postgres-sql() {
  psql
}

mysql-start() {
  mysqld --datadir=/Users/admin/mysql-data/ --init-file=/Users/admin/mysql-data/mysql.init --secure-file-priv=/Users/admin/dev/monetdb-postgres-compare/.data/sf-1 &
}
mysql-stop() {
  killall mysqld
}
mysql-sql() {
  mysql -u root -D tpch
}

tidb-start() {
  pd-server --data-dir=$HOME/tidb-data/pd --log-file=$HOME/tidb-data/pd.log &
  sleep 5
  tikv-server --pd="127.0.0.1:2379" --data-dir=$HOME/tidb-data/tikv --log-file=$HOME/tidb-data/tikv.log &
  sleep 2
  tidb-server --store=tikv --path="127.0.0.1:2379" --log-file=$HOME/tidb-data/tidb.log &
}
tidb-stop() {
  killall tidb-server
  killall tikv-server
  killall pd-server
}
tidb-sql() {
  mysql -h 127.0.0.1 -P 4000 -u root -D tpch
}

cockroachdb-start() {
  cockroach start --store=$HOME/cockroach-data --insecure --log-dir=$HOME/cockroachdb.log &
}
cockroachdb-stop() {
  killall cockroach
}
cockroachdb-sql() {
  cockroach sql --insecure
}

export MASTER_DATA_DIRECTORY=/Users/admin/dev/gpdb/gpAux/gpdemo/datadirs/qddir/demoDataDir-1
gpdb-sql() {
  psql -p 15432
}

spark-start() {
  /usr/local/Cellar/apache-spark/2.2.0/libexec/sbin/start-master.sh
  /usr/local/Cellar/apache-spark/2.2.0/libexec/sbin/start-slave spark://localhost:7077
}
spark-sql() {
  cd /tmp
  spark-sql --driver-java-options "-Dlog4j.configuration=file:///usr/local/Cellar/apache-spark/2.2.0/bin/log4j.properties"
}
