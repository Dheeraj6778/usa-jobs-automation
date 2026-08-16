select 
    occupational_series_code,
    occupational_series_name,
    job_family
from {{ref('silver_occupations')}}