view: funnel_explorer {
  derived_table: {
    sql: SELECT
        --CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', tracks_sessions_map.timestamp , 'Asia/Seoul')) AS {% parameter timeframe_picker %}) as date
        tracks_sessions_map.session_id
        ,tracks_sessions_map.looker_visitor_id as user_id
        , MIN(
            CASE WHEN
              {% condition event1 %} tracks_sessions_map.event {% endcondition %}
              THEN tracks_sessions_map.timestamp
              ELSE NULL END
            ) as event1_time
        , MIN(
            CASE WHEN
              {% condition event2 %} tracks_sessions_map.event {% endcondition %}
              THEN tracks_sessions_map.timestamp
              ELSE NULL END
            ) as event2_time
        , MIN(
            CASE WHEN
              {% condition event3 %} tracks_sessions_map.event {% endcondition %}
              THEN tracks_sessions_map.timestamp
              ELSE NULL END
            ) as event3_time
        , MIN(
            CASE WHEN
              {% condition event4 %} tracks_sessions_map.event {% endcondition %}
              THEN tracks_sessions_map.timestamp
              ELSE NULL END
            ) as event4_time
        , MIN(
            CASE WHEN
              {% condition event5 %} tracks_sessions_map.event {% endcondition %}
              THEN tracks_sessions_map.timestamp
              ELSE NULL END
            ) as event5_time
      FROM ${event_facts.SQL_TABLE_NAME} as tracks_sessions_map
      GROUP BY 1, 2
       ;;
  }

  filter: event1 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  filter: event2 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  filter: event3 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  filter: event4 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  filter: event5 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  parameter: timeframe_picker {
    label: "Date Granularity"
    type: unquoted
    allowed_value: { value: "Date" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
    default_value: "Date"
  }

  dimension: user_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension_group: event1 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event1_time ;;
  }

  dimension_group: event2 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event2_time ;;
  }

  dimension_group: event3 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event3_time ;;
  }

  dimension_group: event4 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event4_time ;;
  }

  dimension_group: event5 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event5_time ;;
  }

  dimension: event1_before_event2 {
    type: yesno
    sql: ${event1_time} <= ${event2_time} ;;
  }

  dimension: event2_before_event3 {
    type: yesno
    sql: ${event2_time} < ${event3_time} ;;
  }

  dimension: event3_before_event4 {
    type: yesno
    sql: ${event3_time} < ${event4_time} ;;
  }

  dimension: event4_before_event5 {
    type: yesno
    sql: ${event4_time} < ${event5_time} ;;
  }

  dimension: minutes_in_funnel {
    type: number
    sql: timestamp_diff(${event1_raw},COALESCE(${event5_raw},${event4_raw},${event3_raw},${event2_raw}), minute) ;;
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: count_users_event1 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: event1_time
      value: "NOT NULL"
    }
  }

  measure: count_users_event12 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: event1_time
      value: "NOT NULL"
    }

    filters: {
      field: event2_time
      value: "NOT NULL"
    }

    filters: {
      field: event1_before_event2
      value: "yes"
    }
  }

  measure: count_users_event123 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: event1_time
      value: "NOT NULL"
    }

    filters: {
      field: event2_time
      value: "NOT NULL"
    }

    filters: {
      field: event3_time
      value: "NOT NULL"
    }

    filters: {
      field: event1_before_event2
      value: "yes"
    }

    filters: {
      field: event2_before_event3
      value: "yes"
    }
  }

  measure: count_users_event1234 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: event1_time
      value: "NOT NULL"
    }

    filters: {
      field: event2_time
      value: "NOT NULL"
    }

    filters: {
      field: event3_time
      value: "NOT NULL"
    }

    filters: {
      field: event4_time
      value: "NOT NULL"
    }

    filters: {
      field: event1_before_event2
      value: "yes"
    }

    filters: {
      field: event2_before_event3
      value: "yes"
    }

    filters: {
      field: event3_before_event4
      value: "yes"
    }
  }

  measure: count_users_event12345 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: event1_time
      value: "NOT NULL"
    }

    filters: {
      field: event2_time
      value: "NOT NULL"
    }

    filters: {
      field: event3_time
      value: "NOT NULL"
    }

    filters: {
      field: event4_time
      value: "NOT NULL"
    }

    filters: {
      field: event5_time
      value: "NOT NULL"
    }

    filters: {
      field: event1_before_event2
      value: "yes"
    }

    filters: {
      field: event2_before_event3
      value: "yes"
    }

    filters: {
      field: event3_before_event4
      value: "yes"
    }

    filters: {
      field: event4_before_event5
      value: "yes"
    }
  }

  measure: event1_conversion {
    type: number
    sql: 1 ;;
    group_label: "Conversion"
  }

  measure: event2_conversion {
    type: number
    sql: ${count_users_event12} / NULLIF(${count_users_event1},0) ;;
    value_format_name: percent_0
    group_label: "Conversion"
  }

  measure: event3_conversion {
    type: number
    sql: ${count_users_event123} / NULLIF(${count_users_event1},0) ;;
    value_format_name: percent_0
    group_label: "Conversion"
  }

  measure: event4_conversion {
    type: number
    sql: ${count_users_event1234} / NULLIF(${count_users_event1},0) ;;
    value_format_name: percent_0
    group_label: "Conversion"
  }

  measure: event5_conversion {
    type: number
    sql: ${count_users_event12345} / NULLIF(${count_users_event1},0) ;;
    value_format_name: percent_0
    group_label: "Conversion"
  }
}
