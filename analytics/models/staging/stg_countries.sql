with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'countries') }}

)
select value->>'Code' as country_code,
       value->>'Value' as country_name,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       current_timestamp as loaded_at
from cte_unnested