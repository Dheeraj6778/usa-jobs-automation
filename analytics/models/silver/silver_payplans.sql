select 
    pay_plan_code,
    pay_plan_name,
    cast(last_modified as timestamp) as last_modified,
    loaded_at
from {{ref('stg_payplans')}}
where is_disabled = 'No'