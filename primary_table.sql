CREATE TABLE t_lukas_baksi_project_SQL_primary_final AS	
WITH payroll_table AS (	
	SELECT
		cpib.code AS industry_code,
		cpib."name" AS industry,
		ROUND(AVG(cpr.value),2) AS salary_by_industry,  -- výpočet priemernej mzdy k odvetviu --
		cpr.payroll_year
	FROM
		czechia_payroll AS cpr
	LEFT JOIN czechia_payroll_industry_branch AS cpib  -- filter industry branch --
			ON cpr.industry_branch_code = cpib.code 
	LEFT JOIN czechia_payroll_value_type AS cpvt  -- filter Priemernej hrubej mzdy na zamestnanca --
			ON cpvt.code = cpr.value_type_code 
	WHERE
		cpvt.code = 5958 AND cpr.industry_branch_code IS NOT NULL 
	GROUP BY
		cpr.payroll_year,
		industry,
		industry_code 
),
price_table AS(
	SELECT 
		cpc."name" AS food_type, 
		ROUND(AVG(cp.value::NUMERIC),2) AS food_price, -- výpočet priemernej ceny jedla --
		date_part('year',cp.date_from) AS food_year 
	FROM
		czechia_price AS cp
	LEFT JOIN czechia_price_category AS cpc   -- priradenie názvu jedla --
			ON cpc.code = cp.category_code 
	WHERE 
		cp.region_code IS NULL -- definovanie celorep. hodnôt --
	GROUP BY
		food_type,
		food_year
)
SELECT *
FROM payroll_table AS pt 
INNER JOIN price_table AS prt
	ON pt.payroll_year = prt.food_year 
ORDER BY 
	pt.payroll_year;

