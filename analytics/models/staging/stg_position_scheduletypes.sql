with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'positionscheduletypes') }}

)
select value->>'Code' as position_schedule_type_code,
       value->>'Value' as position_schedule_type_name,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       current_timestamp as loaded_at
from cte_unnested