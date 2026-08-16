select 
    distinct
    md5(coalesce(location_name, '') || coalesce(state, '') || coalesce(country, '')) as location_id,
    location_name,
    city_name,
    state,
    country
from {{ref('silver_job_postings')}}
where location_name is not null