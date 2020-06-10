drop table if exists nation;
drop table if exists customer;
drop table if exists region;
drop table if exists part;
drop table if exists supplier;
drop table if exists partsupp;
drop table if exists orders;
drop table if exists lineitem;

create table nation
(
    n_nationkey integer,
    n_name      varchar,
    n_regionkey integer,
    n_comment   varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/nation/*_*', 'ORC');

create table region
(
    r_regionkey integer,
    r_name      varchar,
    r_comment   varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/region/*_*', 'ORC');

create table part
(
    p_partkey     integer,
    p_name        varchar,
    p_mfgr        varchar,
    p_brand       varchar,
    p_type        varchar,
    p_size        integer,
    p_container   varchar,
    p_retailprice double,
    p_comment     varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/part/*_*', 'ORC');

create table supplier
(
    s_suppkey   integer,
    s_name      varchar,
    s_address   varchar,
    s_nationkey integer,
    s_phone     varchar,
    s_acctbal   double,
    s_comment   varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/supplier/*_*', 'ORC');

create table partsupp
(
    ps_partkey    integer,
    ps_suppkey    integer,
    ps_availqty   integer,
    ps_supplycost double,
    ps_comment    varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/partsupp/*_*', 'ORC');

create table customer
(
    c_custkey    integer,
    c_name       varchar,
    c_address    varchar,
    c_nationkey  integer,
    c_phone      varchar,
    c_acctbal    double,
    c_mktsegment varchar,
    c_comment    varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/customer/*_*', 'ORC');

create table orders
(
    o_orderkey      bigint,
    o_custkey       integer,
    o_orderstatus   char,
    o_totalprice    double,
    o_orderdate     date,
    o_orderpriority varchar,
    o_clerk         varchar,
    o_shippriority  integer,
    o_comment       varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/orders/*_*', 'ORC');

create table lineitem
(
    l_orderkey      bigint,
    l_partkey       integer,
    l_suppkey       integer,
    l_linenumber    integer,
    l_quantity      double,
    l_extendedprice double,
    l_discount      double,
    l_tax           double,
    l_returnflag    char,
    l_linestatus    char,
    l_shipdate      date,
    l_commitdate    date,
    l_receiptdate   date,
    l_shipinstruct  varchar,
    l_shipmode      varchar,
    l_comment       varchar
) engine = HDFS('hdfs://localhost:8020/hawq_default/dfs_default/postgres/public/lineitem/*_*', 'ORC');

drop table if exists native.nation;
drop table if exists native.customer;
drop table if exists native.region;
drop table if exists native.part;
drop table if exists native.supplier;
drop table if exists native.partsupp;
drop table if exists native.orders;
drop table if exists native.lineitem;
create table native.nation engine = MergeTree order by tuple() as select * from hdfs.nation;
create table native.customer engine = MergeTree order by tuple() as select * from hdfs.customer;
create table native.region engine = MergeTree order by tuple() as select * from hdfs.region;
create table native.part engine = MergeTree order by tuple() as select * from hdfs.part;
create table native.supplier engine = MergeTree order by tuple() as select * from hdfs.supplier;
create table native.partsupp engine = MergeTree order by tuple() as select * from hdfs.partsupp;
create table native.orders engine = MergeTree order by tuple() as select * from hdfs.orders;
create table native.lineitem engine = MergeTree order by tuple() as select * from hdfs.lineitem;
