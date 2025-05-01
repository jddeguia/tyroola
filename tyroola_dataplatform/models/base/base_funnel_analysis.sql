{{ config (materialized='view') }}

WITH funnel AS (
    SELECT
        DATE(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp))) AS event_date,
        COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN user_pseudo_id END) AS users_viewed_product,
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_pseudo_id END) AS users_added_to_cart,
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_pseudo_id END) AS users_started_checkout,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS users_completed_purchase
    FROM {{ source('public_dataset', 'events_*') }}
    GROUP BY ALL
),

summary AS (
    SELECT
        event_date,
        users_viewed_product,
        users_added_to_cart,
        users_started_checkout,
        users_completed_purchase,
        ROUND(SAFE_DIVIDE(users_added_to_cart, users_viewed_product), 2) AS view_to_cart_rate,
        ROUND(SAFE_DIVIDE(users_started_checkout, users_added_to_cart), 2) AS cart_to_checkout_rate,
        ROUND(SAFE_DIVIDE(users_completed_purchase, users_started_checkout), 2) AS checkout_to_purchase_rate,
        ROUND(SAFE_DIVIDE(users_completed_purchase, users_viewed_product), 2) AS overall_conversion_rate
    FROM funnel
)

SELECT * FROM summary
