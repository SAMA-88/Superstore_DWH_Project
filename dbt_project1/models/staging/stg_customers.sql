{{
    config(
        materialized='view'
    )
}}

SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM {{ source('my_ods', 'ods_superstore') }}
WHERE customer_id IS NOT NULL