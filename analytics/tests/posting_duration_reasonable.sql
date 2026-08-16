SELECT *
FROM {{ ref('silver_job_postings') }}
WHERE posting_duration_days < 0
   OR posting_duration_days > 365