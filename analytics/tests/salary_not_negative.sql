select *
from {{ref('silver_job_postings')}}
where salary_min_annual<0 or salary_max_annual<0