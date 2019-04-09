view: order_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${orders.SQL_TABLE_NAME} ;;
    sql: SELECT
        o.order_id
        , o.user_id
        , ef.session_id
        , ef.event_id
        , o.transaction_at
        , o.order_sequence_number
        , o.total
        , c.rate as cashback_rate
        , SUM(c.amount) as total_cashback
      from ${orders.SQL_TABLE_NAME} as o
      LEFT JOIN ${event_facts.SQL_TABLE_NAME} as ef
      ON CONCAT(cast(o.transaction_at as string), o.user_id, '-r') = ef.event_id
      LEFT JOIN ${cashbacks.SQL_TABLE_NAME} as c
        ON o.order_id = c.order_id
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
    ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension_group: transaction_at {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.transaction_at ;;
  }

  dimension: cashback_rate {
    type: number
    sql: ${TABLE}.cashback_rate / 100 ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}.total ;;
  }

  dimension: total_cashback {
    type: number
    sql: ${TABLE}.total_cashback ;;
  }

  dimension: cashback_error_rate {
    type: number
    sql: ${total_cashback} / NULLIF((${total} * 0.98 * ${cashback_rate}), 0) - 1;;
  }

  dimension: is_cashback_correct {
    type: yesno
    sql: IF(${cashback_error_rate}  < 0.1 AND ${cashback_error_rate} > -0.1, true, false)  ;;
  }
}
