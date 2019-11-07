CREATE LANGUAGE plpythonu;

CREATE FUNCTION pytest()
     RETURNS text[]
   AS $$
     import sys
     return sys.executable, sys.path
   $$ LANGUAGE plpythonu;
select pytest();

DROP FUNCTION pytest();
DROP LANGUAGE plpythonu;
