view:journeys {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
    CREATE TEMP FUNCTION decodeurl(a STRING)
    RETURNS STRING
    LANGUAGE js AS "return decodeURI(a)";

    with t as(
      -- mark start and end of journey creating first & last
      select
        case
          when lag(e.journey_type) over (w) is null then e.event_sequence
          when e.journey_type<>lag(e.journey_type) over (w) then e.event_sequence
          when e.journey_type in ('Brand', 'Category', 'Product Search', 'Hashtag')
            and e.journey_type=lag(e.journey_type) over (w)
            and e.journey_prop<>last_value(IF(e.journey_type in ('Brand', 'Category', 'Product Search', 'Hashtag'),e.journey_prop,NULL) ignore nulls) over (w1)
            then e.event_sequence
          else null
        end as first_journey_event_sequence
        ,last_value(e.event_sequence) over (we) as last_session_event_sequence
        ,*
      from ${event_sessions.SQL_TABLE_NAME} as e
      window
      w as (partition by e.session_id order by e.event_sequence)
      ,w1 as (partition by e.session_id order by e.event_sequence rows between unbounded preceding and 1 preceding)
      ,we as (partition by e.session_id order by e.event_sequence rows between unbounded preceding and unbounded following)
    )
    select
      concat(t.session_id, ' - ', cast(row_number() over(ws) AS string)) AS journey_id
      ,t.session_id
      ,t.anonymous_id
      ,t.looker_visitor_id
      ,t.journey_type
      ,t.timestamp as journey_start_at
      ,t.journey_prop
      ,if(t.journey_prop is null,null,lower(decodeurl(t.journey_prop))) as journey_prop_decoded
      ,case
        when t.journey_type='Product Search'
          then true
        when t.journey_type in ('Brand','Category')
          and lag(t.journey_type) over (ws)='Search'
          and (lag(t.journey_prop,2) over (ws)<>t.journey_prop
            or lag(t.journey_prop,2) over (ws) is null)
          then true
        when t.journey_type='Search'
          and lead(t.journey_type) over (ws) in ('Brand', 'Category', 'Product Search')
          and (lag(t.journey_prop) over (ws)<>lead(t.journey_prop) over (ws)
            or lag(t.journey_prop) over (ws) is null)
          then true
        else false
      end as is_search
      ,IF(t.journey_type IN ('Brand', 'Category', 'Product Search', 'Hashtag', 'Sale', 'New'), true, false) as is_discovery
      ,t.first_journey_event_sequence
      ,ifnull(lead(t.first_journey_event_sequence) over (ws)-1,t.last_session_event_sequence) as last_journey_event_sequence
    from t
    where t.first_journey_event_sequence is not null
    window ws as (partition by t.session_id order by t.event_sequence)
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

  dimension: journey_prop_decoded {
    type: string
    sql: ${TABLE}.journey_prop_decoded ;;
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

    filters: {
      field: journey_type
      value: "Brand, Category, Product Search"
    }
  }

  measure: discovery_journeys_per_discovery_journey_user {
    type: number
    sql: ${discovery_journey_count} / NULLIF(${unique_discovery_journey_visitor_count}, 0);;
    value_format_name:decimal_2
    group_label: "Product Discovery"
  }

  measure: discovery_journey_visitor_per_unique_visitor {
    type: number
    sql: ${unique_discovery_journey_visitor_count} / ${unique_visitor_count} ;;
    value_format_name: percent_0
    group_label: "Product Discovery"
  }




}
