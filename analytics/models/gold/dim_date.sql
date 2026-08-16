-- models/gold/dim_date.sql
{{
    config(materialized='table')
}}

WITH date_spine AS (
    SELECT UNNEST(
        generate_series(DATE '2017-01-01', DATE '2030-12-31', INTERVAL 1 DAY)
    )::DATE AS date_key
)

SELECT
    date_key,
    YEAR(date_key)                          AS year,
    MONTH(date_key)                         AS month,
    DAY(date_key)                           AS day,
    QUARTER(date_key)                       AS quarter,
    DAYOFWEEK(date_key)                     AS day_of_week,
    DAYNAME(date_key)                       AS day_name,
    MONTHNAME(date_key)                     AS month_name,
    WEEKOFYEAR(date_key)                    AS week_of_year,
    CASE WHEN DAYOFWEEK(date_key) IN (0, 6) THEN true ELSE false END AS is_weekend,
    -- federal fiscal year starts October 1
    CASE WHEN MONTH(date_key) >= 10
         THEN YEAR(date_key) + 1
         ELSE YEAR(date_key)
    END AS fiscal_year,
    CASE
        WHEN MONTH(date_key) >= 10 THEN MONTH(date_key) - 9
        ELSE MONTH(date_key) + 3
    END AS fiscal_month,
    CASE
    WHEN MONTH(date_key) IN (10, 11, 12) THEN 1
    WHEN MONTH(date_key) IN (1, 2, 3)    THEN 2
    WHEN MONTH(date_key) IN (4, 5, 6)    THEN 3
    WHEN MONTH(date_key) IN (7, 8, 9)    THEN 4
END AS fiscal_quarter
FROM date_spine