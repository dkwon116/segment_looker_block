view: orders {
  derived_table: {
    sql_trigger_value: select count(*) from ${order_items.SQL_TABLE_NAME} ;;
    sql: WITH affiliate_commission as (
          SELECT
            pe.order_id
            , sum(pe.item_publisher_commission * c.rate) as commission
          FROM data_data_api_db.partnerize_events as pe
          LEFT JOIN ${currencies.SQL_TABLE_NAME} as c
            ON DATE(pe.transaction_date) = c.date AND c.unit = pe.currency
          WHERE pe.item_status = "p"
          GROUP BY 1

          union all

          SELECT
            re.order_id
            , SUM(re.commissions * c.rate) as commission
          FROM data_data_api_db.rakuten_events as re
          LEFT JOIN ${currencies.SQL_TABLE_NAME} as c
            ON DATE(re.transaction_date) = c.date AND c.unit = re.currency
          WHERE re.is_event = "N"
          -- AND re.order_id = "OMF180249912"
          GROUP BY 1
        ), orders as (
          SELECT e.order_id
            , e.user_id
            , e.vendor
            , e.transaction_at
            , e.is_confirmed
            , max(e.process_at) as created_at
            , sum(e.quantity) as quantity
            , sum(e.sale_amount) as original_total
            , sum(IF(e.order_type = "P", e.krw_amount, 0)) / 1000 as total
            , sum(IF(e.order_type = "R", e.krw_amount, 0)) / 1000 as total_return
            , row_number() over(partition by e.user_id order by e.transaction_at) as order_sequence_number
          FROM ${order_items.SQL_TABLE_NAME} as e
          GROUP BY 1, 2, 3, 4, 5
        )
        SELECT
          o.order_id
            , o.user_id
            , o.vendor
            , o.transaction_at
            , o.is_confirmed
            , o.created_at
            , o.quantity
            , o.original_total
            , o.total
            , o.total_return
            , o.order_sequence_number
            , c.commission / 1000 as commission
        FROM orders as o
        LEFT JOIN affiliate_commission as c
          ON o.order_id = c.order_id


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

  dimension: transaction_date {
    type: date
    sql: ${TABLE}.transaction_at ;;
    link: {
      label: "View {{value}} Products"
      url: "https://smileventures.au.looker.com/dashboards/41?date= {{value | encode_url}}"
      icon_url: "https://looker.com/favicon.ico"
    }
  }

  dimension_group: transaction_at {
    type: time
    timeframes: [raw, time, hour, day_of_week, day_of_month, date, week, month, quarter]
    sql: ${TABLE}.transaction_at ;;
  }

  dimension_group: created_at {
    type: time
    timeframes: [raw, time, date, week, month, quarter]
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
    sql: ${TABLE}.total ;;
    description: "in 천원"
    value_format_name: decimal_0
  }

  dimension: is_confirmed {
    type: yesno
    sql: ${TABLE}.is_confirmed ;;
  }

  dimension: total_return {
    type: number
    sql: ${TABLE}.total_return;;
    value_format_name: decimal_0
  }

  dimension: net_sales {
    type: number
    sql: ${total} + ${total_return} ;;
    value_format_name: decimal_0
  }

  dimension: price_per_unit {
    type: number
    sql: ${total} / ${quantity} ;;
  }

  dimension: total_tier {
    type: tier
    tiers: [0, 100, 300, 500, 1000, 2000]
    sql: ${total} ;;
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
    sql: ${total_return} <> 0 ;;
  }

  dimension: affiliate_commission {
    type: number
    sql: ${TABLE}.commission ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count
  }

  measure: total_commission {
    type: sum
    sql: ${affiliate_commission} ;;
    value_format_name: decimal_0
    filters: {
      field: affiliate_commission
      value: ">0"
    }
  }

  measure: commissionable_total_order_amount {
    type: sum
    sql: ${total} ;;
    value_format_name: decimal_0

    filters: {
      field: affiliate_commission
      value: ">0"
    }
  }

  measure: unique_user_count {
    type: count_distinct
    sql_distinct_key: ${user_id} ;;
    sql: ${user_id} ;;
  }

  measure: total_order_amount {
    type: sum
    description: "Product GMV"
    sql: ${total} ;;
    value_format_name: decimal_0
  }

  measure: total_not_confirmed_amount {
    type:  sum
    sql: ${total} ;;
    value_format_name: decimal_0
    filters: {
      field: is_confirmed
      value: "No"
    }
  }

  measure: total_return_amount {
    type: sum
    sql: ${total_return} ;;
    value_format_name: decimal_0
  }

  measure: net_of_not_confirmed {
    type: number
    description: "Net of assumed cancellation"
    sql: ${total_order_amount} - ${total_not_confirmed_amount} ;;
    value_format_name: decimal_0
  }

  measure: net_order_amount {
    type: number
    description: "Net of returns & assumed cancellation"
    sql: ${net_of_not_confirmed} + ${total_return_amount} ;;
    value_format_name: decimal_0
  }

  measure: total_reseller_amount {
    type: sum
    sql: ${total} ;;
    value_format_name: decimal_0
    filters: {
      field: user_facts.user_type
      value: "VIP"
    }
  }

  measure: return_rate {
    type: number
    sql: - ${total_return_amount} / NULLIF(${total_order_amount}, 0) ;;
    value_format_name: percent_1
  }

  measure: cancellation_rate {
    type: number
    sql: ${total_not_confirmed_amount} / NULLIF(${total_order_amount}, 0) ;;
    value_format_name: percent_1
  }

  measure: percent_of_reseller {
    type: number
    sql: ${total_reseller_amount} / NULLIF(${total_order_amount}, 0) ;;
    value_format_name: percent_1
  }

  measure: average_order_value {
    type: average
    sql: ${total} ;;
    value_format_name: decimal_0
    filters: {
      field: total
      value: ">0"
    }
  }

  measure: median_order_value {
    type: median
    sql: ${total} ;;
    value_format_name: decimal_0
    filters: {
      field: total
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

  measure: dealtake {
    type: number
    sql: ${total_commission} / NULLIF(${commissionable_total_order_amount}, 0) ;;
    value_format_name: percent_1
  }
}
