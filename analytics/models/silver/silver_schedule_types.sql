select 
    position_schedule_type_code,
    position_schedule_type_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_position_scheduletypes')}}
where is_disabled = 'No'