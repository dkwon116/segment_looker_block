view: order_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${orders.SQL_TABLE_NAME} ;;
    sql: SELECT


      from ${orders.SQL_TABLE_NAME} as o
      left join ${session_facts.SQL_TABLE_NAME} as sf
      on o.user_id = s.looker_visitor_id
      LEFT JOIN ${event_facts.SQL_TABLE_NAME} as ef
    ;;
  }
}
