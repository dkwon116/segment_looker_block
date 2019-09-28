view:event_sessions {


  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        t.event_id
        , t.anonymous_id
        , t.looker_visitor_id
        , s.session_id
        , row_number() over(partition by s.session_id order by t.timestamp) as track_sequence_number
        , row_number() over(partition by s.session_id, t.event_source order by t.timestamp) as source_sequence_number
        , t.timestamp
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${sessions.SQL_TABLE_NAME} as s
        on t.looker_visitor_id = s.looker_visitor_id
        and t.timestamp >= s.session_start_at
        and (t.timestamp < s.next_session_start_at or s.next_session_start_at is null)
      ;;
  }


  dimension: event_id {
  type: string
  sql: ${TABLE}.event_id ;;
}

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: track_sequence_number {
    type: number
    sql: ${TABLE}.track_sequence_number ;;
  }

  dimension: source_sequence_number {
    type: number
    sql: ${TABLE}.source_sequence_number ;;
  }

 }
