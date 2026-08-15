

with cte_unnested as (

    select unnest(CodeList[1].ValidValue) as value
    from {{ source('bronze_codelists', 'agencysubelements') }}

) 
select value->>'Code' as agency_code,
       value->>'Value' as agency_name,
       value->>'ParentCode' as parent_code,
       value->>'Acronym' as acronym,
       value->>'LastModified' as last_modified,
       value->>'IsDisabled' as is_disabled,
       current_timestamp as loaded_at
from cte_unnested