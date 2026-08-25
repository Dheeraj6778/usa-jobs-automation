-- models/silver/historical/silver_historical_postings.sql
{{
    config(
        materialized='incremental',
        unique_key='control_number'
    )
}}

WITH cleaned AS (
    SELECT
        -- identifiers
        control_number::VARCHAR AS control_number,
        announcement_number,

        -- job details
        NULLIF(TRIM(position_title), '') AS position_title,

        -- organization
        TRIM(agency_code) AS agency_code,
        agency_name,
        TRIM(department_code) AS department_code,
        department_name,
        sub_agency_name,
        agency_level,

        -- location
        NULLIF(TRIM(city_name), '') AS city_name,
        NULLIF(TRIM(state), '') AS state,
        NULLIF(TRIM(country), '') AS country,

        -- salary (cast + normalize to annual)
        CAST(salary_min AS DECIMAL(12,2)) AS salary_min,
        CAST(salary_max AS DECIMAL(12,2)) AS salary_max,
        salary_type,
        CASE
            WHEN salary_type = 'Per Year' THEN CAST(salary_min AS DECIMAL(12,2))
            WHEN salary_type = 'Per Hour' THEN CAST(salary_min AS DECIMAL(12,2)) * 2080
            ELSE NULL
        END AS salary_min_annual,
        CASE
            WHEN salary_type = 'Per Year' THEN CAST(salary_max AS DECIMAL(12,2))
            WHEN salary_type = 'Per Hour' THEN CAST(salary_max AS DECIMAL(12,2)) * 2080
            ELSE NULL
        END AS salary_max_annual,

        -- grade / pay plan
        NULLIF(TRIM(pay_plan_code), '') AS pay_plan_code,
        grade_low,
        grade_high,
        promotion_potential::VARCHAR AS promotion_potential,

        -- job classification
        job_category_code,

        -- schedule & type
        NULLIF(TRIM(work_schedule), '') AS work_schedule,
        NULLIF(TRIM(appointment_type), '') AS appointment_type,

        -- dates
        CAST(position_open_date AS DATE) AS position_open_date,
        CAST(position_close_date AS DATE) AS position_close_date,
        CAST(position_expire_date AS DATE) AS position_expire_date,
        NULLIF(TRIM(position_status), '') AS position_status,
        DATEDIFF('day',
            CAST(position_open_date AS DATE),
            CAST(position_close_date AS DATE)
        ) AS posting_duration_days,

        -- work arrangement (clean booleans)
        CASE WHEN is_telework_eligible = 'Y' THEN true ELSE false END AS is_telework_eligible,
        NULLIF(TRIM(travel_requirement), 'NA') AS travel_requirement,
        CASE WHEN relocation_offered = 'Y' THEN true ELSE false END AS relocation_offered,

        -- security & compliance (clean booleans)
        CASE WHEN security_clearance_required = 'Y' THEN true ELSE false END AS security_clearance_required,
        NULLIF(TRIM(security_clearance), 'NA') AS security_clearance,
        CASE WHEN drug_test_required = 'Y' THEN true ELSE false END AS drug_test_required,
        CASE WHEN is_supervisory = 'Y' THEN true ELSE false END AS is_supervisory,

        -- hiring info
        NULLIF(TRIM(who_may_apply), '') AS who_may_apply,
        total_openings,
        NULLIF(TRIM(service_type), 'NA') AS service_type,
        vendor,

        -- closing info
        closing_type_code,
        NULLIF(TRIM(closing_type_description), 'NA') AS closing_type_description,

        -- multi-value arrays
        locations_raw,
        job_categories_raw,
        hiring_paths_raw,

        -- metadata
        source_filename,
        loaded_at,

        -- dedup
        ROW_NUMBER() OVER (
            PARTITION BY control_number
            ORDER BY loaded_at DESC
        ) AS row_num

    FROM {{ ref('stg_historical_jobs') }}

    {% if is_incremental() %}
    WHERE loaded_at > (SELECT MAX(loaded_at) FROM {{ this }})
    {% endif %}
)

SELECT * EXCLUDE (row_num)
FROM cleaned
WHERE row_num = 1