\set seg_num 4
\set scale_factor 1

-- Only works for TPC-H 2.6, with `-N -n` specifying step


DROP EXTERNAL WEB TABLE IF EXISTS e_nation;
DROP EXTERNAL WEB TABLE IF EXISTS e_customer;
DROP EXTERNAL WEB TABLE IF EXISTS e_region;
DROP EXTERNAL WEB TABLE IF EXISTS e_part;
DROP EXTERNAL WEB TABLE IF EXISTS e_supplier;
DROP EXTERNAL WEB TABLE IF EXISTS e_partsupp;
DROP EXTERNAL WEB TABLE IF EXISTS e_orders;
DROP EXTERNAL WEB TABLE IF EXISTS e_lineitem;

CREATE EXTERNAL WEB TABLE e_nation (N_NATIONKEY INTEGER ,
    N_NAME VARCHAR(25) ,
    N_REGIONKEY INTEGER ,
    N_COMMENT VARCHAR(152))
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T n -s ':'scale_factor''"'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_REGION ( R_REGIONKEY INTEGER ,
    R_NAME VARCHAR(25) ,
    R_COMMENT VARCHAR(152))
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T r -s ':'scale_factor''"'
    on 1 format 'text' (delimiter '|');

CREATE external web TABLE e_PART ( P_PARTKEY INTEGER ,
    P_NAME VARCHAR(55) ,
    P_MFGR VARCHAR(25) ,
    P_BRAND VARCHAR(10) ,
    P_TYPE VARCHAR(25) ,
    P_SIZE INTEGER ,
    P_CONTAINER VARCHAR(10) ,
    P_RETAILPRICE FLOAT ,
    P_COMMENT VARCHAR(23) )
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T P -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_SUPPLIER ( S_SUPPKEY INTEGER ,
    S_NAME VARCHAR(25) ,
    S_ADDRESS VARCHAR(40) ,
    S_NATIONKEY INTEGER ,
    S_PHONE VARCHAR(15) ,
    S_ACCTBAL FLOAT ,
    S_COMMENT VARCHAR(101) )
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T s -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_PARTSUPP ( PS_PARTKEY INTEGER ,
    PS_SUPPKEY INTEGER ,
    PS_AVAILQTY INTEGER ,
    PS_SUPPLYCOST FLOAT ,
    PS_COMMENT VARCHAR(199) )
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T S -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_CUSTOMER ( C_CUSTKEY INTEGER ,
    C_NAME VARCHAR(25) ,
    C_ADDRESS VARCHAR(40) ,
    C_NATIONKEY INTEGER ,
    C_PHONE VARCHAR(15) ,
    C_ACCTBAL FLOAT ,
    C_MKTSEGMENT VARCHAR(10) ,
    C_COMMENT VARCHAR(117) )
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T c -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');

CREATE external web TABLE e_ORDERS ( O_ORDERKEY INT8 ,
    O_CUSTKEY INTEGER ,
    O_ORDERSTATUS VARCHAR(1) ,
    O_TOTALPRICE FLOAT ,
    O_ORDERDATE DATE,
    O_ORDERPRIORITY VARCHAR(15) ,
    O_CLERK VARCHAR(15) ,
    O_SHIPPRIORITY INTEGER ,
    O_COMMENT VARCHAR(79) )
    execute 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T O -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');

CREATE EXTERNAL WEB TABLE E_LINEITEM ( L_ORDERKEY INT8 ,
    L_PARTKEY INTEGER ,
    L_SUPPKEY INTEGER ,
    L_LINENUMBER INTEGER ,
    L_QUANTITY FLOAT ,
    L_EXTENDEDPRICE FLOAT ,
    L_DISCOUNT FLOAT ,
    L_TAX FLOAT ,
    L_RETURNFLAG VARCHAR(1) ,
    L_LINESTATUS VARCHAR(1) ,
    L_SHIPDATE DATE ,
    L_COMMITDATE DATE ,
    L_RECEIPTDATE DATE ,
    L_SHIPINSTRUCT CHAR(25) ,
    L_SHIPMODE VARCHAR(10) ,
    L_COMMENT VARCHAR(44) )
    EXECUTE 'bash -c "$GPHOME/bin/dbgen -b $GPHOME/bin/dists.dss -T L -s ':'scale_factor'' -N ':'seg_num'' -n $((GP_SEGMENT_ID + 1))"'
    on :seg_num format 'text' (delimiter '|');
