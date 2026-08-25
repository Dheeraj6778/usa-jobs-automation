SELECT DISTINCT
    MD5(
        COALESCE(city_name, '') ||
        COALESCE(state, '') ||
        COALESCE(country, '')
    ) AS location_key,
    city_name,
    state,
    country
FROM {{ ref('silver_historical_jobs') }}
WHERE city_name IS NOT NULL
   OR state IS NOT NULL