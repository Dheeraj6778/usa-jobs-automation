select *
from {{ref('silver_job_postings')}}


SELECT count(*) FROM {{ source('bronze_jobs', 'daily_job_postings') }}


select 
    usajobsControlNumber as control_number,
    source_filename
from {{ source('bronze_historical', 'historical_job_postings') }}
limit 5