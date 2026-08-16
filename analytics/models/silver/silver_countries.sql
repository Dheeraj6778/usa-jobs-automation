select 
    country_code,
    country_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_countries')}}
where is_disabled = 'No'