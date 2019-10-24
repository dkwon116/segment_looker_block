# Funnel based on first ever event by user
# If user outlinked this 3 months ago, but also outlinked this month will not be counted
# Also, this is strict funnel. Only counting if previous event happened


view: funnel_explorer {
  derived_table: {
    sql: SELECT
        -- ef.session_id
        ef.looker_visitor_id as user_id
        , fe.first_order_completed
        , fe.first_outlink_sent
        , MIN(
            CASE WHEN
              {% condition event1 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event1_time
        , MIN(
            CASE WHEN
              {% condition event2 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event2_time
        , MIN(
            CASE WHEN
              {% condition event3 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event3_time
        , MIN(
            CASE WHEN
              {% condition event4 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event4_time
        , MIN(
            CASE WHEN
              {% condition event5 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event5_time
        , MIN(
            CASE WHEN
              {% condition event6 %} ef.event {% endcondition %}
              THEN ef.timestamp
              ELSE NULL END
            ) as event6_time

      FROM ${event_facts.SQL_TABLE_NAME} as ef
      LEFT JOIN ${first_events.SQL_TABLE_NAME} as fe
        ON ef.looker_visitor_id = fe.looker_visitor_id
      WHERE
        {% if no_event._parameter_value != "all" %}
          fe.{% parameter no_event %} IS NULL
        {% elsif before_event._parameter_value != "all" %}
          ef.timestamp <= fe.{% parameter before_event %} or fe.{% parameter before_event %} IS NULL
        {% elsif after_event._parameter_value != "all" %}
          ef.timestamp > fe.{% parameter after_event %} and fe.{% parameter after_event %} IS NOT NULL
        {% else %}
          1=1
        {% endif %}
      GROUP BY 1, 2, 3
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

  filter: event6 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  parameter: no_event {
    type: unquoted
    allowed_value: {
      label: "Not Purchase"
      value: "first_order_completed"
    }
    allowed_value: {
      label: "Not Outlinked"
      value: "first_outlink_sent"
    }
    allowed_value: {
      label: "Not SignedUp"
      value: "signed_up"
    }
    default_value: "all"
  }

  parameter: before_event {
    type: unquoted
    allowed_value: {
      label: "Before First Purchase"
      value: "first_order_completed"
    }
    allowed_value: {
      label: "Before First Outlinked"
      value: "first_outlink_sent"
    }
    allowed_value: {
      label: "Before SignedUp"
      value: "signed_up"
    }
    default_value: "all"
  }

  parameter: after_event {
    type: unquoted
    allowed_value: {
      label: "After First Purchase"
      value: "first_order_completed"
    }
    allowed_value: {
      label: "Before First Outlinked"
      value: "first_outlink_sent"
    }
    allowed_value: {
      label: "Before SignedUp"
      value: "signed_up"
    }
    default_value: "all"
  }


  # parameter: timeframe_picker {
  #   label: "Date Granularity"
  #   type: unquoted
  #   allowed_value: { value: "Date" }
  #   allowed_value: { value: "Week" }
  #   allowed_value: { value: "Month" }
  #   default_value: "Date"
  # }

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

  dimension_group: event6 {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.event6_time ;;
  }

  dimension_group: first_order_completed {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.first_order_completed ;;
  }

  dimension_group: first_outlink_sent {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.first_outlink_sent ;;
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

  dimension: event5_before_event6 {
    type: yesno
    sql: ${event5_time} < ${event6_time} ;;
  }

  dimension: minutes_in_funnel {
    type: number
    sql: timestamp_diff(${event1_raw},COALESCE(${event6_raw},${event5_raw},${event4_raw},${event3_raw},${event2_raw}), minute) ;;
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: count_users_event1 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
  }

  measure: count_users_event12 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
    filters: {field: event2_time value: "NOT NULL"}

    filters: {field: event1_before_event2 value: "yes"}
  }

  measure: count_users_event123 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
    filters: {field: event2_time value: "NOT NULL"}
    filters: {field: event3_time value: "NOT NULL"}

    filters: {field: event1_before_event2 value: "yes"}
    filters: {field: event2_before_event3 value: "yes"}
  }

  measure: count_users_event1234 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
    filters: {field: event2_time value: "NOT NULL"}
    filters: {field: event3_time value: "NOT NULL"}
    filters: {field: event4_time value: "NOT NULL"}

    filters: {field: event1_before_event2 value: "yes"}
    filters: {field: event2_before_event3 value: "yes"}
    filters: {field: event3_before_event4 value: "yes"}
  }

  measure: count_users_event12345 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
    filters: {field: event2_time value: "NOT NULL"}
    filters: {field: event3_time value: "NOT NULL"}
    filters: {field: event4_time value: "NOT NULL"}
    filters: {field: event5_time value: "NOT NULL"}

    filters: {field: event1_before_event2 value: "yes"}
    filters: {field: event2_before_event3 value: "yes"}
    filters: {field: event3_before_event4 value: "yes"}
    filters: {field: event4_before_event5 value: "yes"}
  }

  measure: count_users_event123456 {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {field: event1_time value: "NOT NULL"}
    filters: {field: event2_time value: "NOT NULL"}
    filters: {field: event3_time value: "NOT NULL"}
    filters: {field: event4_time value: "NOT NULL"}
    filters: {field: event5_time value: "NOT NULL"}
    filters: {field: event6_time value: "NOT NULL"}

    filters: {field: event1_before_event2 value: "yes"}
    filters: {field: event2_before_event3 value: "yes"}
    filters: {field: event3_before_event4 value: "yes"}
    filters: {field: event4_before_event5 value: "yes"}
    filters: {field: event5_before_event6 value: "yes"}
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

  measure: event6_conversion {
    type: number
    sql: ${count_users_event123456} / NULLIF(${count_users_event1},0) ;;
    value_format_name: percent_0
    group_label: "Conversion"
  }
}
