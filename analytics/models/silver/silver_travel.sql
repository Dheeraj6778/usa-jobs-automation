select 
    travel_percentage_code,
    travel_percentage_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_travel_percentages')}}
where is_disabled = 'No'