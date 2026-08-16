select 
    security_clearance_code,
    security_clearance_name
from {{ref('silver_security_clearances')}}