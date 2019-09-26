view: track_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${tracks_sanitized.SQL_TABLE_NAME} ;;
      sql: with events as (
          select
            e.event_id
            , e.event
            , e.session_id
            , t.context_page_path
            , e.source_sequence_number as sequence
          from ${event_facts.SQL_TABLE_NAME} as e
          left join ${tracks_sanitized.SQL_TABLE_NAME} as t
          on e.event_id = concat(cast(t.timestamp AS string), t.anonymous_id, '-t')
          where e.event_source = "tracks"
        )

        select
          e.event_id
          , e.event
          , e2.event as prev_event
          , e.session_id
          , e.context_page_path as current_path
          , coalesce(e2.context_page_path, 'direct') as prev_path
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
