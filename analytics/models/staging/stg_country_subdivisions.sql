with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'countrysubdivisions') }}

)
select value->>'Code' as country_subdivision_code,
       value->>'Value' as country_subdivision_name,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       value->>'ParentCode' as parent_code,
       current_timestamp as loaded_at
from cte_unnested