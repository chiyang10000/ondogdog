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
       C.relkind, C.relstorage
FROM pg_class C
         LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname = current_schema()
  AND C.relkind <> 'i'
  AND C.relstorage <> 'x' -- external table
ORDER BY pg_total_relation_size(C.oid) DESC;
