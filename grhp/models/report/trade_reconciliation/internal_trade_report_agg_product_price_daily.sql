{{
  config(
    materialized = "incremental",
    incremental_strategy = "insert_overwrite",
    partitions = [exec_date()],
    require_partition_filter = true,
    partition_by = {
      "field": "report_date",
      "data_type": "date",
      "granularity": "day"
    },
    pre_hook = "alter table if exists {{ this }} set options (require_partition_filter = false)",
    post_hook = "alter table if exists {{ this }} set options (require_partition_filter = true)"
  )
}}

SELECT
  product_code,
  price,
  report_date,
  SUM(buy_quantity) AS total_buy_quantity,
  SUM(sell_quantity) AS total_sell_quantity,
FROM {{ ref('internal_trade_report') }}
WHERE report_date = {{ exec_date() }}
GROUP BY
  product_code,
  price,
  report_date
