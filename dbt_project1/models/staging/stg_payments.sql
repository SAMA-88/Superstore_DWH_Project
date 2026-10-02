{{
    config(
        materialized='view'
    )
}}

SELECT
    row_id,
    order_id,
    sales,
    quantity,
    discount,
    profit
FROM {{ source('my_ods', 'ods_superstore') }}
WHERE order_id IS NOT NULL