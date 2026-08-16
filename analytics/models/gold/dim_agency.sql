SELECT
    agency_code,
    agency_name,
    parent_code,
    acronym
FROM {{ ref('silver_agencies') }}