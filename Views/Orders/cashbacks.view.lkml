view: cashbacks {
  derived_table: {
    sql_trigger_value: select count(*) from aurora_smile_ventures.cashbacks ;;
    sql:
    SELECT
      CONCAT(c.order_id, "-", c.sku_number) as id
      , c.created_at
      , c.amount
      , c.order_id
      , c.sku_number
      , c.account_number
      , c.entity_name
      , c.paid_date
      , c.rate
      , c.status
      , c.process_date as confirmed_date
      , c.user_id
      , c.withdrawal_date as available_date
      , c.transaction_date
      , c.requested_date
      , c.vendor
      , DATE_DIFF(CAST(c.transaction_date as DATE), CAST(c.paid_date as DATE), DAY) as time_to_pay

    FROM aurora_smile_ventures.cashbacks as c
    where c._fivetran_deleted = false and c.status != "deleted"
    ;;
  }

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
    group_label: "Cashout Info"
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
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

  dimension: entity_name {
    type: string
    sql: ${TABLE}.entity_name ;;
    group_label: "Cashout Info"
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: paid {
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
    sql: ${TABLE}.paid_date ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.sku_number ;;
  }

  # dimension: rakuten_order_id {
  #   type: string
  #   sql: ${TABLE}.rakuten_order_id ;;
  # }

  dimension: rate {
    type: number
    sql: ${TABLE}.rate ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: confirmed {
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
    sql: ${TABLE}.confirmed_date ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension_group: available {
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
    sql: ${TABLE}.available_date ;;
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

  dimension_group: requested {
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
    sql: ${TABLE}.requested_date ;;
  }

  measure: count {
    type: count
    drill_fields: [id, entity_name]
  }

  measure: total_cashback {
    type: sum
    sql: ${amount} ;;
    drill_fields: [cashback_info*]
  }

  set: cashback_info {
    fields: [user_id, status, amount, affiliate_orders.order_id, affiliate_orders.total]
  }
}
