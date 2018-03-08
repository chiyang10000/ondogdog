DROP EXTERNAL WEB TABLE IF EXISTS e_nation;
DROP EXTERNAL WEB TABLE IF EXISTS e_customer;
DROP EXTERNAL WEB TABLE IF EXISTS e_region;
DROP EXTERNAL WEB TABLE IF EXISTS e_part;
DROP EXTERNAL WEB TABLE IF EXISTS e_supplier;
DROP EXTERNAL WEB TABLE IF EXISTS e_partsupp;
DROP EXTERNAL WEB TABLE IF EXISTS e_orders;
DROP EXTERNAL WEB TABLE IF EXISTS e_lineitem;
drop table if exists nation cascade;
drop table if exists region cascade;
drop table if exists part cascade;
drop table if exists supplier cascade;
drop table if exists partsupp cascade;
drop table if exists customer cascade;
drop table if exists orders cascade;
drop table if exists lineitem cascade;

CREATE EXTERNAL TABLE e_nation (N_NATIONKEY  INTEGER ,
                            N_NAME       VARCHAR(25) ,
                            N_REGIONKEY  INTEGER ,
                            N_COMMENT    VARCHAR(152))
                  location ('hdfs://localhost:8020/tpch1g/nation') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_REGION  ( R_REGIONKEY  INTEGER ,
                            R_NAME       VARCHAR(25) ,
                            R_COMMENT    VARCHAR(152))
                  location ('hdfs://localhost:8020/tpch1g/region') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_PART  ( P_PARTKEY     INTEGER ,
                          P_NAME        VARCHAR(55) ,
                          P_MFGR        VARCHAR(25) ,
                          P_BRAND       VARCHAR(10) ,
                          P_TYPE        VARCHAR(25) ,
                          P_SIZE        INTEGER ,
                          P_CONTAINER   VARCHAR(10) ,
                          P_RETAILPRICE  FLOAT  ,
                          P_COMMENT     VARCHAR(23) )
                  location ('hdfs://localhost:8020/tpch1g/part') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_SUPPLIER ( S_SUPPKEY     INTEGER ,
                             S_NAME        VARCHAR(25) ,
                             S_ADDRESS     VARCHAR(40) ,
                             S_NATIONKEY   INTEGER ,
                             S_PHONE       VARCHAR(15) ,
                             S_ACCTBAL      FLOAT  ,
                             S_COMMENT     VARCHAR(101) )
                  location ('hdfs://localhost:8020/tpch1g/supplier') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_PARTSUPP ( PS_PARTKEY     INTEGER ,
                             PS_SUPPKEY     INTEGER ,
                             PS_AVAILQTY    INTEGER ,
                             PS_SUPPLYCOST   FLOAT   ,
                             PS_COMMENT     VARCHAR(199) )
                  location ('hdfs://localhost:8020/tpch1g/partsupp') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_CUSTOMER ( C_CUSTKEY     INTEGER ,
                             C_NAME        VARCHAR(25) ,
                             C_ADDRESS     VARCHAR(40) ,
                             C_NATIONKEY   INTEGER ,
                             C_PHONE       VARCHAR(15) ,
                             C_ACCTBAL      FLOAT  ,
                             C_MKTSEGMENT  VARCHAR(10) ,
                             C_COMMENT     VARCHAR(117) )
                  location ('hdfs://localhost:8020/tpch1g/customer') FORMAT 'text' (delimiter '|');

CREATE external TABLE e_ORDERS  ( O_ORDERKEY       INT8 ,
                           O_CUSTKEY        INTEGER ,
                           O_ORDERSTATUS    VARCHAR(1) ,
                           O_TOTALPRICE      FLOAT  ,
                           O_ORDERDATE      DATE,
                           O_ORDERPRIORITY  VARCHAR(15) ,
                           O_CLERK          VARCHAR(15) ,
                           O_SHIPPRIORITY   INTEGER ,
                           O_COMMENT        VARCHAR(79) )
                  location ('hdfs://localhost:8020/tpch1g/orders') FORMAT 'text' (delimiter '|');

CREATE EXTERNAL TABLE E_LINEITEM ( L_ORDERKEY    INT8 ,
                              L_PARTKEY     INTEGER ,
                              L_SUPPKEY     INTEGER ,
                              L_LINENUMBER  INTEGER ,
                              L_QUANTITY     FLOAT  ,
                              L_EXTENDEDPRICE   FLOAT  ,
                              L_DISCOUNT     FLOAT  ,
                              L_TAX          FLOAT  ,
                              L_RETURNFLAG  VARCHAR(1) ,
                              L_LINESTATUS  VARCHAR(1) ,
                              L_SHIPDATE    DATE ,
                              L_COMMITDATE  DATE ,
                              L_RECEIPTDATE DATE ,
                              L_SHIPINSTRUCT CHAR(25) ,
                              L_SHIPMODE     VARCHAR(10) ,
                              L_COMMENT      VARCHAR(44) )
                  location ('hdfs://localhost:8020/tpch1g/lineitem') FORMAT 'text' (delimiter '|');
