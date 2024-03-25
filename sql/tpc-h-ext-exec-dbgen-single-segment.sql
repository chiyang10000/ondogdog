\set scale_factor 1
\set ON_ERROR_STOP 1

-- TPC-H V2.6 -- FIXME
   -- OushuDB <= 4.5.2.0
   -- --force not working
   -- the output default to stdout
-- dbgen -fq -b $(dirname $(command -v dbgen))/dists.dss -T r > region.tbl

-- TPC-H V3 
   -- the output file was hard-coded as TABLE.tbl.STEP
-- dbgen -fq -b $(dirname $(command -v dbgen))/dists.dss -T r
   -- -S requires >1



DROP EXTERNAL WEB TABLE IF EXISTS e_dbgen;
CREATE READABLE EXTERNAL WEB TABLE e_dbgen(work_dir text)
    EXECUTE 'test -f $GPHOME/bin/dbgen || exit 1;'
            'pwd;'
    on master format 'text';
select * from e_dbgen;
DROP EXTERNAL WEB TABLE IF EXISTS e_dbgen;
CREATE READABLE EXTERNAL WEB TABLE e_dbgen(dbgen text)
    EXECUTE '$GPHOME/bin/dbgen -h 2>&1| head -n2;'
    on master format 'text';
select * from e_dbgen;



DROP EXTERNAL WEB TABLE IF EXISTS e_nation;
DROP EXTERNAL WEB TABLE IF EXISTS e_customer;
DROP EXTERNAL WEB TABLE IF EXISTS e_region;
DROP EXTERNAL WEB TABLE IF EXISTS e_part;
DROP EXTERNAL WEB TABLE IF EXISTS e_supplier;
DROP EXTERNAL WEB TABLE IF EXISTS e_partsupp;
DROP EXTERNAL WEB TABLE IF EXISTS e_orders;
DROP EXTERNAL WEB TABLE IF EXISTS e_lineitem;

CREATE EXTERNAL WEB TABLE e_nation (
    N_NATIONKEY INTEGER,
    N_NAME TEXT,
    N_REGIONKEY INTEGER,
    N_COMMENT TEXT )
    execute
        'rm -f nation.tbl; mkfifo nation.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -q -T n -s ':'scale_factor''&);'
    'cat nation.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_REGION (
    R_REGIONKEY INTEGER,
    R_NAME TEXT,
    R_COMMENT TEXT )
    execute
        'rm -f region.tbl; mkfifo region.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T r -s ':'scale_factor''&);'
    'cat region.tbl'
    on 1 format 'text' (delimiter '|');
select * from e_REGION; -- ensure workable

CREATE external web TABLE e_PART (
    P_PARTKEY INTEGER,
    P_NAME TEXT,
    P_MFGR TEXT,
    P_BRAND TEXT,
    P_TYPE TEXT,
    P_SIZE INTEGER,
    P_CONTAINER TEXT,
    P_RETAILPRICE FLOAT,
    P_COMMENT TEXT )
    execute
        'rm -f part.tbl; mkfifo part.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T P -s ':'scale_factor''  &);'
    'cat part.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_SUPPLIER (
    S_SUPPKEY INTEGER,
    S_NAME TEXT,
    S_ADDRESS TEXT,
    S_NATIONKEY INTEGER,
    S_PHONE TEXT,
    S_ACCTBAL FLOAT,
    S_COMMENT TEXT )
    execute
        'rm -f supplier.tbl; mkfifo supplier.tbl;'
            '($GPHOME/bin/dbgen -q -b $GPHOME/bin/dists.dss -T s -s ':'scale_factor''  &);'
    'cat supplier.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_PARTSUPP (
    PS_PARTKEY INTEGER,
    PS_SUPPKEY INTEGER,
    PS_AVAILQTY INTEGER,
    PS_SUPPLYCOST FLOAT,
    PS_COMMENT TEXT )
    execute
        'rm -f partsupp.tbl; mkfifo partsupp.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T S -s ':'scale_factor''  &);'
    'cat partsupp.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_CUSTOMER (
    C_CUSTKEY INTEGER,
    C_NAME TEXT,
    C_ADDRESS TEXT,
    C_NATIONKEY INTEGER,
    C_PHONE TEXT,
    C_ACCTBAL FLOAT,
    C_MKTSEGMENT TEXT,
    C_COMMENT TEXT )
    execute
        'rm -f customer.tbl; mkfifo customer.tbl;'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T c -s ':'scale_factor'' " &);'
    'cat customer.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_ORDERS (
    O_ORDERKEY INT8 ,
    O_CUSTKEY INTEGER,
    O_ORDERSTATUS TEXT,
    O_TOTALPRICE FLOAT,
    O_ORDERDATE DATE,
    O_ORDERPRIORITY TEXT,
    O_CLERK TEXT,
    O_SHIPPRIORITY INTEGER,
    O_COMMENT TEXT )
    execute
        'rm -f orders.tbl; mkfifo orders.tbl;'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T O -s ':'scale_factor'' " &);'
    'cat orders.tbl'
    on 1 format 'text' (delimiter '|');

CREATE EXTERNAL WEB TABLE E_LINEITEM (
    L_ORDERKEY INT8,
    L_PARTKEY INTEGER,
    L_SUPPKEY INTEGER,
    L_LINENUMBER INTEGER,
    L_QUANTITY FLOAT,
    L_EXTENDEDPRICE FLOAT,
    L_DISCOUNT FLOAT,
    L_TAX FLOAT,
    L_RETURNFLAG TEXT,
    L_LINESTATUS TEXT,
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT TEXT,
    L_SHIPMODE TEXT,
    L_COMMENT TEXT )
    EXECUTE
        'rm -f lineitem.tbl; mkfifo lineitem.tbl;'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T L -s ':'scale_factor'' " &);'
    'cat lineitem.tbl'
    on 1 format 'text' (delimiter '|');
