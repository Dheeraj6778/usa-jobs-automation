
select 
    agency_code,
    agency_name,
    parent_code,
    acronym,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_agency_subelements')}}
where is_disabled = 'No'