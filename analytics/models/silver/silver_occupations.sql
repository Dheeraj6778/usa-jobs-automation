select 
    occupational_series_code,
    occupational_series_name,
    cast(last_modified as timestamp) as last_modified,
    job_family,
    loaded_at
from {{ref('stg_occupational_series')}}
where is_disabled = 'No'