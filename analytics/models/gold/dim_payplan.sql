
select 
    pay_plan_code,
    pay_plan_name
from {{ref('silver_payplans')}}