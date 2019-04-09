view: orders {
  derived_table: {
    sql_trigger_value: select count(*) from ${order_items.SQL_TABLE_NAME} ;;
    sql:
    SELECT e.order_id
        , e.user_id
        , e.vendor
        , e.transaction_at
        , max(e.process_at) as created_at
        , sum(e.quantity) as quantity
        , sum(e.sale_amount) as original_total
        , sum(e.krw_amount) as total
        , row_number() over(partition by e.user_id order by e.transaction_at) as order_sequence_number
    FROM ${order_items.SQL_TABLE_NAME} as e
    -- WHERE e.user_id NOT IN (SELECT user_id FROM google_sheets.filter_user)
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
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/19?UserID= {{value | encode_url}}"
      icon_url: "https://looker.com/favicon.ico"
    }
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
    sql: ${TABLE}.original_total ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}.total / 10000 ;;
    value_format_name: decimal_0
  }

  dimension: total_m {
    type: number
    description: "in 만원"
    sql: ${total} / 10000 ;;
    value_format_name: decimal_2
  }

  dimension: price_per_unit {
    type: number
    sql: ${total} / ${quantity} ;;
  }

  dimension: total_tier {
    type: tier
    tiers: [0, 10, 20, 50, 100, 200]
    sql: ${total_m} ;;
    style: integer
  }

  dimension: per_unit_tier {
    type: tier
    tiers: [0, 10, 20, 50, 100, 200]
    sql: ${price_per_unit} ;;
    style: integer
  }

  dimension: is_first_order {
    type: yesno
    sql: ${TABLE}.order_sequence_number = 1 ;;
  }

  dimension: is_refund {
    type: yesno
    sql: ${total} <= 0 ;;
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
    description: "only purchases, no returns"
    sql: ${total} ;;
    value_format_name: decimal_0
#     filters: {
#       field: total_m
#       value: ">0"
#     }
  }

  measure: average_order_value {
    type: average
    sql: ${total} ;;
    value_format_name: decimal_0
    filters: {
      field: total_m
      value: ">0"
    }
  }

  measure: distinct_orders {
    type: count_distinct
    sql_distinct_key: ${order_id} ;;
    sql: ${order_id} ;;
    drill_fields: [order_id, vendor, user_id, total]
  }

  measure: unique_user {
    type: count_distinct
    sql_distinct_key: ${user_id} ;;
    sql: ${user_id} ;;
  }

  measure: order_amount {
    type: sum
    description: "all inclusive (order/return)"
    sql: ${total} ;;
  }
}
