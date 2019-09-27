view:journeys {


  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
    with t as(
      select
        case
          when lag(e.journey_type) over (partition by e.session_id order by e.track_sequence_number) is null then e.track_sequence_number
          when lag(e.journey_type) over (partition by e.session_id order by e.track_sequence_number)<>e.journey_type then e.track_sequence_number
          when lag(e.journey_type) over (partition by e.session_id order by e.track_sequence_number)=e.journey_type
            and last_value(IF(e.journey_type IN ('Brand','Category','Product Search'),e.journey_prop,NULL) ignore nulls) over (partition by e.session_id order by e.track_sequence_number rows between unbounded preceding and 1 preceding)<>e.journey_prop
            and e.journey_type IN ('Brand','Category','Product Search') then e.track_sequence_number
          else null
        end as start_track
        ,*
      from(
        select
          e.looker_visitor_id
          ,e.anonymous_id
          ,es.session_id
          ,es.track_sequence_number
          ,last_value(es.track_sequence_number) over (partition by es.session_id order by es.track_sequence_number rows between unbounded preceding and unbounded following) as last_track_sequence_number
          ,IF(e.event_source='pages' AND e.event NOT IN ('Product', 'Signup', 'Login'), e.event, IFNULL(LAST_VALUE(IF(e.event_source='pages' AND e.event NOT IN ('Product', 'Signup', 'Login'), e.event, NULL) IGNORE NULLS) OVER (PARTITION BY es.session_id ORDER BY es.timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 'Direct')) as journey_type
          ,REGEXP_EXTRACT(e.page_path,"^/.*/(.*)$") AS journey_prop
        from ${mapped_events.SQL_TABLE_NAME} e
        join ${event_sessions.SQL_TABLE_NAME} es on es.event_id=e.event_id
      ) e
    )
    select
      concat(t.session_id, ' - ', cast(row_number() over(partition by t.session_id order by t.track_sequence_number) AS string)) AS journey_id
      ,t.session_id
      ,t.anonymous_id
      ,t.looker_visitor_id
      ,t.journey_type
      ,case
        when t.journey_type='Product Search' then 1
        when t.journey_type IN ('Brand','Category')
          and lag(t.journey_type) over (partition by t.session_id order by t.track_sequence_number)='Search'
          and (lag(t.journey_prop,2) over (partition by t.session_id order by t.track_sequence_number)<>t.journey_prop or lag(t.journey_prop,2) over (partition by t.session_id order by t.track_sequence_number) is null) then 1
        else null
      end as journey_issearch
      ,t.start_track
      ,ifnull(lead(t.start_track) over (partition by t.session_id order by t.track_sequence_number)-1,t.last_track_sequence_number) as last_track
      ,IF(t.journey_type IN ('Brand','Category','Product Search'),t.journey_prop,NULL) AS journey_prop
    from t
    where t.start_track is not null

      ;;
  }


  dimension: journey_id {
    type: string
    sql: ${TABLE}.event_id ;;
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

  dimension: journey_type {
    type: string
    sql: ${TABLE}.journey_type ;;
  }

  dimension: journey_issearch {
    type: yesno
    sql: ${TABLE}.journey_issearch ;;
  }

  dimension: start_track {
    type: number
    sql: ${TABLE}.start_track ;;
  }

  dimension: last_track {
    type: number
    sql: ${TABLE}.last_track ;;
  }

  dimension: journey_prop {
    type: string
    sql: ${TABLE}.journey_prop ;;
  }

}
