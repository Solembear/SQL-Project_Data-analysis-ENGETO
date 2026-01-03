-- OTÁZKA 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? --

-- Definuje počet nákupu mlieka / chleba pre jednotlivé obvetvia --

WITH food AS (
    SELECT 
        prim.payroll_year,
        prim.food_type,
        prim.food_price,
        prim.salary_by_industry,
        prim.industry
    FROM t_lukas_baksi_project_SQL_primary_final prim
    WHERE prim.food_type IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
),
years AS (
    SELECT 
        MIN(payroll_year) AS first_year,
        MAX(payroll_year) AS last_year
    FROM food
)
SELECT 
	f.industry,
    f.payroll_year,
    f.food_type,
    ROUND(f.salary_by_industry / f.food_price) AS quantity_affordable
FROM 
	food f
JOIN years y
    ON f.payroll_year = y.first_year
    OR f.payroll_year = y.last_year
ORDER BY 
	f.payroll_year,
	quantity_affordable DESC,
	f.food_type
	;



-- Definuje počet mlieka / chleba pre odvetvia priemerne za roky 2006 a 2018 --

SELECT 
    f.food_type,
    f.payroll_year,
    ROUND(AVG(f.salary_by_industry / f.food_price)) AS average_quantity
FROM t_lukas_baksi_project_SQL_primary_final f
WHERE 
	f.food_type IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
  AND f.payroll_year IN (
        (SELECT MIN(payroll_year)
         FROM t_lukas_baksi_project_SQL_primary_final
         WHERE food_type IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')),
        (SELECT MAX(payroll_year)
         FROM t_lukas_baksi_project_SQL_primary_final
         WHERE food_type IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový'))
    )
GROUP BY 
	f.food_type, 
	f.payroll_year
ORDER BY 
	f.food_type, 
	f.payroll_year;

-- zistenie prehľadu pre jednotlivú potravinu (chleba / mlieko) --

WITH food AS (
    SELECT 
        prim.payroll_year,
        prim.food_type,
        prim.food_price,
        prim.salary_by_industry,
        prim.industry
    FROM t_lukas_baksi_project_SQL_primary_final prim
    WHERE prim.food_type IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
),
years AS (
    SELECT 
        MIN(payroll_year) AS first_year,
        MAX(payroll_year) AS last_year
    FROM food
)
SELECT 
	f.industry,
    f.payroll_year,
    f.food_type,
    ROUND(f.salary_by_industry / f.food_price) AS quantity_affordable
FROM 
	food f
JOIN years y
    ON f.payroll_year = y.first_year
    OR f.payroll_year = y.last_year
WHERE 
	f.food_type = 'Chléb konzumní kmínový'     -- pre zistenie mlieka možno len zameniť v Klauzuli Where názov položky na 'Mléko polotučné pasterované' --
ORDER BY 
	f.payroll_year,
	quantity_affordable DESC,
	f.food_type
	;

