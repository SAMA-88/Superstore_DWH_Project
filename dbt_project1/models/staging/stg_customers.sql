{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ods', 'raw_customers') }}

)

select
    id as customer_id,
    first_name,
    last_name
from source