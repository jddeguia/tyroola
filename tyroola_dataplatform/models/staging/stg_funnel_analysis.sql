{{
  config(
    materialized='table',
    partition_by={'field': 'event_date', 'data_type': 'date'}
  )
}}

WITH base AS (
    SELECT *
    FROM {{ ref('base_funnel_analysis') }}
)

SELECT * FROM base