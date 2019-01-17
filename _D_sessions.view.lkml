# - explore: sessions_pg_trk
view: sessions {
  derived_table: {
#     list sessions by user
    sql_trigger_value: select count(*) from ${mapped_events.SQL_TABLE_NAME} ;;
    sql: select
       concat(cast(row_number() over(partition by looker_visitor_id order by timestamp) AS string), ' - ', looker_visitor_id) as session_id
      ,looker_visitor_id
      ,timestamp as session_start_at
      ,row_number() over(partition by looker_visitor_id order by timestamp) as session_sequence_number
      ,lead(timestamp) over(partition by looker_visitor_id order by timestamp) as next_session_start_at
from ${mapped_events.SQL_TABLE_NAME}
where (idle_time_minutes > 30 or idle_time_minutes is null)
 ;;
  }

  dimension: session_id {
    hidden: yes
    sql: ${TABLE}.session_id ;;
    primary_key: yes
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension_group: start {
    type: time
    timeframes: [time, date, hour_of_day, week, hour, month, raw]
    sql: ${TABLE}.session_start_at ;;
  }

  dimension: is_last_24hours {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, hour) < 24  ;;
  }

  dimension: is_last_7days {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, day) < 7  ;;
  }

  dimension: session_sequence_number {
    type: number
    sql: ${TABLE}.session_sequence_number ;;
  }

  dimension: next_session_start_at {
    sql: ${TABLE}.next_session_start_at ;;
  }

  dimension: is_first_session {
    #     type: yesno
    sql: CASE WHEN ${session_sequence_number} = 1 THEN 'First Session'
           ELSE 'Repeat Session'
      END
       ;;
  }

  dimension: session_duration_minutes {
    type: number
    sql: timestamp_diff(${session_facts.end_time}, ${start_time}, minute) ;;
  }

  measure: count_sessions {
    type: count_distinct
    sql: ${session_id} ;;
    drill_fields: [user_detail*]
  }

  measure: percent_of_total_count {
    type: percent_of_total
    sql: ${count_sessions} ;;
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    drill_fields: [user_detail*]
  }

  measure: avg_sessions_per_user {
    type: number
    value_format_name: decimal_2
    sql: ${count_sessions} / nullif(${count_visitors}, 0) ;;
  }

  measure: avg_session_duration_minutes {
    type: average
    sql: ${session_duration_minutes} ;;
    value_format_name: decimal_1
  }

  set: session_detail {
    fields: []
  }

  set: user_detail {
    fields: [looker_visitor_id, start_time, users.name, user_facts.first_visited, user_facts.first_source]
  }
}
