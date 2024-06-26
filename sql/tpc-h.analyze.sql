\timing on
ANALYZE nation;
ANALYZE region;
ANALYZE part;
ANALYZE supplier;
ANALYZE partsupp;
ANALYZE customer ;
ANALYZE orders;
ANALYZE lineitem;

SELECT nspname || '.' || relname AS "relation",
       pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size",
       pg_size_pretty(pg_relation_size(C.oid)) AS "rel_size",
       reltuples::numeric, relpages,
       -- C.relstorage,
       C.relkind
FROM pg_class C
         LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname = current_schema()
  AND C.relkind <> 'i'
  and relname in ('lineitem', 'orders', 'customer',
                  'partsupp', 'part', 'supplier',
                  'region', 'nation')
  -- AND C.relstorage <> 'x' -- external table
ORDER BY pg_total_relation_size(C.oid) DESC;
