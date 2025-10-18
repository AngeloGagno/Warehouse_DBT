-- models/marts/dim/dim_headquarters.sql
with base as (
    select 
        id_headquarters,
        replace(name_headquarters,'Matriz','') as name_headquarters_formated,
        address_headquarters,
        etl_inserted_at
    from {{ ref('stg_headquarters') }}
)
select 
    -- Surrogate Key
    {{ dbt_utils.generate_surrogate_key(['id_headquarters']) }} as headquarters_sk,
    
    -- Chave do negocio
    id_headquarters as headquarters_nk,
    name_headquarters_formated,
    md5(coalesce(address_headquarters, '')) as address_hash,
    
    etl_inserted_at
from base
