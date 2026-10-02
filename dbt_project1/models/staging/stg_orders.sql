{{
    config(
        materialized='view'
    )
}}

SELECT
    row_id,
    order_id,
    CAST(order_date AS TIMESTAMP) AS order_date,
    CAST(ship_date AS TIMESTAMP) AS ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
FROM {{ source('my_ods', 'ods_superstore') }}