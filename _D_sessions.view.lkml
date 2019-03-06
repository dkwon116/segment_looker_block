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
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, raw]
    sql: ${TABLE}.session_start_at ;;
  }

  dimension_group: today {
    type: time
    hidden: yes
    timeframes: [day_of_week_index, hour_of_day]
    sql: CURRENT_TIMESTAMP() ;;
  }

  dimension: is_same_day_of_week_as_today {
    type: yesno
    sql: ${today_day_of_week_index} = ${start_day_of_week_index} ;;
  }

  dimension: is_up_to_same_hour_of_day {
    type: yesno
    sql: ${today_hour_of_day} >= ${start_hour_of_day};;
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

  measure: count_sessions {
    type: count_distinct
    sql: ${session_id} ;;
    drill_fields: [session_detail*]
  }

  measure: percent_of_total_count {
    type: percent_of_total
    sql: ${count_sessions} ;;
  }

  measure: count_repeat_visitors {
    type: count_distinct
    sql: ${looker_visitor_id} ;;

    filters: {
      field: is_first_session
      value: "Repeat Session"
    }
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

  measure: percent_of_repeat_users {
    type: number
    sql: ${count_repeat_visitors} / ${count_visitors} ;;
    value_format_name: percent_0
  }

  set: session_detail {
    fields: [session_facts.campaign_details*]
  }

  set: user_detail {
    fields: [start_date, users.name, looker_visitor_id, user_facts.first_visited_date, user_facts.first_source]
  }
}
