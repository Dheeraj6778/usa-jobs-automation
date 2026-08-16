select 
    country_subdivision_code,
    country_subdivision_name,
    cast(last_modified as timestamp) as last_modified,
    parent_code,
    loaded_at
from {{ref('stg_country_subdivisions')}}
where is_disabled = 'No'