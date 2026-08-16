

select 
    salary_min_annual,
    salary_max_annual,
    rate_interval_code
from {{ref('silver_job_postings')}}
where  rate_interval_code='WC'