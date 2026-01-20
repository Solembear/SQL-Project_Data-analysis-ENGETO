CREATE TABLE t_lukas_baksi_project_SQL_secondary_final AS
SELECT 
	e."year" AS year,	
	e.country,
	e.gdp AS hdp,
	c.currency_code,
	e.gini,
	e.population,
	c.continent
FROM economies e
LEFT JOIN countries AS c 
	ON e.country = c.country 
WHERE
	e."year" BETWEEN 2006 AND 2018 AND c.continent = 'Europe'
ORDER BY
	e."year" ;
