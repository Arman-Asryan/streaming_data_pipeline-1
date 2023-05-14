-- script to update DimDate table
CREATE OR REPLACE TABLE {project_id}.{dataset_id}.DimDate
AS
SELECT
  EXTRACT(YEAR FROM d)*10000+EXTRACT(MONTH FROM d)*100+EXTRACT(DAY FROM d) AS date_id,
  d AS full_date,
  EXTRACT(YEAR FROM d) AS year,
  EXTRACT(MONTH FROM d) AS month,
  EXTRACT(DAY FROM d) AS day,
  EXTRACT(WEEK FROM d) AS year_week,
  EXTRACT(YEAR FROM d) AS fiscal_year,
  FORMAT_DATE('%Q', d) as fiscal_qtr,
  FORMAT_DATE('%B', d) as month_name,
  FORMAT_DATE('%w', d) AS week_day,
  FORMAT_DATE('%A', d) AS day_name,
  (CASE WHEN FORMAT_DATE('%A', d) IN ('Sunday', 'Saturday') THEN 0 ELSE 1 END) AS day_is_weekday
FROM (
  SELECT
    *
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2023-01-01', CURRENT_DATE(), INTERVAL 1 DAY)) AS d)
ORDER BY date_id ASC;
