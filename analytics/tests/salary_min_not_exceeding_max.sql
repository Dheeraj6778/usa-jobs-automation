-- tests/salary_min_not_exceeding_max.sql
SELECT *
FROM {{ ref('silver_job_postings') }}
WHERE salary_min_annual > salary_max_annual