with source as (
    select * from {{ref('stg_customers')}}
),
replace_names as (
    select id_customer,
    REGEXP_REPLACE(name_customer, '^(?:Sr\.|Srta\.|Dr\.|Dra\.)\s*', '', 'i') as name_customer,
    email_customer,
    phonenum_customer,
    etl_inserted_at
    
    from source
)
select * from replace_names