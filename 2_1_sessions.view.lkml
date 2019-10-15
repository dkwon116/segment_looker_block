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
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.session_start_at ;;
  }

  dimension: session_sequence_number {
    type: number
    sql: ${TABLE}.session_sequence_number ;;
  }

  dimension: next_session_start_at {
    sql: ${TABLE}.next_session_start_at ;;
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
    group_label: "Date Comp"
  }

  dimension: is_up_to_same_hour_of_day {
    type: yesno
    sql: ${today_hour_of_day} >= ${start_hour_of_day};;
    group_label: "Date Comp"
  }

  dimension: is_last_24hours {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, hour) < 24  ;;
    group_label: "Date Comp"
  }

  dimension: is_last_7days {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, day) < 7  ;;
    group_label: "Date Comp"
  }

  dimension: is_first_session {
    group_label: "Session Flags"
    type: string
    sql: CASE WHEN ${session_sequence_number} = 1 THEN 'First Session'
           ELSE 'Repeat Session'
      END
       ;;
  }

  measure: count {
    type: count
    drill_fields: [session_detail*]
    group_label: "Session Facts"
    group_item_label: "Number of Sessions"
  }

  measure: unique_session_count {
    type: count_distinct
    sql: ${session_id} ;;
    group_label: "Session Facts"
    group_item_label: "Number of Unique Sessions"
  }

  measure: repeat_count {
    type: count
    drill_fields: [session_detail*]
    group_label: "Session Facts"
    group_item_label: "Number of Repeat Sessions"


    filters: {
      field: is_first_session
      value: "Repeat Session"
    }
  }

  measure: unique_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    drill_fields: [user_detail*]
    label: "Number of Unique Visitors"
  }

  measure: unique_first_session_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;

    filters: {
      field: is_first_session
      value: "First Session"
    }
    label: "Number of Unique First Session Visitors"
  }

  measure: unique_repeat_session_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id};;

    filters: {
      field: is_first_session
      value: "Repeat Session"
    }
    label: "Number of Unique Repeat Session Visitors"
  }

  measure: sessions_per_unique_visitor {
    type: number
    value_format_name: decimal_2
    sql: ${count} / nullif(${unique_visitor_count}, 0) ;;
  }

  measure: unique_repeat_session_visitors_per_unique_visitor {
    type: number
    sql: ${unique_repeat_session_visitor_count} / ${unique_visitor_count} ;;
    value_format_name: percent_0
  }

  measure: repeat_session_per_session {
    type: number
    value_format_name: percent_0
    sql: ${repeat_count} / ${count} ;;
    group_label: "Session Facts"
  }

  measure: percent_of_total_count {
    type: percent_of_total
    sql: ${count} ;;
  }

  set: session_detail {
    fields: [session_facts.campaign_details*]
  }

  set: user_detail {
    fields: [start_date, users.name, looker_visitor_id, user_facts.first_visited_date, user_facts.first_source]
  }
}
