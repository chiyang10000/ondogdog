CREATE LANGUAGE plpythonu;

CREATE FUNCTION pytest()
     RETURNS integer
   AS $$
     import pandas
     return 12
   $$ LANGUAGE plpythonu;
select pytest();

DROP FUNCTION pytest();
DROP LANGUAGE plpythonu;
