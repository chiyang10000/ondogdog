 \timing off
-- set enforce_virtual_segment_number = 1;
 set gp_enable_agg_distinct = off;
-- set optimizer=on;
set new_executor=on;
-- set enable_groupagg=off; -- skip inferior SORT IMPL
set orc_enable_filter_pushdown=off;
-- set new_executor_enable_partitioned_hashjoin=off;
-- set new_executor_enable_partitioned_hashagg=off;
 set new_executor_external_sort_memory_limit=1024;

create or replace function check_oushudb_config(enforce_vseg_num int) returns text as
$$
declare
    version_str                  text;
    oushudb_version_number       text;
    oushudb_version_number_major text;
    oushudb_version_number_minor text;
begin
    select version() into version_str;
    raise notice '%', version_str;
    if not version_str ~ 'OushuDB' then
        return 'Non-OushuDB';
    end if;
    select regexp_replace(version(), '.*OushuDB (.*)Enter.*', E'\\1') into oushudb_version_number;
    select split_part(oushudb_version_number, '.', 1) into oushudb_version_number_major;
    select split_part(oushudb_version_number, '.', 2) into oushudb_version_number_minor;
   if oushudb_version_number_major >= 4 and oushudb_version_number_minor >= 4 then
        raise notice 'checked VIRTUAL CLUSTER %', oushudb_version_number;
        execute 'alter vcluster vc_default with (enforce_nvseg=' || enforce_vseg_num || ') in session;';
    else
        execute 'set enforce_virtual_segment_number = ' || enforce_vseg_num;
    end if;
    raise notice 'CHANGE enforce_nvseg to %', enforce_vseg_num;
   return oushudb_version_number;
end
$$ language plpgsql;
select check_oushudb_config(3);

 \set sql_prefix 'explain'
 \set sql_prefix 'explain analyze'
 \pset pager off

 create temp table ts as select now()::timestamp;
 \echo '\033[33mTime in TPC-H Power Test\033[0m'
 \timing on

