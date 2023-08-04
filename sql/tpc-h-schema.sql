\set storage_spec with (appendonly=true, orientation=orc, dicthreshold=0.8)
\set storage_spec with (appendonly=true, orientation=orc, compresstype=none, dicthreshold=0.8)
\set storage_spec 
\set char_type "char"
\set char_type CHAR
\set decimal_type FLOAT
-- \set decimal_type DECIMAL(12,2)

DROP TABLE IF EXISTS nation CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS part CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS partsupp CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS lineitem CASCADE;

CREATE TABLE nation
(
    N_NATIONKEY INTEGER,
    N_NAME      CHAR(25),
    N_REGIONKEY INTEGER,
    N_COMMENT   VARCHAR(152)
) :storage_spec;

CREATE TABLE region
(
    R_REGIONKEY INTEGER,
    R_NAME      CHAR(25),
    R_COMMENT   VARCHAR(152)
) :storage_spec;

CREATE TABLE part
(
    P_PARTKEY     INTEGER,
    P_NAME        VARCHAR(55),
    P_MFGR        CHAR(25),
    P_BRAND       CHAR(10),
    P_TYPE        VARCHAR(25),
    P_SIZE        INTEGER,
    P_CONTAINER   CHAR(10),
    P_RETAILPRICE :decimal_type,
    P_COMMENT     VARCHAR(23)
) :storage_spec;

CREATE TABLE supplier
(
    S_SUPPKEY   INTEGER,
    S_NAME      CHAR(25),
    S_ADDRESS   VARCHAR(40),
    S_NATIONKEY INTEGER,
    S_PHONE     CHAR(15),
    S_ACCTBAL   :decimal_type,
    S_COMMENT   VARCHAR(101)
) :storage_spec;

CREATE TABLE partsupp
(
    PS_PARTKEY    INTEGER,
    PS_SUPPKEY    INTEGER,
    PS_AVAILQTY   INTEGER,
    PS_SUPPLYCOST :decimal_type,
    PS_COMMENT    VARCHAR(199)
) :storage_spec;

CREATE TABLE customer
(
    C_CUSTKEY    INTEGER,
    C_NAME       VARCHAR(25),
    C_ADDRESS    VARCHAR(40),
    C_NATIONKEY  INTEGER,
    C_PHONE      CHAR(15),
    C_ACCTBAL    :decimal_type,
    C_MKTSEGMENT CHAR(10),
    C_COMMENT    VARCHAR(117)
) :storage_spec;

CREATE TABLE orders
(
    O_ORDERKEY      bigint,
    O_CUSTKEY       INTEGER,
    O_ORDERSTATUS   :char_type,
    O_TOTALPRICE    :decimal_type,
    O_ORDERDATE     DATE,
    O_ORDERPRIORITy CHAR(15),
    O_CLERK         CHAR(15),
    O_SHIPPRIORITY  integer,
    O_COMMENT       VARCHAR(79)
) :storage_spec;

CREATE TABLE lineitem
(
    L_ORDERKEY      INT8,
    L_PARTKEY       INTEGER,
    L_SUPPKEY       INTEGER,
    L_LINENUMBER    INTEGER,
    L_QUANTITY      :decimal_type,
    L_EXTENDEDPRICE :decimal_type,
    L_DISCOUNT      :decimal_type,
    L_TAX           :decimal_type,
    L_RETURNFLAG    :char_type,
    L_LINESTATUS    :char_type,
    L_SHIPDATE      DATE,
    L_COMMITDATE    DATE,
    L_RECEIPTDATE   DATE,
    L_SHIPINSTRUCT  CHAR(25),
    L_SHIPMODE      CHAR(10),
    L_COMMENT       VARCHAR(44)
) :storage_spec;
