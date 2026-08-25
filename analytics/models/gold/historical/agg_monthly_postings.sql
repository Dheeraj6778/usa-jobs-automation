SELECT
    DATE_TRUNC('month', position_open_date) AS month,
    department_name,
    COUNT(*) AS total_postings,
    AVG(salary_min_annual) AS avg_min_salary,
    AVG(salary_max_annual) AS avg_max_salary,
    AVG(posting_duration_days) AS avg_posting_duration,
    SUM(CASE WHEN is_telework_eligible THEN 1 ELSE 0 END) AS telework_postings
FROM {{ ref('silver_historical_jobs') }}
WHERE position_open_date IS NOT NULL
GROUP BY 1, 2