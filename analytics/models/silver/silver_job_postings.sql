{{
    config(
        materialized='incremental',
        unique_key='control_number',
        tags=['silver'],
        description='Silver layer for job postings data. This model cleans and transforms the raw job postings data into a structured format suitable for analytics.'
    )
}}


with cte_cleaned as (
    select 
        control_number,
        position_id,
        position_url,
        apply_url,
        
        -- - JOB DETAILS ---
        nullif(trim(position_title), '') as position_title,
        nullif(trim(qualification_summary), '') as qualification_summary,
        nullif(trim(job_summary), '') as job_summary,
        nullif(trim(major_duties), '') as major_duties,
        nullif(trim(education), '') as education,
        nullif(trim(requirements), '') as requirements,
        nullif(trim(evaluations), '') as evaluations,

        -- - ORGANIZATION ---
        organization_name,
        department_name,
        sub_agency_name,
        organization_codes

        -- LOCATION ---
        location_display,
        location_name,
        trim(split_part(location_name, ',', 1)) as city_name,
        country,
        state,
        address_line,

        -- SALARY ---
        CAST(salary_min_raw AS DECIMAL(12,2))   AS salary_min,
        CAST(salary_max_raw AS DECIMAL(12,2))   AS salary_max,
        rate_interval_code,
        salary_description,
        coalesce(
        case 
            rate_interval_code
            when 'PA' then CAST(salary_min_raw AS DECIMAL(12,2))
            when 'PH' then CAST(salary_min_raw AS DECIMAL(12,2))*2080
            else cast(0.00 AS DECIMAL(12,2))
        end,0) as salary_min_annual,
        coalesce(
            case 
            rate_interval_code
            when 'PA' then CAST(salary_max_raw AS DECIMAL(12,2))
            when 'PH' then CAST(salary_max_raw AS DECIMAL(12,2))*2080
            else cast(0.00 AS DECIMAL(12,2))
        end ,0
        ) as salary_max_annual
        ,

        -- GRADE / PAY PLAN ---
        pay_plan_code,
        grade_low,
        grade_high,
        promotion_potential,

        -- JOB CLASSIFICATION ---
        job_category_code,
        job_category_name,

        -- SCHEDULE TYPE ---
        schedule_type_code,
        schedule_type_name,
        offering_type_code,
        offering_type_name,

        -- DATES ---
        cast(position_start_date AS timestamp) as position_start_date,
        cast(position_end_date AS timestamp) as position_end_date,
        cast(publication_start_date AS timestamp) as publication_start_date,
        cast(application_close_date AS timestamp) as application_close_date,

        -- posting duration --
        datediff('day', cast(publication_start_date AS timestamp), cast(application_close_date AS timestamp)) as posting_duration_days,

        -- work arrangement --
        coalesce(is_telework_eligible, false) as is_telework_eligible,
        coalesce(is_remote, false) as is_remote,
        travel_code,
        case when relocation_offered='True' then true else false end as relocation_offered,

        -- security clearance --
        security_clearance,
        case when drug_test_required='True' then true else false end as drug_test_required,
        position_sensitivity,
        coalesce(financial_disclosure_required, false) as financial_disclosure_required,
        coalesce(is_bargaining_unit, false) as is_bargaining_unit,

        -- hiring info --

        nullif(trim(who_may_apply), '') as who_may_apply,
        who_may_apply_code,
        hiring_paths,
        total_openings,
        service_type,

        -- application details (for job application emails) --
        nullif(trim(apply_online_url), '') as apply_online_url,
        nullif(trim(application_status_url), '') as application_status_url,
        nullif(trim(how_to_apply), '') as how_to_apply,
        nullif(trim(what_to_expect_next), '') as what_to_expect_next,
        nullif(trim(required_documents), '') as required_documents,

        -- benefits --
        nullif(trim(benefits), '') as benefits,
        benefits_url,
        nullif(trim(other_information), '') as other_information,

        -- contact --
        agency_contact_phone,
        agency_contact_email,
        nullif(trim(agency_contact_website), '') as agency_contact_website,

        -- multi value arrays --
        locations_raw,
        job_categories_raw,
        adjudication_types,
        mco_tags,

        --metadata --
        source_filename,
        loaded_at

    from {{ref('stg_daily_job_postings')}}
)
select 
    * 
from cte_cleaned
{% if is_incremental() %}
    WHERE loaded_at > (SELECT MAX(loaded_at) FROM {{ this }})
{% endif %}
