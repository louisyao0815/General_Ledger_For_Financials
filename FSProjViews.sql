-- gl_master source
-- Note: Ensure your underlying tables (gl, coa, entity_map) 
-- also use these lowercase column names.

--MASTER GENERAL LEDGER------
-- public.gl_master source
DROP VIEW IF EXISTS public.gl_master;
CREATE OR REPLACE VIEW public.gl_master
AS SELECT gl.journal_id,
    gl.account_code,
    coa.account_name,
    gl.date,
    EXTRACT(YEAR FROM gl.date) AS year,
    EXTRACT(MONTH FROM gl.date) AS month,
    gl.entity_id,
    entity_map.entity_name,
    entity_map.region,
    entity_map.country,
    entity_map.currency,
    coa.fs_subclass,
    coa.category,
    coa.normal_balance,
    coa.financial_statement,
    gl.debit,
    gl.credit,
    (gl.debit - gl.credit) AS amount,
    CASE 
    	WHEN coa.category IN ('Revenue', 'Liability', 'Equity') THEN (gl.debit - gl.credit) * -1
    	ELSE (gl.debit - gl.credit)
	END AS display_amount, -- creating negative signs for categories so positive value will display on PBI
    gl.description,
    gl.entry_type
  	FROM gl
    LEFT JOIN coa ON gl.account_code = coa.account_code
    LEFT JOIN entity_map ON entity_map.entity_id = gl.entity_id;


-------INCOME STATEMENT DATA EXCLUDING CLOSING ENTRIES----
DROP VIEW IF EXISTS public.is_data;
CREATE OR REPLACE VIEW public.is_data AS
	SELECT *
	FROM gl_master
	WHERE financial_statement = 'Income Statement' 
	  AND entry_type != 'Close'; -- exclude closing entries as IS only shows activity through year
	  
	  
	  
-------BALANCE SHEET DATA----
DROP VIEW IF EXISTS public.bs;
CREATE VIEW bs AS
	SELECT 
		fs_subclass, 
		account_name, 
		SUM(amount) AS total_amount 
	FROM gl_master
	WHERE financial_statement = 'Balance Sheet' 
	  AND country = 'UK'
	GROUP BY 
		fs_subclass, 
		account_name;
