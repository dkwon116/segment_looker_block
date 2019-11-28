view:journey_groups {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      with t as(
      select
        case
          when lag(journey_group) over(w) is null then first_journey_event_sequence
          when journey_group<>lag(journey_group) over(w) then first_journey_event_sequence
          else null
        end as first_journey_group_event_sequence
        ,last_value(last_journey_event_sequence) over (we) as last_session_event_sequence
        ,*
      from ${journeys.SQL_TABLE_NAME}
      window
        w as (partition by session_id order by first_journey_event_sequence)
        ,we as (partition by session_id order by first_journey_event_sequence rows between unbounded preceding and unbounded following)
      )
      select
        concat(t.session_id, ' - G', cast(row_number() over(ws) AS string)) AS journey_group_id
        ,t.session_id
        ,t.anonymous_id
        ,t.looker_visitor_id
        ,t.journey_group
        ,t.journey_start_at as journey_group_start_at
        ,t.is_search
        ,t.is_discovery
        ,t.first_journey_group_event_sequence
        ,ifnull(lead(t.first_journey_group_event_sequence) over (ws)-1,t.last_session_event_sequence) as last_journey_group_event_sequence
      from t
      where t.first_journey_group_event_sequence is not null
      window ws as (partition by t.session_id order by t.first_journey_event_sequence)
;;
  }


  dimension: journey_group_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.journey_group_id ;;
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

  dimension: journey_group {
    type: string
    sql: ${TABLE}.journey_group ;;
  }

  dimension: is_search {
    type: yesno
    sql: ${TABLE}.is_search ;;
  }

  dimension: is_discovery {
    type: yesno
    sql: ${TABLE}.is_discovery ;;
  }

  dimension: first_journey_group_event_sequence {
    type: number
    sql: ${TABLE}.first_journey_group_event_sequence ;;
  }

  dimension: last_journey_group_event_sequence {
    type: number
    sql: ${TABLE}.last_journey_group_event_sequence ;;
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
      field: journey_group
      value: "Brand, Category, Product Search"
    }
  }

  measure: unique_search_journey_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;

    filters: {
      field: is_search
      value: "yes"
    }
  }

  measure: search_journey_per_unique_visitor {
    type: number
    sql: ${unique_search_journey_visitor_count} / NULLIF(${unique_visitor_count},0) ;;
    group_label: "Product Discovery"
    value_format_name: percent_0
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
