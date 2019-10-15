view: experiment_sessions {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
      select
        distinct e.session_id
        ,e.looker_visitor_id
        ,exp.experiment_id
        ,coalesce(exp.variant_id,exp.variation_id) as variant_id
      from ${event_sessions.SQL_TABLE_NAME} e
      join ${experiment.SQL_TABLE_NAME} exp on exp.id=e.event_id
      where e.event='experiment_viewed'
      ;;
  }


  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
  }

  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
  }

}
