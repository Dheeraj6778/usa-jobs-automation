SELECT *
FROM {{ ref('silver_job_postings') }}
WHERE application_close_date < publication_start_date