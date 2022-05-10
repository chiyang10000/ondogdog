\set seg_num 4
\set scale_factor 10
\set ON_ERROR_STOP 1

-- TPC-H V2.6 -- FIXME
   -- OushuDB <= 4.5.2.0
   -- --force not working
   -- the output default to stdout
-- dbgen -fq -b $(dirname $(command -v dbgen))/dists.dss -T r > region.tbl

-- TPC-H V3 
   -- the output file was hard-coded as TABLE.tbl.STEP
-- dbgen -fq -b $(dirname $(command -v dbgen))/dists.dss -T r



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
    N_NAME CHAR(25),
    N_REGIONKEY INTEGER,
    N_COMMENT VARCHAR(152) )
    execute
        'rm -f nation.tbl; mkfifo nation.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -q -T n -s ':'scale_factor''&);'
    'cat nation.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_REGION (
    R_REGIONKEY INTEGER,
    R_NAME CHAR(25),
    R_COMMENT VARCHAR(152) )
    execute
        'rm -f region.tbl; mkfifo region.tbl;'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T r -s ':'scale_factor''&);'
    'cat region.tbl'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_PART (
    P_PARTKEY INTEGER,
    P_NAME VARCHAR(55),
    P_MFGR CHAR(25),
    P_BRAND CHAR(10),
    P_TYPE VARCHAR(25),
    P_SIZE INTEGER,
    P_CONTAINER CHAR(10),
    P_RETAILPRICE FLOAT,
    P_COMMENT VARCHAR(23) )
    execute
        'rm -f part.tbl.$((GP_SEGMENT_ID + 1)); mkfifo part.tbl.$((GP_SEGMENT_ID + 1));'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T P -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1)) &);'
    'cat part.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_SUPPLIER (
    S_SUPPKEY INTEGER,
    S_NAME CHAR(25),
    S_ADDRESS VARCHAR(40),
    S_NATIONKEY INTEGER,
    S_PHONE CHAR(15),
    S_ACCTBAL FLOAT,
    S_COMMENT VARCHAR(101) )
    execute
        'rm -f supplier.tbl.$((GP_SEGMENT_ID + 1)); mkfifo supplier.tbl.$((GP_SEGMENT_ID + 1));'
            '($GPHOME/bin/dbgen -q -b $GPHOME/bin/dists.dss -T s -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1)) &);'
    'cat supplier.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_PARTSUPP (
    PS_PARTKEY INTEGER,
    PS_SUPPKEY INTEGER,
    PS_AVAILQTY INTEGER,
    PS_SUPPLYCOST FLOAT,
    PS_COMMENT VARCHAR(199) )
    execute
        'rm -f partsupp.tbl.$((GP_SEGMENT_ID + 1)); mkfifo partsupp.tbl.$((GP_SEGMENT_ID + 1));'
            '($GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T S -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1)) &);'
    'cat partsupp.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_CUSTOMER (
    C_CUSTKEY INTEGER,
    C_NAME VARCHAR(25),
    C_ADDRESS VARCHAR(40),
    C_NATIONKEY INTEGER,
    C_PHONE CHAR(15),
    C_ACCTBAL FLOAT,
    C_MKTSEGMENT CHAR(10),
    C_COMMENT VARCHAR(117) )
    execute
        'rm -f customer.tbl.$((GP_SEGMENT_ID + 1)); mkfifo customer.tbl.$((GP_SEGMENT_ID + 1));'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T c -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1))" &);'
    'cat customer.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_ORDERS (
    O_ORDERKEY INT8 ,
    O_CUSTKEY INTEGER,
    O_ORDERSTATUS CHAR(1),
    O_TOTALPRICE FLOAT,
    O_ORDERDATE DATE,
    O_ORDERPRIORITY CHAR(15),
    O_CLERK CHAR(15),
    O_SHIPPRIORITY INTEGER,
    O_COMMENT VARCHAR(79) )
    execute
        'rm -f orders.tbl.$((GP_SEGMENT_ID + 1)); mkfifo orders.tbl.$((GP_SEGMENT_ID + 1));'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T O -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1))" &);'
    'cat orders.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');

CREATE EXTERNAL WEB TABLE E_LINEITEM (
    L_ORDERKEY INT8,
    L_PARTKEY INTEGER,
    L_SUPPKEY INTEGER,
    L_LINENUMBER INTEGER,
    L_QUANTITY FLOAT,
    L_EXTENDEDPRICE FLOAT,
    L_DISCOUNT FLOAT,
    L_TAX FLOAT,
    L_RETURNFLAG CHAR(1),
    L_LINESTATUS CHAR(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT CHAR(25),
    L_SHIPMODE CHAR(10),
    L_COMMENT VARCHAR(44) )
    EXECUTE
        'rm -f lineitem.tbl.$((GP_SEGMENT_ID + 1)); mkfifo lineitem.tbl.$((GP_SEGMENT_ID + 1));'
            '(bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T L -s ':'scale_factor'' -C ':'seg_num'' -S $((GP_SEGMENT_ID + 1))" &);'
    'cat lineitem.tbl.$((GP_SEGMENT_ID + 1))'
    on :seg_num format 'text' (delimiter '|');
