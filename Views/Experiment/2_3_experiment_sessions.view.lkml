view: experiment_sessions {
  derived_table: {
#     sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql_trigger_value: SELECT FLOOR((TIMESTAMP_DIFF(CURRENT_TIMESTAMP(),'1970-01-01 00:00:00',SECOND)) / (3*60*60)) ;;
    sql:
      select
        distinct e.session_id
        ,e.looker_visitor_id
        ,exp.experiment_id
        ,coalesce(exp.variant_id,exp.variation_id) as variant_id
        ,exp.experiment_name
      from ${event_sessions.SQL_TABLE_NAME} e
      join ${experiment.SQL_TABLE_NAME} exp on exp.id=e.event_id
      where ((exp.experiment_name not like '%Unbounce%') or (exp.experiment_name is null))
      and e.timestamp >= '2019-10-09'
      and exp.timestamp >= '2019-10-09'

      ;;
  }


  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    hidden: yes
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
    hidden: yes
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
    group_label: "Experiment"
    hidden: yes
  }

  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
    group_label: "Experiment"
    label: "Experiment Variant Id"
  }



}
