with source_customers as (
    select * from {{ref('stg_customers')}}
),
replace_names as (
    select id_customer,
    REGEXP_REPLACE(name_customer, '^(?:Sr\.|Srta\.|Dr\.|Dra\.)\s*', '', 'i') as name_customer,
    email_customer,
    phonenum_customer,
    etl_inserted_at
    
    from source_customers
),
sales as (
    select * from {{ref('stg_sales')}}
)
select 
    s.id_customer,
    c.name_customer,
    s.sold_at,
    s.sales_value
    from sales s
    join replace_names c on s.id_customer = c.id_customer