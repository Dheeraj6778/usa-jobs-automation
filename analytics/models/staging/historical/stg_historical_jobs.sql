{{
  config(
    materialized = 'incremental',
    unique_key = 'control_number',
    )
}}

select 
    usajobsControlNumber as control_number,
    filename as source_filename,
    announcementNumber as announcement_number,
    positionTitle as position_title,
    hiringAgencyCode as agency_code,
    hiringAgencyName as agency_name,
    hiringDepartmentCode as department_code,
    hiringDepartmentName as department_name,
    hiringSubelementName as sub_agency_name,
    agencyLevel as agency_level,

    -- location
    positionlocations[1].positionLocationCity as city_name,
    positionlocations[1].positionLocationState as state,
    positionlocations[1].positionLocationCountry as country,

    -- salary
    minimumSalary as salary_min,
    maximumSalary as salary_max,
    salaryType as salary_type,

    -- grade / pay plan
    payScale as pay_plan_code,
    minimumGrade as grade_low,
    maximumGrade as grade_high,
    promotionPotential as promotion_potential,

    -- job classification
    jobcategories[1].series as job_category_code,

    -- schedule & type
    workSchedule as work_schedule,
    appointmentType as appointment_type,

    -- dates
    positionOpenDate as position_open_date,
    positionCloseDate as position_close_date,
    positionExpireDate as position_expire_date,
    positionOpeningStatus as position_status,

    -- work arrangement
    teleworkEligible as is_telework_eligible,
    travelRequirement as travel_requirement,
    relocationExpensesReimbursed as relocation_offered,

    -- security & compliance
    securityClearanceRequired as security_clearance_required,
    securityClearance as security_clearance,
    drugTestRequired as drug_test_required,
    supervisoryStatus as is_supervisory,

    -- hiring info
    whoMayApply as who_may_apply,
    totalOpenings as total_openings,
    serviceType as service_type,
    vendor as vendor,

    -- closing info
    announcementClosingTypeCode as closing_type_code,
    announcementClosingTypeDescription as closing_type_description,
    disableAppyOnline as disable_apply_online,

    -- multi-value arrays
    positionlocations as locations_raw,
    jobcategories as job_categories_raw,
    hiringpaths as hiring_paths_raw,

    -- metadata
    CURRENT_TIMESTAMP as loaded_at

from {{ source('bronze_historical', 'historical_job_postings') }}

{% if is_incremental() %}
where filename not in (select distinct source_filename from {{ this }})
{% endif %}