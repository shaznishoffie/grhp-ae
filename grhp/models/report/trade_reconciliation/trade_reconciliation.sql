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
  COALESCE(int_trade_rpt.product_code, ext_trade_rpt.product_code) AS product_code,
  COALESCE(int_trade_rpt.price, ext_trade_rpt.price) AS price,
  COALESCE(int_trade_rpt.report_date, ext_trade_rpt.report_date) AS report_date,
  IFNULL(int_trade_rpt.total_buy_quantity, 0) AS int_buy_qty,
  IFNULL(ext_trade_rpt.total_buy_quantity, 0) AS ext_buy_qty,
  IFNULL(int_trade_rpt.total_buy_quantity, 0) - IFNULL(ext_trade_rpt.total_buy_quantity, 0) AS diff_buy_qty,
  IFNULL(int_trade_rpt.total_buy_quantity, 0) - IFNULL(ext_trade_rpt.total_buy_quantity, 0) > 0 AS is_buy_qty_diff,
  IFNULL(int_trade_rpt.total_sell_quantity, 0) AS int_sell_qty,
  IFNULL(ext_trade_rpt.total_sell_quantity, 0) AS ext_sell_qty,
  IFNULL(int_trade_rpt.total_sell_quantity, 0) - IFNULL(ext_trade_rpt.total_sell_quantity, 0) AS diff_sell_qty,
  IFNULL(int_trade_rpt.total_sell_quantity, 0) - IFNULL(ext_trade_rpt.total_sell_quantity, 0) > 0 AS is_sell_qty_diff
FROM {{ ref('external_trade_report_agg_product_price_daily') }} AS ext_trade_rpt
FULL OUTER JOIN {{ ref('internal_trade_report_agg_product_price_daily') }} AS int_trade_rpt
             ON ext_trade_rpt.product_code = int_trade_rpt.product_code
            AND ext_trade_rpt.price = int_trade_rpt.price
            AND ext_trade_rpt.report_date = int_trade_rpt.report_date
WHERE ext_trade_rpt.report_date = {{ exec_date() }}
  AND int_trade_rpt.report_date = {{ exec_date() }}
