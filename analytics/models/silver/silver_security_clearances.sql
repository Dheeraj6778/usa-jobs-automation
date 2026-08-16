select 
    security_clearance_code,
    security_clearance_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_security_clearances')}}
where is_disabled = 'No'