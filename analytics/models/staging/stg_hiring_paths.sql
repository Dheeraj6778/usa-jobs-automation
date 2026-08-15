with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'hiringpaths') }}

)
select value->>'Code' as hiring_path_code,
       value->>'Value' as hiring_path_name,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       current_timestamp as loaded_at
from cte_unnested