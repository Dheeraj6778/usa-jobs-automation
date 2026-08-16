SELECT
    travel_percentage_code,
    travel_percentage_name
FROM {{ ref('silver_travel') }}