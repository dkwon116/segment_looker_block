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
      from ${orders.SQL_TABLE_NAME} as o
      LEFT JOIN ${event_facts.SQL_TABLE_NAME} as ef
      ON CONCAT(cast(o.transaction_at as string), o.user_id, '-r') = ef.event_id
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
}
