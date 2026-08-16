select *
from {{ref('silver_job_postings')}}


SELECT count(*) FROM {{ source('bronze_jobs', 'daily_job_postings') }}


select location_id,
        count(*)
from {{ref('dim_location')}}
group by location_id
having count(*)>1