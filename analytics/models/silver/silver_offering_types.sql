select 
    position_offering_type_code,
    position_offering_type_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_position_offeringtypes')}}
where is_disabled = 'No'