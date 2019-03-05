view: orders {
  derived_table: {
    sql_trigger_value: select count(*) from mysql_smile_ventures.rakuten_orders ;;
    sql: WITH normalized_event AS (
        SELECT
          re.order_id
          ,re.sku_number
          ,re.transaction_date as transaction_at
          ,ro.vendor
          ,min(ro.user_id) as user_id
          ,min(re.created_at) as created_at
          ,min(re.quantity) as quantity
          ,max(re.sale_amount) as sale_amount
          ,max(ro.total) as total

        FROM mysql_smile_ventures.rakuten_events as re
        LEFT JOIN mysql_smile_ventures.rakuten_orders as ro
        ON ro.order_id = re.order_id
          and ro.sku_number = re.sku_number
        WHERE ro.user_id IS NOT NULL and re.sale_amount IS NOT NULL

        GROUP BY 1, 2, 3, 4
      )

    SELECT e.order_id
        , e.user_id
        , e.vendor
        , e.transaction_at
        , min(e.created_at) as created_at
        , sum(e.quantity) as quantity
        , sum(e.sale_amount) as original_amount
        , sum(e.total) as total
        , row_number() over(partition by e.user_id order by e.transaction_at) as order_sequence_number
    FROM normalized_event as e
    WHERE e.user_id NOT IN (SELECT user_id FROM google_sheets.filter_user)
    GROUP BY 1, 2, 3, 4

    ;;
  }

  dimension: order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension_group: transaction_at {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.transaction_at ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension_group: created_at {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.created_at ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: original_amount {
    type: number
    sql: ${TABLE}.original_amount ;;
  }

  dimension: total {
    type: number
    description: "in 만원"
    sql: ${TABLE}.total / 10000 ;;
    value_format_name: decimal_0
  }

  dimension: is_first_order {
    type: yesno
    sql: ${TABLE}.order_sequence_number = 1 ;;
  }

  measure: count {
    type: count
  }

  measure: unique_user_count {
    type: count_distinct
    sql_distinct_key: ${user_id} ;;
    sql: ${user_id} ;;
  }

  measure: total_order_amount {
    type: sum
    sql: ${total} ;;
    value_format_name: decimal_0
  }

  measure: average_order_value {
    type: average
    sql: ${total} ;;
    value_format_name: decimal_0
  }
}
