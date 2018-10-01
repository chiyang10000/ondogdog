\timing

CREATE TABLE NATION  ( N_NATIONKEY  INTEGER ,
                       N_NAME       CHAR(25) ,
                       N_REGIONKEY  INTEGER ,
                       N_COMMENT    VARCHAR(152),
                       primary key(N_NATIONKEY))
FORMAT 'magma';

CREATE TABLE REGION  ( R_REGIONKEY  INTEGER ,
                       R_NAME       CHAR(25) ,
                       R_COMMENT    VARCHAR(152),
                       primary key(R_REGIONKEY))
FORMAT 'magma';

CREATE  TABLE PART  ( P_PARTKEY     INTEGER,
                      P_NAME        VARCHAR(55),
                      P_MFGR        CHAR(25),
                      P_BRAND       CHAR(10),
                      P_TYPE        VARCHAR(25),
                      P_SIZE        INTEGER,
                      P_CONTAINER   CHAR(10),
                      P_RETAILPRICE  FLOAT ,
                      P_COMMENT     VARCHAR(23),
                      primary key(P_PARTKEY))
FORMAT 'magma';

CREATE TABLE SUPPLIER ( S_SUPPKEY     INTEGER ,
                             S_NAME        CHAR(25) ,
                             S_ADDRESS     VARCHAR(40) ,
                             S_NATIONKEY   INTEGER ,
                             S_PHONE       CHAR(15) ,
                             S_ACCTBAL      FLOAT  ,
                             S_COMMENT     VARCHAR(101) ,
                             primary key(S_SUPPKEY))
FORMAT 'magma';

CREATE TABLE PARTSUPP ( PS_PARTKEY     INTEGER ,
                             PS_SUPPKEY     INTEGER ,
                             PS_AVAILQTY    INTEGER ,
                             PS_SUPPLYCOST   FLOAT   ,
                             PS_COMMENT     VARCHAR(199) ,
                       primary key(PS_PARTKEY, PS_SUPPKEY) )
FORMAT 'magma';

CREATE TABLE CUSTOMER ( C_CUSTKEY     INTEGER,
                             C_NAME        VARCHAR(25),
                             C_ADDRESS     VARCHAR(40),
                             C_NATIONKEY   INTEGER,
                             C_PHONE       CHAR(15),
                             C_ACCTBAL      FLOAT   ,
                             C_MKTSEGMENT  CHAR(10),
                             C_COMMENT     VARCHAR(117),
                         primary key(C_CUSTKEY)) 
FORMAT 'magma';

CREATE TABLE orders (
    o_orderkey bigint,
    o_custkey INTEGER,
    o_orderstatus CHAR,
    o_totalprice  FLOAT ,
    o_orderdate DATE,
    o_orderpriority CHAR(15),
    o_clerk CHAR(15),
    o_shippriority integer,
    o_comment VARCHAR(79), 
    primary key(o_orderkey)
) 
FORMAT 'magma'
;

CREATE  TABLE lineitem ( L_ORDERKEY    INT8,
                              L_PARTKEY     INTEGER,
                              L_SUPPKEY     INTEGER,
                              L_LINENUMBER  INTEGER,
                              L_QUANTITY     FLOAT ,
                              L_EXTENDEDPRICE   FLOAT ,
                              L_DISCOUNT     FLOAT ,
                              L_TAX          FLOAT ,
                              L_RETURNFLAG  CHAR,
                              L_LINESTATUS  CHAR,
                              L_SHIPDATE    DATE,
                              L_COMMITDATE  DATE,
                              L_RECEIPTDATE DATE,
                              L_SHIPINSTRUCT CHAR(25),
                              L_SHIPMODE     CHAR(10),
                              L_COMMENT      VARCHAR(44), 
                        primary key(L_ORDERKEY, L_LINENUMBER))
FORMAT 'magma' 
;
