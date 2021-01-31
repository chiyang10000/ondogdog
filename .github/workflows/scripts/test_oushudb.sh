#!/bin/bash
set -e



# Connect
source /usr/local/opt/oushudb/greenplum_path.sh
psql -d postgres -a -v ON_ERROR_STOP=1 << EOF
select version();
select gp_opt_version();

create table t_ao(i int);
create table t_orc(i int) with (appendonly=true,orientation=orc);
create table t_parquet(i int) with (appendonly=true,orientation=parquet);

insert into t_ao select generate_series(1,1000);
insert into t_orc select generate_series(1,1000);
insert into t_parquet select generate_series(1,1000);

select count(*) from t_ao;
select count(*) from t_orc;
select count(*) from t_parquet;
EOF

# Stop
source /usr/local/opt/oushudb/greenplum_path.sh
hawq stop cluster -a
