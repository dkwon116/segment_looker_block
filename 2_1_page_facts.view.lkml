view: page_facts {
  derived_table: {
#     converting event to pageview durations and last page view to calculate sessions
    sql_trigger_value: select count(*) from ${mapped_events.SQL_TABLE_NAME} ;;
    sql:
      SELECT
        e.event_id AS event_id
        ,e.looker_visitor_id
        ,e.timestamp
        ,CASE
          WHEN timestamp_diff(LEAD(e.timestamp) OVER(w), e.timestamp, second) > 30*60 THEN NULL
          ELSE timestamp_diff(LEAD(e.timestamp) OVER(w), e.timestamp, second)
        END AS lead_idle_time_condition
      FROM ${mapped_events.SQL_TABLE_NAME} AS e
      window w as (PARTITION BY e.looker_visitor_id ORDER BY e.timestamp)
 ;;
  }

  dimension: event_id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.event_id ;;
  }

  dimension: duration_page_view_seconds {
    type: number
    sql: ${TABLE}.lead_idle_time_condition ;;
  }

  dimension: is_last_page {
    type: yesno
    sql: ${duration_page_view_seconds} is NULL ;;
  }

  dimension: looker_visitor_id {
    hidden: yes
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension_group: timestamp {
    hidden: yes
    type: time
    datatype: timestamp
    timeframes: [
      raw,
      time,
      date,
      month,
      day_of_week,
      year
    ]
    sql: ${TABLE}.timestamp ;;
  }

  measure: avg_pageview_duration_seconds {
    group_label: "Pageview Durations"
    group_item_label: "Average Seconds"
    type: average
    value_format_name: decimal_0
    sql: ${duration_page_view_seconds} ;;
  }

  measure: total_pageview_duration_seconds {
    group_label: "Pageview Durations"
    group_item_label: "Total Seconds"
    type: sum
    sql: ${duration_page_view_seconds} ;;
    value_format_name: decimal_0
  }

  measure: avg_pageview_duration_minutes_per_visitor {
    group_label: "Pageview Durations"
    group_item_label: "Avg Minutes per Visitor"
    type: number
    sql: ${total_pageview_duration_seconds} / ${event_facts.unique_visitor_count} / 60 ;;
    value_format_name: decimal_1
  }

  set: detail {
    fields: [event_id]
  }
}
