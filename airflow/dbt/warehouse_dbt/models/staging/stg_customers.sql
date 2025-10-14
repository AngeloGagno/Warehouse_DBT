with source as (
    select * from {{source('postgres_warehouse_dbt','clientes')}}
),
rename_columns as (
    select id_cliente as id_customer,
    nome as name_customer,
    email as email_customer,
    celular as phonenum_customer,
    current_timestamp as etl_inserted_at
    from source
)
select * from rename_columns