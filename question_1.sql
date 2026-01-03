-- OTÁZKA 1 : Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? --

-- Vytvorenie základnej porovnávacej tabuľky --

WITH changes AS (
    SELECT DISTINCT
        t1.industry,
        t1.payroll_year AS year_prev,
        t2.payroll_year AS year_next,
        t1.salary_by_industry AS salary_prev,
        t2.salary_by_industry AS salary_next,
        (t2.salary_by_industry - t1.salary_by_industry) AS salary_change
    FROM t_lukas_baksi_project_SQL_primary_final t1
    JOIN t_lukas_baksi_project_SQL_primary_final t2
        ON t1.industry = t2.industry
        AND t2.payroll_year = t1.payroll_year + 1
)
SELECT 
    industry,
    year_prev,
    year_next,
    salary_prev,
    salary_next,
    salary_change,
    CASE 
        WHEN salary_change > 0 THEN 'INCREASE'
        WHEN salary_change < 0 THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS change_label
FROM 
	changes
ORDER BY 
	industry, 
	year_prev;

-- Vytvorenie prehľadovej tabuľky, ktorá definuje odvetvie s najvyšším počtom poklesov v porovnaní rokov --

WITH changes AS (
    SELECT DISTINCT
        t1.industry,
        t1.payroll_year AS year_prev,
        t2.payroll_year AS year_next,
        (t2.salary_by_industry - t1.salary_by_industry) AS salary_change
    FROM 
    	t_lukas_baksi_project_SQL_primary_final t1
    JOIN t_lukas_baksi_project_SQL_primary_final t2
        ON t1.industry = t2.industry
        AND t2.payroll_year = t1.payroll_year + 1
)
SELECT 
    industry,
    COUNT(*) AS decrease_count
FROM 
	changes
WHERE 
	salary_change < 0
GROUP BY 
	industry
ORDER BY 
	decrease_count DESC;

-- Vytvorenie prehľadovej tabuľky, ktorá definuje roky, v ktorých jednotlivé odvetvia vykazovali pokles miezd --

WITH changes AS (
    SELECT DISTINCT
        t1.industry,
        t1.payroll_year AS year_prev,
        t2.payroll_year AS year_next,
        t1.salary_by_industry AS salary_prev,
        t2.salary_by_industry AS salary_next,
        (t2.salary_by_industry - t1.salary_by_industry) AS salary_change
    FROM t_lukas_baksi_project_SQL_primary_final t1
    JOIN t_lukas_baksi_project_SQL_primary_final t2
        ON t1.industry = t2.industry
        AND t2.payroll_year = t1.payroll_year + 1
)
SELECT 
    industry,
    year_prev,
    year_next,
    salary_prev,
    salary_next,
    salary_change,
    CASE 
        WHEN salary_change > 0 THEN 'INCREASE'
        WHEN salary_change < 0 THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS change_label
FROM 
	changes
WHERE 
	salary_change < 0
ORDER BY 
	year_prev,	
	industry 
	;

