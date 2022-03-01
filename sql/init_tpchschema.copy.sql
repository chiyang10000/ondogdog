\timing on
copy nation from '/opt/db_data/tpch1g/nation/nation.tbl' delimiter '|';
copy region  from '/opt/db_data/tpch1g/region/region.tbl' delimiter '|';
copy part from '/opt/db_data/tpch1g/part/part.tbl' delimiter '|';
copy supplier from '/opt/db_data/tpch1g/supplier/supplier.tbl' delimiter '|';
copy partsupp from '/opt/db_data/tpch1g/partsupp/partsupp.tbl' delimiter '|';
copy customer from '/opt/db_data/tpch1g/customer/customer.tbl' delimiter '|';
copy orders from '/opt/db_data/tpch1g/orders/orders.tbl' delimiter '|';
copy lineitem from '/opt/db_data/tpch1g/lineitem/lineitem.tbl' delimiter '|';
create view revenue0 (supplier_no, total_revenue) as
        select
                l_suppkey,
                sum(l_extendedprice * (1 - l_discount))
        from
                lineitem
        where
                l_shipdate >= date '1996-01-01'
                and l_shipdate < date '1996-01-01' + interval '3 month'
        group by
                l_suppkey;
