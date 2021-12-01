DROP TABLE IF EXISTS part;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS partsupp;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS lineitem;
DROP TABLE IF EXISTS nation;
DROP TABLE IF EXISTS region;

CREATE TABLE part
(
    p_partkey       Int32,  -- PK
    p_name          String, -- variable text, size 55
    p_mfgr          FixedString(25),
    p_brand         FixedString(10),
    p_type          String, -- variable text, size 25
    p_size          Int32,  -- integer
    p_container     FixedString(10),
    p_retailprice   Decimal(18,2),
    p_comment       String, -- variable text, size 23
    CONSTRAINT pk CHECK p_partkey >= 0,
    CONSTRAINT positive CHECK (p_size >= 0 AND p_retailprice >= 0)
) engine = MergeTree ORDER BY (p_partkey);

CREATE TABLE supplier
(
    s_suppkey       Int32,  -- PK
    s_name          FixedString(25),
    s_address       String, -- variable text, size 40
    s_nationkey     Int32,  -- FK n_nationkey
    s_phone         FixedString(15),
    s_acctbal       Decimal(18,2),
    s_comment       String, -- variable text, size 101
    CONSTRAINT pk CHECK s_suppkey >= 0
) engine = MergeTree ORDER BY (s_suppkey);

CREATE TABLE partsupp
(
    ps_partkey      Int32,  -- PK(1), FK p_partkey
    ps_suppkey      Int32,  -- PK(2), FK s_suppkey
    ps_availqty     Int32,  -- integer
    ps_supplycost   Decimal(18,2),
    ps_comment      String, -- variable text, size 199
    CONSTRAINT pk CHECK ps_partkey >= 0,
    CONSTRAINT c1 CHECK (ps_availqty >= 0 AND ps_supplycost >= 0)
) engine = MergeTree ORDER BY (ps_partkey, ps_suppkey);

CREATE TABLE customer
(
    c_custkey       Int32,  -- PK
    c_name          String, -- variable text, size 25
    c_address       String, -- variable text, size 40
    c_nationkey     Int32,  -- FK n_nationkey
    c_phone         FixedString(15),
    c_acctbal       Decimal(18,2),
    c_mktsegment    FixedString(10),
    c_comment       String, -- variable text, size 117
    CONSTRAINT pk CHECK c_custkey >= 0
) engine = MergeTree ORDER BY (c_custkey);

CREATE TABLE orders
(
    o_orderkey      Int32,  -- PK
    o_custkey       Int32,  -- FK c_custkey
    o_orderstatus   FixedString(1),
    o_totalprice    Decimal(18,2),
    o_orderdate     Date,
    o_orderpriority FixedString(15),
    o_clerk         FixedString(15),
    o_shippriority  Int32,  -- integer
    o_comment       String, -- variable text, size 79
    CONSTRAINT c1 CHECK o_totalprice >= 0
) engine = MergeTree ORDER BY (o_orderdate, o_orderkey);

CREATE TABLE lineitem
(
    l_orderkey      Int32,  -- PK(1), FK o_orderkey
    l_partkey       Int32,  -- FK ps_partkey
    l_suppkey       Int32,  -- FK ps_suppkey
    l_linenumber    Int32,  -- PK(2)
    l_quantity      Decimal(18,2),
    l_extendedprice Decimal(18,2),
    l_discount      Decimal(18,2),
    l_tax           Decimal(18,2),
    l_returnflag    FixedString(1),
    l_linestatus    FixedString(1),
    l_shipdate      Date,
    l_commitdate    Date,
    l_receiptdate   Date,
    l_shipinstruct  FixedString(25),
    l_shipmode      FixedString(10),
    l_comment       String, -- variable text size 44
    CONSTRAINT c1 CHECK (l_quantity >= 0 AND l_extendedprice >= 0 AND l_tax >= 0 AND l_shipdate <= l_receiptdate)
--  CONSTRAINT c2 CHECK (l_discount >= 0 AND l_discount <= 1)
) engine = MergeTree ORDER BY (l_shipdate, l_receiptdate, l_orderkey, l_linenumber);

CREATE TABLE nation
(
    n_nationkey     Int32,  -- PK
    n_name          FixedString(25),
    n_regionkey     Int32,  -- FK r_regionkey
    n_comment       String, -- variable text, size 152
    CONSTRAINT pk CHECK n_nationkey >= 0
) Engine = MergeTree ORDER BY (n_nationkey);

CREATE TABLE region
(
    r_regionkey     Int32,  -- PK
    r_name          FixedString(25),
    r_comment       String, -- variable text, size 152
    CONSTRAINT pk CHECK r_regionkey >= 0
) engine = MergeTree ORDER BY (r_regionkey);
