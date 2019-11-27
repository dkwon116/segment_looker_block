# 1. Combine events with session_id
# 2. Add sequence number to events
# 3. Add journey type and props to events

view:event_sessions {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        e.event_id
        , e.anonymous_id
        , e.looker_visitor_id
        , s.session_id
        , row_number() over(partition by s.session_id order by e.timestamp) as event_sequence
        , row_number() over(partition by s.session_id, e.event_source order by e.timestamp) as source_sequence
        , e.timestamp
        , IF(e.event_source='pages' and e.event NOT IN ('Product', 'Signup', 'Login'),
                e.event,
                IFNULL(LAST_VALUE(IF(e.event_source='pages' AND e.event NOT IN ('Product', 'Signup', 'Login'), e.event, NULL) IGNORE NULLS) OVER (PARTITION BY s.session_id ORDER BY e.timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 'Direct')) as journey_type
        -- ,IF(e.event IN ('Brand', 'Category', 'Product Search', 'Hashtag'),REGEXP_EXTRACT(e.page_path,"^/.*/(.*)$"),null) AS journey_prop
        , case
            when e.event_source='pages' and e.event='Brand' then split(e.page_path,'/')[safe_offset(3)]
            when e.event_source='pages' and e.event IN ('Category', 'Product Search', 'Hashtag') then REGEXP_EXTRACT(e.page_path,"^/.*/(.*)$")
            else null
        end as journey_prop
      from ${mapped_events.SQL_TABLE_NAME} as e
      left join ${sessions.SQL_TABLE_NAME} as s
        on e.looker_visitor_id = s.looker_visitor_id
        and e.timestamp >= s.session_start_at
        and (e.timestamp < s.next_session_start_at or s.next_session_start_at is null)
      ;;
  }


  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
    primary_key: yes
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: event_sequence {
    type: number
    sql: ${TABLE}.event_sequence ;;
  }

  dimension: source_sequence {
    type: number
    sql: ${TABLE}.source_sequence ;;
  }

}