:sql_prefix /*Q01*/ select l_returnflag, l_linestatus, sum(l_quantity)::bigint as sum_qty, sum(l_extendedprice)::bigint as sum_base_price, sum(l_extendedprice * (1 - l_discount))::bigint as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax))::bigint as sum_charge, avg(l_quantity)::bigint as avg_qty, avg(l_extendedprice)::bigint as avg_price, avg(l_discount)::bigint as avg_disc, count(*) as count_order from lineitem where l_shipdate <= date '1998-09-02' group by l_returnflag, l_linestatus order by l_returnflag, l_linestatus;
:sql_prefix /*Q02*/ select s_acctbal::bigint, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment from part, supplier, partsupp, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 15 and p_type like '%BRASS' and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'EUROPE' and ps_supplycost = ( select min(ps_supplycost) from partsupp, supplier, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'EUROPE' ) order by s_acctbal desc, n_name, s_name, p_partkey limit 100;
:sql_prefix /*Q03*/ select l_orderkey, sum(l_extendedprice * (1 - l_discount))::bigint as revenue, o_orderdate, o_shippriority from customer, orders, lineitem where c_mktsegment = 'BUILDING' and c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate < date '1995-03-15' and l_shipdate > date '1995-03-15' group by l_orderkey, o_orderdate, o_shippriority order by revenue desc, o_orderdate, l_orderkey limit 10;
:sql_prefix /*Q04*/ select o_orderpriority, count(*) as order_count from orders where o_orderdate >= date '1993-07-01' and o_orderdate < date '1993-10-01' and exists ( select * from lineitem where l_orderkey = o_orderkey and l_commitdate < l_receiptdate ) group by o_orderpriority order by o_orderpriority;
:sql_prefix /*Q05*/ select n_name, sum(l_extendedprice * (1 - l_discount))::bigint as revenue from customer, orders, lineitem, supplier, nation, region where c_custkey = o_custkey and l_orderkey = o_orderkey and l_suppkey = s_suppkey and c_nationkey = s_nationkey and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'ASIA' and o_orderdate >= date '1994-01-01' and o_orderdate < date '1995-01-01' group by n_name order by revenue desc;
:sql_prefix /*Q06*/ select sum(l_extendedprice * l_discount)::bigint as revenue from lineitem where l_shipdate >= date '1994-01-01' and l_shipdate < date '1995-01-01' and l_discount between 0.06 - 0.01 and 0.06 + 0.01 and l_quantity < 24;
:sql_prefix /*Q07*/ select supp_nation, cust_nation, l_year, sum(volume)::bigint as revenue from ( select n1.n_name as supp_nation, n2.n_name as cust_nation, extract(year from l_shipdate) as l_year, l_extendedprice * (1 - l_discount) as volume from supplier, lineitem, orders, customer, nation n1, nation n2 where s_suppkey = l_suppkey and o_orderkey = l_orderkey and c_custkey = o_custkey and s_nationkey = n1.n_nationkey and c_nationkey = n2.n_nationkey and ( (n1.n_name = 'FRANCE' and n2.n_name = 'GERMANY') or (n1.n_name = 'GERMANY' and n2.n_name = 'FRANCE') ) and l_shipdate between date '1995-01-01' and date '1996-12-31' ) as shipping group by supp_nation, cust_nation, l_year order by supp_nation, cust_nation, l_year;
:sql_prefix /*Q08*/ select o_year, (sum(case when nation = 'BRAZIL' then volume else 0 end) / sum(volume)) as mkt_share from ( select extract(year from o_orderdate) as o_year, l_extendedprice * (1 - l_discount) as volume, n2.n_name as nation from part, supplier, lineitem, orders, customer, nation n1, nation n2, region where p_partkey = l_partkey and s_suppkey = l_suppkey and l_orderkey = o_orderkey and o_custkey = c_custkey and c_nationkey = n1.n_nationkey and n1.n_regionkey = r_regionkey and r_name = 'AMERICA' and s_nationkey = n2.n_nationkey and o_orderdate between date '1995-01-01' and date '1996-12-31' and p_type = 'ECONOMY ANODIZED STEEL' ) as all_nations group by o_year order by o_year;
:sql_prefix /*Q09*/ select nation, o_year, sum(amount)::bigint as sum_profit from ( select n_name as nation, extract(year from o_orderdate) as o_year, l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount from part, supplier, lineitem, partsupp, orders, nation where s_suppkey = l_suppkey and ps_suppkey = l_suppkey and ps_partkey = l_partkey and p_partkey = l_partkey and o_orderkey = l_orderkey and s_nationkey = n_nationkey and p_name like '%green%' ) as profit group by nation, o_year order by nation, o_year desc;
:sql_prefix /*Q10*/ select c_custkey, c_name, sum(l_extendedprice) as revenue, sum(1 - l_discount) as average, c_acctbal, n_name, c_address, c_phone from customer, orders, lineitem, nation where c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate >= date'1993-10-01' and o_orderdate < date '1994-1-01' and l_returnflag = 'R' and c_nationkey = n_nationkey group by c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment order by c_custkey desc, c_name desc, revenue desc limit 20;
:sql_prefix /*Q11*/ select ps_partkey, sum(ps_supplycost * ps_availqty)::bigint as value from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'GERMANY' group by ps_partkey having sum(ps_supplycost * ps_availqty) > ( select sum(ps_supplycost * ps_availqty) * 0.0001000000 from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'ALGERIA' ) order by value desc;
:sql_prefix /*Q12*/ select l_shipmode, sum(case when o_orderpriority = '1-URGENT' or o_orderpriority = '2-HIGH' then 1 else 0 end) as high_line_count, sum(case when o_orderpriority <> '1-URGENT' and o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from orders, lineitem where o_orderkey = l_orderkey and l_shipmode in ('MAIL', 'SHIP') and l_commitdate < l_receiptdate and l_shipdate < l_commitdate and l_receiptdate >= date '1994-01-01' and l_receiptdate < date '1995-01-01' group by l_shipmode order by l_shipmode;
:sql_prefix /*Q13*/ select c_count, count(*) as custdist from ( select c_custkey, count(o_orderkey) from customer left outer join orders on c_custkey = o_custkey and o_comment not like '%special%requests%' group by c_custkey ) as c_orders (c_custkey, c_count) group by c_count order by custdist desc, c_count desc;
:sql_prefix /*Q14*/ select (100.00 * sum(case when p_type like 'PROMO%' then l_extendedprice * (1 - l_discount) else 0 end) / sum(l_extendedprice * (1 - l_discount)))::bigint as promo_revenue from lineitem, part where l_partkey = p_partkey and l_shipdate >= date '1995-09-01' and l_shipdate < date '1995-10-01';
:sql_prefix /*Q15*/ select s_suppkey, s_name, s_address, s_phone, total_revenue::bigint from supplier, revenue0 where s_suppkey = supplier_no and total_revenue = ( select max(total_revenue) from revenue0 ) order by s_suppkey;
:sql_prefix /*Q16*/ select p_brand, p_type, p_size, count(distinct ps_suppkey) as supplier_cnt from partsupp, part where p_partkey = ps_partkey and p_brand <> 'Brand#45' and p_type not like 'MEDIUM BURNISHED%' and p_size in (49, 14, 23, 45, 19, 3, 36, 9) and ps_suppkey not in ( select s_suppkey from supplier where s_comment like '%Customer%Complaints%' ) group by p_brand, p_type, p_size order by supplier_cnt desc, p_brand, p_type, p_size;
:sql_prefix /*Q17*/ select (sum(l_extendedprice) / 7.0)::bigint as avg_yearly from lineitem, part where p_partkey = l_partkey and p_brand = 'Brand#23' and p_container = 'MED BOX' and l_quantity < ( select 0.2 * avg(l_quantity) from lineitem where l_partkey = p_partkey );
:sql_prefix /*Q18*/ select c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice::bigint, sum(l_quantity)::bigint from customer, orders, lineitem where o_orderkey in ( select l_orderkey from lineitem group by l_orderkey having sum(l_quantity) > 300 ) and c_custkey = o_custkey and o_orderkey = l_orderkey group by c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice order by o_totalprice desc, o_orderdate limit 100;
:sql_prefix /*Q19*/ select sum(l_extendedprice* (1 - l_discount))::bigint as revenue from lineitem, part where ( p_partkey = l_partkey and p_brand = 'Brand#12' and p_container in ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG') and l_quantity >= 1 and l_quantity <= 1 + 10 and p_size between 1 and 5 and l_shipmode in ('AIR', 'AIR REG') and l_shipinstruct = 'DELIVER IN PERSON' ) or ( p_partkey = l_partkey and p_brand = 'Brand#23' and p_container in ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK') and l_quantity >= 10 and l_quantity <= 10 + 10 and p_size between 1 and 10 and l_shipmode in ('AIR', 'AIR REG') and l_shipinstruct = 'DELIVER IN PERSON' ) or ( p_partkey = l_partkey and p_brand = 'Brand#34' and p_container in ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG') and l_quantity >= 20 and l_quantity <= 20 + 10 and p_size between 1 and 15 and l_shipmode in ('AIR', 'AIR REG') and l_shipinstruct = 'DELIVER IN PERSON' );
:sql_prefix /*Q20*/ select s_name, s_address from supplier, nation where s_suppkey in ( select ps_suppkey from partsupp where ps_partkey in ( select p_partkey from part where p_name like 'forest%' ) and ps_availqty > ( select 0.5 * sum(l_quantity) from lineitem where l_partkey = ps_partkey and l_suppkey = ps_suppkey and l_shipdate >= date '1994-01-01' and l_shipdate < date '1995-01-01' ) ) and s_nationkey = n_nationkey and n_name = 'CANADA' order by s_name;
:sql_prefix /*Q21*/ select s_name, count(*) as numwait from supplier, lineitem l1, orders, nation where s_suppkey = l1.l_suppkey and o_orderkey = l1.l_orderkey and o_orderstatus = 'F' and l1.l_receiptdate > l1.l_commitdate and exists ( select * from lineitem l2 where l2.l_orderkey = l1.l_orderkey and l2.l_suppkey <> l1.l_suppkey ) and not exists ( select * from lineitem l3 where l3.l_orderkey = l1.l_orderkey and l3.l_suppkey <> l1.l_suppkey and l3.l_receiptdate > l3.l_commitdate ) and s_nationkey = n_nationkey and n_name = 'SAUDI ARABIA' group by s_name order by numwait desc, s_name limit 100;
:sql_prefix /*Q22*/ select cntrycode, count(*) as numcust, sum(c_acctbal)::bigint as totacctbal from ( select substring(c_phone from 1 for 2) as cntrycode, c_acctbal from customer where substring(c_phone from 1 for 2) in ('13', '31', '23', '29', '30', '18', '17') and c_acctbal > ( select avg(c_acctbal) from customer where c_acctbal > 0.00 and substring(c_phone from 1 for 2) in ('13', '31', '23', '29', '30', '18', '17') ) and not exists ( select * from orders where o_custkey = c_custkey ) ) as custsale group by cntrycode order by cntrycode;

 \timing off
 select 'Time of TPC-H Power Test', now()::timestamp - now from ts;

\q
 SELECT CAST(AVG (L_QUANTITY)  AS INTEGER) FROM LINEITEM, ORDERS WHERE L_ORDERKEY = O_ORDERKEY;
 SELECT CAST(AVG (P_RETAILPRICE*L_QUANTITY) AS INTEGER) FROM PART, LINEITEM WHERE P_PARTKEY = L_PARTKEY;
 SELECT CAST(SUM(L_QUANTITY) AS INTEGER) FROM PART, LINEITEM WHERE P_PARTKEY=L_SUPPKEY;
 SELECT N_NAME, CAST(AVG(C_ACCTBAL) AS INTEGER) FROM CUSTOMER, NATION WHERE C_NATIONKEY=N_NATIONKEY GROUP BY N_NAME order by n_name;
 SELECT CAST(SUM(C_ACCTBAL*2) AS BIGINT) FROM CUSTOMER WHERE C_CUSTKEY NOT IN ( SELECT O_CUSTKEY FROM ORDERS);
