view: affiliate_events {
  sql_table_name: mysql_smile_ventures.rakuten_events ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: advertiser_id {
    type: number
    sql: ${TABLE}.advertiser_id ;;
  }

  dimension: commissions {
    type: number
    sql: ${TABLE}.commissions ;;
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

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: etransaction_id {
    type: string
    sql: ${TABLE}.etransaction_id ;;
  }

  dimension: is_event {
    type: string
    sql: ${TABLE}.is_event ;;
  }

  dimension: member_id {
    type: string
    sql: ${TABLE}.member_id ;;
    hidden: yes
  }

  dimension_group: normalized {
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
    sql: ${TABLE}.normalized_at ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: process {
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
    sql: ${TABLE}.process_date ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: publisher_id {
    type: number
    sql: ${TABLE}.publisher_id ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: sale_amount {
    type: number
    sql: ${TABLE}.sale_amount ;;
  }

  dimension: sku_number {
    type: string
    sql: ${TABLE}.sku_number ;;
  }

  dimension: order_product_id {
    type: string
    sql: concat(${order_id}, "-", ${sku_number}) ;;
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

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  dimension: u1 {
    type: string
    sql: ${TABLE}.u1 ;;
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

  dimension: decoded_u1 {
    type: string
    sql: CASE
      WHEN
        EXTRACT(MONTH FROM ${transaction_date}) = 4
        OR
        (EXTRACT(MONTH FROM ${transaction_date}) = 3 AND EXTRACT(DAY FROM ${transaction_date}) > 28)
      THEN SAFE_CONVERT_BYTES_TO_STRING(FROM_BASE64(${u1}))
      END;;
  }

  dimension: norm_user_id {
    type: string
    sql:IF(STARTS_WITH(${decoded_u1}, "seg_"), SUBSTR(${decoded_u1}, 5, 36), SUBSTR(${decoded_u1}, 1, 36));;
  }

  measure: count {
    type: count
    drill_fields: [id, product_name]
  }
}
