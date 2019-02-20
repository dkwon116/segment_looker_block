view: affiliate_orders {
  sql_table_name: mysql_smile_ventures.rakuten_orders ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._fivetran_synced ;;
  }

  dimension: active {
    type: number
    sql: ${TABLE}.active ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: ga_session_id {
    type: string
    sql: ${TABLE}.ga_session_id ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: rakuten_event_id {
    type: string
    sql: ${TABLE}.rakuten_event_id ;;
  }

  dimension: segment_notification_sent {
    type: yesno
    sql: ${TABLE}.segment_notification_sent ;;
  }

  dimension: segment_user_id {
    type: string
    sql: ${TABLE}.segment_user_id ;;
  }

  dimension: sku_number {
    type: string
    sql: ${TABLE}.sku_number ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}.total ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.transaction_date ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated_at ;;
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

  measure: count {
    type: count
    drill_fields: [id]
  }

  measure: distinct_orders {
    type: count_distinct
    sql_distinct_key: ${order_id} ;;
    sql: ${order_id} ;;
    drill_fields: [order_id, vendor, user_id, transaction_date, total]
  }

  measure: unique_user {
    type: count_distinct
    sql_distinct_key: ${user_id} ;;
    sql: ${user_id} ;;
  }

  measure: order_amount {
    type: sum
    sql: ${total} ;;
  }

  measure: average_order_value {
    type: number
    sql: ${order_amount} / NULLIF(${distinct_orders}, 0) ;;
    value_format_name: decimal_0
  }
}
