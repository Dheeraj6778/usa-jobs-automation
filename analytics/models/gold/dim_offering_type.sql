SELECT
    position_offering_type_code,
    position_offering_type_name
FROM {{ ref('silver_offering_types') }}