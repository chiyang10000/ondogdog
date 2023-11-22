\set storage_spec with (appendonly=true, orientation=orc, compresstype=none, dicthreshold=0.8)

-- a combo <=2048MB for SF=10
\set storage_spec with (appendonly=true, orientation=orc, compresstype=zlib, dicthreshold=0.8)
\set char_type VARCHAR
\set flag_status_type "char"
\set decimal_type DECIMAL(12,2)

\set storage_spec
\set not_null_constraint 'NOT NULL'
\set flag_status_type CHAR
\set decimal_type FLOAT

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
    N_NATIONKEY INTEGER        :not_null_constraint,
    N_NAME      :char_type(25) :not_null_constraint,
    N_REGIONKEY INTEGER        :not_null_constraint,
    N_COMMENT   VARCHAR(152)   :not_null_constraint
) :storage_spec;

CREATE TABLE region
(
    R_REGIONKEY INTEGER        :not_null_constraint,
    R_NAME      :char_type(25) :not_null_constraint,
    R_COMMENT   VARCHAR(152)   :not_null_constraint
) :storage_spec;

CREATE TABLE part
(
    P_PARTKEY     INTEGER        :not_null_constraint,
    P_NAME        VARCHAR(55)    :not_null_constraint,
    P_MFGR        :char_type(25) :not_null_constraint,
    P_BRAND       :char_type(10) :not_null_constraint,
    P_TYPE        VARCHAR(25)    :not_null_constraint,
    P_SIZE        INTEGER        :not_null_constraint,
    P_CONTAINER   :char_type(10) :not_null_constraint,
    P_RETAILPRICE :decimal_type  :not_null_constraint,
    P_COMMENT     VARCHAR(23)    :not_null_constraint
) :storage_spec;

CREATE TABLE supplier
(
    S_SUPPKEY   INTEGER        :not_null_constraint,
    S_NAME      :char_type(25) :not_null_constraint,
    S_ADDRESS   VARCHAR(40)    :not_null_constraint,
    S_NATIONKEY INTEGER        :not_null_constraint,
    S_PHONE     :char_type(15) :not_null_constraint,
    S_ACCTBAL   :decimal_type  :not_null_constraint,
    S_COMMENT   VARCHAR(101)   :not_null_constraint
) :storage_spec;

CREATE TABLE partsupp
(
    PS_PARTKEY    INTEGER       :not_null_constraint,
    PS_SUPPKEY    INTEGER       :not_null_constraint,
    PS_AVAILQTY   INTEGER       :not_null_constraint,
    PS_SUPPLYCOST :decimal_type :not_null_constraint,
    PS_COMMENT    VARCHAR(199)  :not_null_constraint
) :storage_spec;

CREATE TABLE customer
(
    C_CUSTKEY    INTEGER        :not_null_constraint,
    C_NAME       VARCHAR(25)    :not_null_constraint,
    C_ADDRESS    VARCHAR(40)    :not_null_constraint,
    C_NATIONKEY  INTEGER        :not_null_constraint,
    C_PHONE      :char_type(15) :not_null_constraint,
    C_ACCTBAL    :decimal_type  :not_null_constraint,
    C_MKTSEGMENT :char_type(10) :not_null_constraint,
    C_COMMENT    VARCHAR(117)   :not_null_constraint
) :storage_spec;

CREATE TABLE orders
(
    O_ORDERKEY      bigint            :not_null_constraint,
    O_CUSTKEY       INTEGER           :not_null_constraint,
    O_ORDERSTATUS   :flag_status_type :not_null_constraint,
    O_TOTALPRICE    :decimal_type     :not_null_constraint,
    O_ORDERDATE     DATE              :not_null_constraint,
    O_ORDERPRIORITy :char_type(15)    :not_null_constraint,
    O_CLERK         :char_type(15)    :not_null_constraint,
    O_SHIPPRIORITY  INTEGER           :not_null_constraint,
    O_COMMENT       VARCHAR(79)       :not_null_constraint
) :storage_spec;

CREATE TABLE lineitem
(
    L_ORDERKEY      bigint            :not_null_constraint,
    L_PARTKEY       INTEGER           :not_null_constraint,
    L_SUPPKEY       INTEGER           :not_null_constraint,
    L_LINENUMBER    INTEGER           :not_null_constraint,
    L_QUANTITY      :decimal_type     :not_null_constraint,
    L_EXTENDEDPRICE :decimal_type     :not_null_constraint,
    L_DISCOUNT      :decimal_type     :not_null_constraint,
    L_TAX           :decimal_type     :not_null_constraint,
    L_RETURNFLAG    :flag_status_type :not_null_constraint,
    L_LINESTATUS    :flag_status_type :not_null_constraint,
    L_SHIPDATE      DATE              :not_null_constraint,
    L_COMMITDATE    DATE              :not_null_constraint,
    L_RECEIPTDATE   DATE              :not_null_constraint,
    L_SHIPINSTRUCT  :char_type(25)    :not_null_constraint,
    L_SHIPMODE      :char_type(10)    :not_null_constraint,
    L_COMMENT       VARCHAR(44)       :not_null_constraint
) :storage_spec;
