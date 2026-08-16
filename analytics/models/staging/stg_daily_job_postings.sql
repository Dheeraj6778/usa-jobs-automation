-- models/staging/stg_daily_job_postings.sql
{{
    config(
        materialized='incremental',
        unique_key='control_number'
    )
}}



WITH raw_jobs AS (
    SELECT * FROM {{ source('bronze_jobs', 'daily_job_postings') }}
)

SELECT
    -- === IDENTIFIERS ===
    filename                                                 AS source_filename,
    MatchedObjectId                                          AS control_number,
    MatchedObjectDescriptor.PositionID                       AS position_id,
    MatchedObjectDescriptor.PositionURI                      AS position_url,
    MatchedObjectDescriptor.ApplyURI[1]                      AS apply_url,

    -- === JOB DETAILS ===
    MatchedObjectDescriptor.PositionTitle                    AS position_title,
    MatchedObjectDescriptor.QualificationSummary             AS qualification_summary,
    MatchedObjectDescriptor.UserArea.Details.JobSummary      AS job_summary,
    MatchedObjectDescriptor.UserArea.Details.MajorDuties[1]  AS major_duties,
    MatchedObjectDescriptor.UserArea.Details.Education       AS education,
    MatchedObjectDescriptor.UserArea.Details.Requirements    AS requirements,
    MatchedObjectDescriptor.UserArea.Details.Evaluations     AS evaluations,

    -- === ORGANIZATION ===
    MatchedObjectDescriptor.OrganizationName                 AS organization_name,
    MatchedObjectDescriptor.DepartmentName                   AS department_name,
    MatchedObjectDescriptor.UserArea.Details.SubAgencyName   AS sub_agency_name,
    MatchedObjectDescriptor.UserArea.Details.OrganizationCodes AS organization_codes,
    MatchedObjectDescriptor.UserArea.Details.AgencyMarketingStatement AS agency_marketing_statement,

    -- === LOCATION ===
    MatchedObjectDescriptor.PositionLocationDisplay          AS location_display,
    MatchedObjectDescriptor.PositionLocation[1].LocationName AS location_name,
    MatchedObjectDescriptor.PositionLocation[1].CityName     AS city_name,
    MatchedObjectDescriptor.PositionLocation[1].CountryCode  AS country,
    MatchedObjectDescriptor.PositionLocation[1].CountrySubDivisionCode AS state,
    MatchedObjectDescriptor.PositionLocation[1].AddressLine  AS address_line,
    MatchedObjectDescriptor.PositionLocation[1].Latitude     AS latitude,
    MatchedObjectDescriptor.PositionLocation[1].Longitude    AS longitude,

    -- === SALARY ===
    MatchedObjectDescriptor.PositionRemuneration[1].MinimumRange     AS salary_min_raw,
    MatchedObjectDescriptor.PositionRemuneration[1].MaximumRange     AS salary_max_raw,
    MatchedObjectDescriptor.PositionRemuneration[1].RateIntervalCode AS rate_interval_code,
    MatchedObjectDescriptor.PositionRemuneration[1].Description      AS salary_description,

    -- === GRADE / PAY PLAN ===
    MatchedObjectDescriptor.JobGrade[1].Code                 AS pay_plan_code,
    MatchedObjectDescriptor.UserArea.Details.LowGrade        AS grade_low,
    MatchedObjectDescriptor.UserArea.Details.HighGrade       AS grade_high,
    MatchedObjectDescriptor.UserArea.Details.PromotionPotential AS promotion_potential,

    -- === JOB CLASSIFICATION ===
    MatchedObjectDescriptor.JobCategory[1].Code              AS job_category_code,
    MatchedObjectDescriptor.JobCategory[1].Name              AS job_category_name,

    -- === SCHEDULE & TYPE ===
    MatchedObjectDescriptor.PositionSchedule[1].Code         AS schedule_type_code,
    MatchedObjectDescriptor.PositionSchedule[1].Name         AS schedule_type_name,
    MatchedObjectDescriptor.PositionOfferingType[1].Code     AS offering_type_code,
    MatchedObjectDescriptor.PositionOfferingType[1].Name     AS offering_type_name,

    -- === DATES ===
    MatchedObjectDescriptor.PositionStartDate                AS position_start_date,
    MatchedObjectDescriptor.PositionEndDate                  AS position_end_date,
    MatchedObjectDescriptor.PublicationStartDate              AS publication_start_date,
    MatchedObjectDescriptor.ApplicationCloseDate              AS application_close_date,

    -- === WORK ARRANGEMENT ===
    MatchedObjectDescriptor.UserArea.Details.TeleworkEligible AS is_telework_eligible,
    MatchedObjectDescriptor.UserArea.Details.RemoteIndicator  AS is_remote,
    MatchedObjectDescriptor.UserArea.Details.TravelCode       AS travel_code,
    MatchedObjectDescriptor.UserArea.Details.Relocation       AS relocation_offered,

    -- === SECURITY & COMPLIANCE ===
    MatchedObjectDescriptor.UserArea.Details.SecurityClearance      AS security_clearance,
    MatchedObjectDescriptor.UserArea.Details.DrugTestRequired       AS drug_test_required,
    MatchedObjectDescriptor.UserArea.Details.PositionSensitivitiy   AS position_sensitivity,
    MatchedObjectDescriptor.UserArea.Details.FinancialDisclosure    AS financial_disclosure_required,
    MatchedObjectDescriptor.UserArea.Details.BargainingUnitStatus   AS is_bargaining_unit,

    -- === HIRING INFO ===
    MatchedObjectDescriptor.UserArea.Details.WhoMayApply.Name       AS who_may_apply,
    MatchedObjectDescriptor.UserArea.Details.WhoMayApply.Code       AS who_may_apply_code,
    MatchedObjectDescriptor.UserArea.Details.HiringPath             AS hiring_paths,
    MatchedObjectDescriptor.UserArea.Details.TotalOpenings          AS total_openings,
    MatchedObjectDescriptor.UserArea.Details.ServiceType            AS service_type,

    -- === APPLICATION DETAILS (for job application emails) ===
    MatchedObjectDescriptor.UserArea.Details.ApplyOnlineUrl         AS apply_online_url,
    MatchedObjectDescriptor.UserArea.Details.DetailStatusUrl        AS application_status_url,
    MatchedObjectDescriptor.UserArea.Details.HowToApply             AS how_to_apply,
    MatchedObjectDescriptor.UserArea.Details.WhatToExpectNext       AS what_to_expect_next,
    MatchedObjectDescriptor.UserArea.Details.RequiredDocuments      AS required_documents,

    -- === BENEFITS ===
    MatchedObjectDescriptor.UserArea.Details.Benefits               AS benefits,
    MatchedObjectDescriptor.UserArea.Details.BenefitsUrl            AS benefits_url,
    MatchedObjectDescriptor.UserArea.Details.OtherInformation       AS other_information,

    -- === CONTACT ===
    MatchedObjectDescriptor.UserArea.Details.AgencyContactPhone     AS agency_contact_phone,
    MatchedObjectDescriptor.UserArea.Details.AgencyContactEmail     AS agency_contact_email,
    MatchedObjectDescriptor.UserArea.Details.AgencyContactWebsite   AS agency_contact_website,

    -- === MULTI-VALUE ARRAYS (keep raw for silver layer to handle) ===
    MatchedObjectDescriptor.PositionLocation                        AS locations_raw,
    MatchedObjectDescriptor.JobCategory                             AS job_categories_raw,
    MatchedObjectDescriptor.UserArea.Details.AdjudicationType       AS adjudication_types,
    MatchedObjectDescriptor.UserArea.Details.MCOTags                AS mco_tags,

    -- === METADATA ===
    CURRENT_TIMESTAMP AS loaded_at

FROM raw_jobs
{% if is_incremental() %}
WHERE filename NOT IN (SELECT DISTINCT source_filename FROM {{ this }})
{% endif %}