with headquarters as (
  select * from {{ref('int_headquarters')}}
)
select headquarters_sk,   
  name_headquarters_formated,
  address_hash
  from headquarters