{{
  config(
    materialized='table',
    partition_by={'field': 'event_date', 'data_type': 'date'},
    cluster_by = ['event_name']
  )
}}

WITH base AS (
    SELECT *
    FROM {{ ref('base_funnel_analysis') }}
)

SELECT * FROM base