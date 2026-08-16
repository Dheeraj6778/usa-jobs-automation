select 
    control_number,

    -- dimension foreign keys
    agency_code,
    job_category_code as occupational_series_code,
    pay_plan_code,
    schedule_type_code,
    offering_type_code,
    travel_code,
    cast(publication_start_date as date) as publication_date_key,
    cast(application_close_date as date) as close_date_key,
    md5(coalesce(location_name, '') || coalesce(state, '') || coalesce(country, '')) as location_id,

    -- measures
    salary_min,
    salary_max,
    salary_min_annual,
    salary_max_annual,
    grade_low,
    grade_high,
    promotion_potential,
    posting_duration_days,

    --flags
    is_remote,
    is_telework_eligible,
    relocation_offered,
    drug_test_required,
    financial_disclosure_required,
    is_bargaining_unit,

    --descriptive
    position_title,
    position_id,
    position_url,
    apply_url,
    organization_name,
    department_name,
    sub_agency_name,
    security_clearance,
    who_may_apply,
    hiring_paths,
    service_type,

    --text fields
    job_summary,
    qualification_summary,
    major_duties,
    education,
    requirements,
    how_to_apply,
    required_documents,
    benefits,

    --contact
    agency_contact_email,
    agency_contact_phone,
    agency_contact_website,

    -- dates
    publication_start_date,
    application_close_date,
    position_start_date,
    position_end_date,

    -- metadata
    loaded_at


from {{ref('silver_job_postings')}}