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

funnel_step AS (
    SELECT *,
        CASE 
            WHEN event_name = 'view_item' THEN 1
            WHEN event_name = 'add_to_cart' THEN 2
            WHEN event_name = 'begin_checkout' THEN 3
            WHEN event_name = 'purchase' THEN 4
            ELSE 0
        END AS funnel_step 
    FROM mart
),

minutes_to_next_event AS (
    SELECT *,
        TIMESTAMP_DIFF(
            LEAD(TIMESTAMP(event_timestamp)) OVER (PARTITION BY user_pseudo_id, session_id ORDER BY event_timestamp),
            TIMESTAMP(event_timestamp),
            MINUTE
        ) AS minutes_to_next_event,
    FROM funnel_step
),

event_counts AS (
    SELECT *,
        SUM(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS users_viewed_product,
        SUM(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS users_added_to_cart,
        SUM(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS users_started_checkout,
        SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS users_completed_purchase
    FROM minutes_to_next_event
    GROUP BY ALL
),

time_metrics AS (
    SELECT *,
        AVG(CASE WHEN funnel_step = 1 THEN minutes_to_next_event END) AS avg_view_to_cart_minutes,
        AVG(CASE WHEN funnel_step = 2 THEN minutes_to_next_event END) AS avg_cart_to_checkout_minutes,
        AVG(CASE WHEN funnel_step = 3 THEN minutes_to_next_event END) AS avg_checkout_to_purchase_minutes,
    FROM event_counts
    GROUP BY ALL
)

SELECT * FROM time_metrics
        

