{{
    config(
        materialized='table'
    )
}}

SELECT
    row_id,
    order_id,
    sales,
    quantity,
    discount,
    profit
FROM {{ ref('stg_payments') }}