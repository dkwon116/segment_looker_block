view:journeys {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
    with t as(
      -- mark start and end of journey creating first & last
      select
        case
          when lag(e.journey_type) over (partition by e.session_id order by e.event_sequence) is null then e.event_sequence
          when lag(e.journey_type) over (partition by e.session_id order by e.event_sequence)<>e.journey_type then e.event_sequence
          when lag(e.journey_type) over (partition by e.session_id order by e.event_sequence)=e.journey_type
            and last_value(IF(e.journey_type IN ('Brand', 'Category', 'Product Search', 'Hashtag'),e.journey_prop,NULL) ignore nulls) over (partition by e.session_id order by e.event_sequence rows between unbounded preceding and 1 preceding)<>e.journey_prop
            and e.journey_type IN ('Brand', 'Category', 'Product Search', 'Hashtag') then e.event_sequence
          else null
        end as first_journey_event_sequence
        ,last_value(e.event_sequence) over (partition by e.session_id order by e.event_sequence rows between unbounded preceding and unbounded following) as last_session_event_sequence
        ,*
      from ${event_sessions.SQL_TABLE_NAME} as e
    )
    select
      concat(t.session_id, ' - ', cast(row_number() over(partition by t.session_id order by t.event_sequence) AS string)) AS journey_id
      ,t.session_id
      ,t.anonymous_id
      ,t.looker_visitor_id
      ,t.journey_type
      ,t.timestamp
      ,t.journey_prop
      ,case
        when t.journey_type='Product Search' then true
        when t.journey_type IN ('Brand','Category')
          and lag(t.journey_type) over (partition by t.session_id order by t.event_sequence)='Search'
          and (lag(t.journey_prop,2) over (partition by t.session_id order by t.event_sequence)<>t.journey_prop or lag(t.journey_prop,2) over (partition by t.session_id order by t.event_sequence) is null) then true
        else false
      end as is_search
      ,IF(t.journey_type IN ('Brand', 'Category', 'Product Search', 'Hashtag', 'Sale', 'New'), true, false) as is_discovery
      ,t.first_journey_event_sequence
      ,ifnull(lead(t.first_journey_event_sequence) over (partition by t.session_id order by t.event_sequence)-1,t.last_session_event_sequence) as last_journey_event_sequence
    from t
    where t.first_journey_event_sequence is not null

      ;;
  }


  dimension: journey_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.journey_id ;;
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

  dimension: is_search {
    type: yesno
    sql: ${TABLE}.is_search ;;
  }

  dimension: is_discovery {
    type: yesno
    sql: ${TABLE}.is_discovery ;;
  }

  dimension: first_journey_event_sequence {
    type: number
    sql: ${TABLE}.first_journey_event_sequence ;;
  }

  dimension: last_journey_event_sequence {
    type: number
    sql: ${TABLE}.last_journey_event_sequence ;;
  }

  dimension: journey_prop {
    type: string
    sql: ${TABLE}.journey_prop ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, hour, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  measure: count {
    type: count
  }

  measure: unique_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: discovery_journey_count {
    type: count

    filters: {
      field: is_discovery
      value: "yes"
    }
  }

  measure: unique_discovery_journey_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;

    filters: {
      field: is_discovery
      value: "yes"
    }
  }

  measure: search_journey_count {
    type: count

    filters: {
      field: is_search
      value: "yes"
    }
  }
}
