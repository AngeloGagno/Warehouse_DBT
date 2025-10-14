with source as (
    select * from {{source('postgres_warehouse_dbt','matrizes')}}
),
rename_columns as (
    select 
    id_matriz as id_headquarters,
    nome as name_headquarters,
    endereco as address_headquarters,
    current_timestamp as etl_inserted_at
    from source
)
select * from rename_columns