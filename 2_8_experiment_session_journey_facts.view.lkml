view: experiment_session_journey_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:

    select
      e.session_id
      ,e.experiment_id
      ,e.variant_id
      ,e.looker_visitor_id
      ,j.journey_type

      ,sum(jf.journey_duration_seconds) as session_journey_duration_seconds
    from ${experiment_sessions.SQL_TABLE_NAME} AS e
    join ${journey_facts.SQL_TABLE_NAME} AS jf ON jf.session_id=e.session_id
    join ${journeys.SQL_TABLE_NAME} AS j ON j.journey_id=jf.journey_id
    group by 1,2,3,4,5
    ;;
    }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }
  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
  }
  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
  }
  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }
  dimension: journey_type {
    type: string
    sql: ${TABLE}.journey_type ;;
  }
  dimension: session_journey_duration_seconds {
    type: number
    sql: ${TABLE}.session_journey_duration_seconds ;;
  }

  measure: count_session {
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: var_session_journey_duration_seconds {
    type: number
    sql: var_samp(${session_journey_duration_seconds}) ;;
  }

  measure: sum_session_journey_duration_seconds {
    type: sum
    sql: ${session_journey_duration_seconds} ;;
  }

  measure: avg_session_journey_duration_seconds_per_session {
    type: number
    sql: ${sum_session_journey_duration_seconds}/nullif(${count_session},0) ;;
  }

}


view: experiment_session_journey_group_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:

    select
      e.session_id
      ,e.experiment_id
      ,e.variant_id
      ,e.looker_visitor_id
      ,j.journey_group

      ,sum(jf.journey_group_duration_seconds) as session_journey_group_duration_seconds
    from ${experiment_sessions.SQL_TABLE_NAME} AS e
    join ${journey_group_facts.SQL_TABLE_NAME} AS jf ON jf.session_id=e.session_id
    join ${journey_groups.SQL_TABLE_NAME} AS j ON j.journey_group_id=jf.journey_group_id
    group by 1,2,3,4,5
    ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }
  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
  }
  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
  }
  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }
  dimension: journey_group {
    type: string
    sql: ${TABLE}.journey_group ;;
  }
  dimension: session_journey_group_duration_seconds {
    type: number
    sql: ${TABLE}.session_journey_group_duration_seconds ;;
  }

  measure: count_session {
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: var_session_journey_group_duration_seconds {
    type: number
    sql: var_samp(${session_journey_group_duration_seconds}) ;;
  }

  measure: sum_session_journey_group_duration_seconds {
    type: sum
    sql: ${session_journey_group_duration_seconds} ;;
  }

  measure: avg_session_journey_group_duration_seconds_per_session {
    type: number
    sql: ${sum_session_journey_group_duration_seconds}/nullif(${count_session},0) ;;
  }

}
