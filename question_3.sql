-- OTÁZKA 2: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst) --

-- Výpočet priemernej zmeny ceny (v %) za rok --

SELECT 
    p1.food_type,
    ROUND(AVG(((p2.food_price - p1.food_price) / p1.food_price) * 100), 2) 
        AS avg_yearly_increase_pct,
    '%' AS percent
FROM t_lukas_baksi_project_SQL_primary_final p1
JOIN t_lukas_baksi_project_SQL_primary_final p2
    ON p1.food_type = p2.food_type
    AND p2.payroll_year = p1.payroll_year + 1
GROUP BY 
	p1.food_type, percent
ORDER BY 
	avg_yearly_increase_pct;

