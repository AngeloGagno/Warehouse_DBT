with source as (
    select * from {{ref('stg_products')}}
)
select 
    -- surrogate key 
     {{ dbt_utils.generate_surrogate_key(['id_product']) }} as product_sk,
    -- normal key 
     id_product as product_nk,
     name_product,
     department_product,
     cast(price_product as numeric) as price_product_normlized,
     etl_inserted_at
     from source  