SELECT * FROM master_clean_expenses LIMIT 10;
UPDATE master_clean_expenses
SET cat = 'ребенок'
WHERE YEAR(created) = 2025
  AND MONTH(created) = 1 
  AND price = 1250.00
  AND user_id = 2;
UPDATE master_clean_expenses
SET cat = 'ребенок'
WHERE YEAR(created) = 2025 
  AND MONTH(created) = 11 
  AND price = 436
  AND user_id = 2;
INSERT INTO master_clean_expenses (user_id, cat, item, price, created)
VALUES (2, 'ребенок', 'школа', 950.00, '2025-09-10');
INSERT INTO master_clean_expenses (user_id, cat, item, price, created)
VALUES (2, 'ребенок', 'школа', 750.00, '2026-01-21');
INSERT INTO master_clean_expenses (user_id, cat, item, price, created)
VALUES 
(2, 'кафе', 'кафе', 50.00, '2026-05-17'),
(2, 'услуги', 'стоматолог', 180, '2026-05-04'),
(2, 'услуги', 'врач', 220, '2026-05-08'),
(2, 'услуги', 'врач', 120, '2026-05-07'),
(2, 'услуги', 'эстетика', 50, '2026-05-07')
;
DELETE FROM master_clean_expenses 
WHERE
created = '2025-08-24' AND
item = ‘концерт' AND
price = 225;


SELECT cat,
SUM(CASE WHEN created BETWEEN '2025-05-01' AND '2025-06-01' AND user_id = 2 THEN price ELSE 0 END) AS expenses_2025,
SUM(CASE WHEN created BETWEEN '2026-05-01' AND '2026-06-01' AND user_id = 2 THEN price ELSE 0 END) AS expenses_2026,
SUM(price) AS total
FROM master_clean_expenses
GROUP BY ROLLUP(cat);



