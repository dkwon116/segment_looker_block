view:page_path_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      with t as(
      select
        case
          when lag(page_path) over(w) is null then event_sequence
          when page_path<>lag(page_path) over(w) then event_sequence
          else null
        end as first_page_path_event_sequence
        ,last_value(event_sequence) over (we) as last_session_event_sequence
        ,last_value(timestamp) over (we) as last_session_timestamp
        ,*
      from ${event_sessions.SQL_TABLE_NAME} as e
      window
        w as (partition by session_id order by event_sequence)
        ,we as (partition by session_id order by event_sequence rows between unbounded preceding and unbounded following)
      )
      select
        concat(t.session_id, ' - P', cast(row_number() over(ws) AS string)) AS page_path_id
        ,t.session_id
        ,t.anonymous_id
        ,t.looker_visitor_id
        ,t.page_path
        ,row_number() over(ws) as page_path_sequence
        ,t.timestamp as page_path_start_at
        ,case
          when lead(t.timestamp) over (ws) is not null then timestamp_diff(lead(t.timestamp) over (ws), t.timestamp, second)
          else timestamp_diff(t.last_session_timestamp, t.timestamp, second)
        end as page_path_duration_second
        ,t.first_page_path_event_sequence
        ,ifnull(lead(t.first_page_path_event_sequence) over (ws)-1,t.last_session_event_sequence) as last_page_path_event_sequence
      from t
      where t.first_page_path_event_sequence is not null
      window ws as (partition by t.session_id order by t.first_page_path_event_sequence)
;;
  }

  dimension: page_path_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.page_path_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: page_path {
    type: string
    sql: ${TABLE}.page_path ;;
  }

  dimension: page_path_sequence {
    type: number
    sql: ${TABLE}.page_path_sequence ;;
  }

  dimension: page_path_duration_second {
    type: number
    sql: ${TABLE}.page_path_duration_second ;;
  }

  dimension: first_page_path_event_sequence {
    type: number
    sql: ${TABLE}.first_page_path_event_sequence ;;
    hidden: yes
  }

  dimension: last_page_path_event_sequence {
    type: number
    sql: ${TABLE}.last_page_path_event_sequence ;;
    hidden: yes
  }



  measure: count {
    type: count
  }

  measure: unique_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: total_page_path_duration {
    type: sum
    sql: ${page_path_duration_second} ;;
    value_format_name: decimal_0
  }

  measure: avg_page_path_duration {
    type: average
    value_format_name: decimal_1
    sql: ${page_path_duration_second};;
    group_label: "Journey Facts"
  }

  measure: avg_page_path_duration_per_session {
    type: number
    value_format_name: decimal_1
    sql: ${total_page_path_duration}/nullif(${sessions.count},0);;
  }
  }
