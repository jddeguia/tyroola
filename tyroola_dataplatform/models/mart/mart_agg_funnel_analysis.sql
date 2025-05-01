{{
  config(
    materialized='table',
    partition_by={'field': 'event_date', 'data_type': 'date'},
    cluster_by = ['event_name']
  )
}}

WITH mart AS (
    SELECT *
    FROM {{ ref('mart_funnel_analysis') }}
),

aggregates AS (
    SELECT 
        event_date,
        event_name,
        product_name,
        brand,
        utm_source,
        utm_medium,
        utm_campaign,
        SUM(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS users_viewed_product,
        SUM(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS users_added_to_cart,
        SUM(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS users_started_checkout,
        SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS users_completed_purchase
    FROM mart
    GROUP BY ALL
),

conversion_rates AS (
    SELECT *,
        ROUND(SAFE_DIVIDE(users_added_to_cart, users_viewed_product), 2) AS view_to_cart_rate,
        ROUND(SAFE_DIVIDE(users_started_checkout, users_added_to_cart), 2) AS cart_to_checkout_rate,
        ROUND(SAFE_DIVIDE(users_completed_purchase, users_started_checkout), 2) AS checkout_to_purchase_rate,
        ROUND(SAFE_DIVIDE(users_completed_purchase, users_viewed_product), 2) AS overall_conversion_rate
    FROM aggregates
)

SELECT * FROM conversion_rates

        

