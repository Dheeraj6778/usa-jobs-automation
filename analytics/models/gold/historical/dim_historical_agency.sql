-- models/gold/historical/dim_historical_agency.sql

SELECT DISTINCT
    TRIM(agency_code) AS agency_code,
    agency_name,
    department_code,
    department_name,
    sub_agency_name,
    agency_level
FROM {{ ref('silver_historical_jobs') }}
WHERE agency_code IS NOT NULL