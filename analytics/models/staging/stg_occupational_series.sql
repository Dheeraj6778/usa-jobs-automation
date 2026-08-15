
with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'occupationalseries') }}

)
select value->>'Code' as occupational_series_code,
       value->>'Value' as occupational_series_name,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       value->>'JobFamily' as job_family,
       current_timestamp as loaded_at
from cte_unnested