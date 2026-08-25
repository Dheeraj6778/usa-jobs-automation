SELECT
    DATE_TRUNC('year', position_open_date) AS year,
    pay_plan_code,
    grade_low,
    COUNT(*) AS posting_count,
    AVG(salary_min_annual) AS avg_min_salary,
    AVG(salary_max_annual) AS avg_max_salary,
    MIN(salary_min_annual) AS lowest_salary,
    MAX(salary_max_annual) AS highest_salary
FROM {{ ref('silver_historical_jobs') }}
WHERE salary_min_annual > 0
  AND position_open_date IS NOT NULL
GROUP BY 1, 2, 3