CREATE TABLE abc_25 AS
WITH base AS(
SELECT cat, SUM(price) AS total
FROM master_clean_expenses
WHERE created BETWEEN '2025-01-01' AND '2025-12-31'
AND user_id = 2
GROUP BY cat),
total_cum AS(
SELECT cat, total, SUM(total) OVER(ORDER BY total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100/ SUM(total) OVER() AS cumulat
FROM base)
SELECT cat, ROUND(total, 2) AS total, ROUND(cumulat, 2) AS cumulat,
CASE 
	WHEN cumulat < 80 THEN 'A'
	WHEN cumulat < 95 THEN 'B'
	ELSE 'C'
	END AS abc_category
FROM total_cum;


CREATE TABLE metrics_25 AS
WITH basic AS (SELECT cat, MONTH(created) AS num_month, SUM(price) AS sum_month
FROM master_clean_expenses
WHERE YEAR(created) = 2025
GROUP BY cat, MONTH(created)),
metrics AS 
(
SELECT cat, ROUND(AVG(sum_month), 2) AS avg_monthly,
ROUND(STDDEV(sum_month), 2) AS std_monthly
FROM basic 
GROUP BY cat
)
SELECT 
cat,
avg_monthly AS avg_month,
std_monthly AS sd,
CASE 
WHEN avg_monthly > 0 THEN ROUND((std_monthly / avg_monthly) * 100, 2)
ELSE 0 
END AS cv
FROM metrics
ORDER BY cv DESC;

SELECT cat, total, cumulat, abc_category, cv
FROM abc_25 LEFT JOIN metrics_25 USING(cat)
ORDER BY abc_category, total DESC, cv DESC;

SELECT cat, 
SUM(CASE WHEN MONTH(created) = 01 THEN price END) AS january,
SUM(CASE WHEN MONTH(created) = 02 THEN price END) AS february,
SUM(CASE WHEN MONTH(created) = 03 THEN price END) AS march,
SUM(CASE WHEN MONTH(created) = 04 THEN price END) AS april,
SUM(CASE WHEN MONTH(created) = 05 THEN price END) AS may,
SUM(CASE WHEN MONTH(created) = 06 THEN price END) AS june,
SUM(CASE WHEN MONTH(created) = 07 THEN price END) AS jule,
SUM(CASE WHEN MONTH(created) = 08 THEN price END) AS august,
SUM(CASE WHEN MONTH(created) = 09 THEN price END) AS september,
SUM(CASE WHEN MONTH(created) = 10 THEN price END) AS october,
SUM(CASE WHEN MONTH(created) = 11 THEN price END) AS november,
SUM(CASE WHEN MONTH(created) = 12 THEN price END) AS december,
SUM(price) AS total
FROM master_clean_expenses mce LEFT JOIN abc_25 a USING(cat)
WHERE YEAR(mce.created) = 2025
AND mce.user_id = 2
AND a.abc_category = 'A'
GROUP BY ROLLUP(cat);

SELECT cat, 
SUM(CASE WHEN MONTH(created) = 01 THEN price END) AS january,
SUM(CASE WHEN MONTH(created) = 02 THEN price END) AS february,
SUM(CASE WHEN MONTH(created) = 03 THEN price END) AS march,
SUM(CASE WHEN MONTH(created) = 04 THEN price END) AS april,
SUM(CASE WHEN MONTH(created) = 05 THEN price END) AS may,
SUM(CASE WHEN MONTH(created) = 06 THEN price END) AS june,
SUM(CASE WHEN MONTH(created) = 07 THEN price END) AS jule,
SUM(CASE WHEN MONTH(created) = 08 THEN price END) AS august,
SUM(CASE WHEN MONTH(created) = 09 THEN price END) AS september,
SUM(CASE WHEN MONTH(created) = 10 THEN price END) AS october,
SUM(CASE WHEN MONTH(created) = 11 THEN price END) AS november,
SUM(CASE WHEN MONTH(created) = 12 THEN price END) AS december,
SUM(price) AS total
FROM master_clean_expenses
WHERE YEAR(created) = 2025
AND user_id = 2
GROUP BY ROLLUP(cat);

 SELECT WEEKDAY(created) AS week_day, cat, round(SUM(price), 2) AS total
 FROM master_clean_expenses
 WHERE YEAR(created) = 2025 AND
 user_id = 2 AND
 cat IN ('вкусняшки', 'кафе' )
 GROUP BY WEEKDAY(created), cat
 ORDER BY 1;

 SELECT WEEKDAY(created) AS week_day, cat, SUM(price) AS total,
 ROW_NUMBER() OVER(PARTITION BY cat ORDER BY SUM(price) DESC) AS cat_rank
 FROM master_clean_expenses
 WHERE YEAR(created) = 2025 AND
 user_id = 2 AND
 cat IN ('молочка', 'мясо', 'овощи')
 GROUP BY WEEKDAY(created), cat
 ORDER BY 4;

WITH years AS(
SELECT cat, 
SUM(CASE WHEN created BETWEEN '2023-01-01' AND '2023-05-31' THEN price ELSE 0 END) AS month5_2023,
SUM(CASE WHEN created BETWEEN '2024-01-01' AND '2024-05-31' THEN price ELSE 0 END) AS month5_2024,
SUM(CASE WHEN created BETWEEN '2025-01-01' AND '2025-05-31' THEN price ELSE 0 END) AS month5_2025,
SUM(CASE WHEN created BETWEEN '2026-01-01' AND '2026-05-31' THEN price ELSE 0 END) AS month5_2026
FROM master_clean_expenses
WHERE user_id = 2
GROUP BY cat)
SELECT cat, month5_2023, month5_2024,
month5_2025, month5_2026,
ROUND((month5_2024 - month5_2023) * 100 / NULLIF(month5_2023, 0), 2) AS grow_rate_24,
ROUND((month5_2025 - month5_2024) * 100 / NULLIF(month5_2024, 0), 2) AS grow_rate_25,
ROUND((month5_2026 - month5_2025) * 100 / NULLIF(month5_2025, 0), 2) AS grow_rate_26
FROM years;

