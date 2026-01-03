-- OTÁZKA 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? --

SELECT 
    t1.payroll_year AS year_prev,
    t2.payroll_year AS year_next,
	ROUND(														
        ((t2.avg_salary - t1.avg_salary) / t1.avg_salary) * 100, 2) AS salary_growth_pct,		-- percentuálny rast miezd
    ROUND(															
        ((t2.avg_price - t1.avg_price) / t1.avg_price) * 100, 2) AS price_growth_pct,			-- percentuálny rast cien potravín
    ROUND(
        (((t2.avg_price - t1.avg_price) / t1.avg_price) * 100) - (((t2.avg_salary - t1.avg_salary) / t1.avg_salary) * 100), 2) AS difference_pct  	-- rozdiel medzi rastom cien a rastom miezd --
FROM (
    SELECT 
        payroll_year,
        AVG(salary_by_industry) AS avg_salary,
        AVG(food_price) AS avg_price
    FROM 
    	t_lukas_baksi_project_SQL_primary_final
    GROUP BY 
    	payroll_year
) t1
JOIN (
    SELECT 
        payroll_year,
        AVG(salary_by_industry) AS avg_salary,
        AVG(food_price) AS avg_price
    FROM 
    	t_lukas_baksi_project_SQL_primary_final
    GROUP BY 
    	payroll_year
) t2
    ON t2.payroll_year = t1.payroll_year + 1
ORDER BY year_prev;

