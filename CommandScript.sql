select SUM(amount) FROM gl_master;


ALTER TABLE public.gl 
ALTER COLUMN date TYPE DATE 
USING date::DATE;

