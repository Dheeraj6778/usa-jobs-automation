select 
    trim(hiring_path_code) as hiring_path_code,
    trim(hiring_path_name) as hiring_path_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_hiring_paths')}}
where is_disabled = 'No'