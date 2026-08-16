select 
    position_schedule_type_code,
    position_schedule_type_name
from {{ref('silver_schedule_types')}}