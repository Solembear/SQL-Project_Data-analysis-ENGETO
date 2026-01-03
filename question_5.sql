/*
OTÁZKA 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
*/

WITH base AS (
    SELECT 
        s.year,
        s.hdp::NUMERIC,
        pf.salary,
        pf.food_price
    FROM t_lukas_baksi_project_SQL_secondary_final s
    LEFT JOIN (
        SELECT 
            payroll_year AS year,
            ROUND(AVG(salary_by_industry), 2) AS salary,
            ROUND(AVG(food_price), 2) AS food_price
        FROM t_lukas_baksi_project_SQL_primary_final
        GROUP BY payroll_year
    ) pf ON s.year = pf.year
    WHERE s.country = 'Czech Republic' AND s.hdp IS NOT NULL
),
year_pairs AS (
    SELECT 
        b1.year AS year_prev,
        b2.year AS year_next,
        b1.hdp AS hdp_prev,
        b2.hdp AS hdp_next,
        b1.salary AS salary_prev,
        b2.salary AS salary_next,
        b1.food_price AS price_prev,
        b2.food_price AS price_next
    FROM base b1
    JOIN base b2 ON b2.year = b1.year + 1
),
growth AS (
    SELECT 
        year_prev,
        year_next,
        ROUND(((hdp_next - hdp_prev) / hdp_prev) * 100, 2) AS hdp_growth_pct,
        ROUND(((salary_next - salary_prev) / salary_prev) * 100, 2) AS salary_growth_pct,
        ROUND(((price_next - price_prev) / price_prev) * 100, 2) AS price_growth_pct
    FROM year_pairs
)
SELECT 
    year_prev,
    year_next,
    hdp_growth_pct,
    salary_growth_pct,
    price_growth_pct,
    CASE 
     	WHEN hdp_growth_pct > 5 THEN 'HDP ▲▲'
    	WHEN hdp_growth_pct > 0 THEN 'HDP ▲'
    	WHEN hdp_growth_pct < 0 THEN 'HDP ▼'
    	ELSE 'beze změny'
    END AS corr_hdp,
    CASE
    	WHEN salary_growth_pct > 5 THEN 'mzdy ▲▲'
    	WHEN salary_growth_pct > 0 THEN 'mzdy ▲'
    	WHEN salary_growth_pct < 0 THEN 'mzdy ▼'
    	ELSE 'beze změny'
    END AS corr_salary,
    CASE
    	WHEN price_growth_pct > 5 THEN 'ceny ▲▲'
    	WHEN price_growth_pct > 0 THEN 'ceny ▲'
    	WHEN price_growth_pct < 0 THEN 'ceny ▼'
    	ELSE 'beze změny'
    END AS corr_salary
FROM growth
WHERE price_growth_pct IS NOT NULL
ORDER BY year_prev;
