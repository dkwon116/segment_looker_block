view: track_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${event_sessions.SQL_TABLE_NAME} ;;
      sql: with events as (
          select
            e.event_id
            , e.event
            , es.session_id
            , e.page_path
            , es.source_sequence as sequence
          from ${event_sessions.SQL_TABLE_NAME} as es
          left join ${mapped_events.SQL_TABLE_NAME} as e
            on es.event_id = e.event_id
          where e.event_source = "tracks"
        )

        select
          e.event_id
          , e.event
          , e2.event as prev_event
          , e.session_id
          , e.page_path as current_path
          , coalesce(e2.page_path, 'direct') as prev_path
          , e.sequence as current_sequence

        from events as e
        left join events as e2
          on e.sequence - 1 = e2.sequence
          and e.session_id = e2.session_id
        ;;
  }

  dimension: event_id {
    sql: ${TABLE}.event_id ;;
  }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: session_id {
    sql: ${TABLE}.session_id ;;
  }

  dimension: current_path {
    sql: ${TABLE}.current_path ;;
  }

  dimension: current_sequence {
    sql: ${TABLE}.current_sequence ;;
  }

  dimension: prev_event {
    sql: ${TABLE}.prev_event ;;
  }

  dimension: prev_path {
    sql: ${TABLE}.prev_path ;;
  }
}
