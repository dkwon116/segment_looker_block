view: experiment_user_session_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
      select
        e.experiment_id
        ,e.variant_id
        --,sum(e.number_of_sessions) as number_of_sessions
        --,count(e.looker_visitor_id) as unique_visitors
        --,sum(e.number_of_sessions)/count(e.looker_visitor_id) as sessions_per_unique_visitor
        ,var_samp(e.number_of_sessions) as sessions_variance
      from(
        select
          e.experiment_id
          ,e.variant_id
          ,e.looker_visitor_id
          ,count(distinct e.session_id) as number_of_sessions
        from ${experiment_sessions.SQL_TABLE_NAME} e
        group by 1,2,3
      ) e
      group by 1,2

      ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
    hidden: yes
  }

  dimension: experiment_name {
    type: string
    sql: ${TABLE}.experiment_name ;;
    hidden: yes
  }

  dimension:sessions_variance{
    type: number
    sql: ${TABLE}.sessions_variance ;;
    hidden: yes
  }

}
