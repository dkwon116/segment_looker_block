view: session_facts {
  derived_table: {
#     information about session
    # Rebuilds after track_facts rebuilds
    sql_trigger_value: select COUNT(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql: select s.session_id
        , first_referrer
        , max(t2s.timestamp) as end_at
        , count(case when t2s.event_source = 'tracks' then 1 else null end) as tracks_count
        , count(case when t2s.event_source = 'pages' then 1 else null end) as pages_count
        , count(case when t2s.event = 'product_viewed' then event_id else null end) as count_product_viewed
        , count(case when t2s.event = 'product_list_viewed' then event_id else null end) as count_product_list_viewed
        , count(case when t2s.event = 'outlink_sent' then event_id else null end) as count_outlinked
      from ${sessions.SQL_TABLE_NAME} as s
        inner join ${event_facts.SQL_TABLE_NAME} as t2s
          on s.session_id = t2s.session_id
          --using(session_id)
      group by 1,2
       ;;
  }

  # ----- Dimensions -----

  dimension: session_id {
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: first_referrer {
    sql: ${TABLE}.first_referrer ;;
  }

  dimension: first_referrer_domain {
    sql: split_part(${first_referrer},'/',3) ;;
  }

  dimension: first_referrer_domain_mapped {
    sql: CASE WHEN ${first_referrer_domain} like '%facebook%' THEN 'facebook' WHEN ${first_referrer_domain} like '%google%' THEN 'google' ELSE ${first_referrer_domain} END ;;
  }

  dimension_group: end {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.end_at ;;
  }

  dimension: tracks_count {
    type: number
    sql: ${TABLE}.tracks_count ;;
  }

  dimension: pages_count {
    type:  number
    sql: ${TABLE}.pages_count ;;
  }

  dimension: total_events {
    type: number
    sql: ${tracks_count} + ${pages_count} ;;
  }

  dimension: referrer {
    type: number
    sql: ${TABLE}.referrer ;;
  }

  dimension: tracks_count_tier {
    type: tier
    sql: ${tracks_count} ;;
    tiers: [
      1,
      5,
      10,
      20,
      30,
      60
    ]
  }


  dimension: is_bounced_session {
    sql: CASE WHEN ${total_events} = 1 THEN 'Bounced Session'
      ELSE 'Not Bounced Session' END
       ;;
  }

  dimension: session_duration_minutes {
    type: number
    sql: datediff(minutes, ${sessions.start_raw}, ${end_raw}) ;;
  }

  dimension: session_duration_minutes_tiered {
    type: tier
    sql: ${session_duration_minutes} ;;
    tiers: [
      1,
      5,
      10,
      20,
      30,
      60
    ]
  }

  dimension: products_viewed {
    type: number
    sql: ${TABLE}.count_product_viewed ;;
  }

  dimension: product_lists_viewed {
    type: number
    sql: ${TABLE}.count_product_list_viewed ;;
  }

  dimension: outlinked {
    type: number
    sql: ${TABLE}.count_outlinked ;;
  }

  # ----- Measures -----

  measure: avg_session_duration_minutes {
    type: average
    value_format_name: decimal_1
    sql: ${session_duration_minutes}::float ;;

    filters: {
      field: session_duration_minutes
      value: "> 0"
    }
  }

  measure: avg_tracks_per_session {
    type: average
    value_format_name: decimal_1
    sql: ${tracks_count}::float ;;
  }

  measure: average_events_per_session {
    type: average
    sql: ${total_events} ;;
  }

  measure: products_viewed_total {
    type: sum
    sql: ${products_viewed} ;;
    group_label: "Product Viewed"
  }

  measure: products_viewed_per_session {
    type: average
    sql: ${products_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product Viewed"
  }

  measure: total_product_viewed_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Product Viewed"

    filters: {
      field: products_viewed
      value: ">0"
    }
  }

  measure: products_viewed_per_converted_user {
    type: number
    sql: ${products_viewed_total} / ${total_product_viewed_users};;
    value_format_name:decimal_2
    group_label: "Product Viewed"
  }

  measure: product_viewed_conversion_rate {
    type: number
    sql: ${total_product_viewed_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
  }

  measure: count_bounced_sessions {
    type: count_distinct
    sql: ${is_bounced_session} ;;

    filters: {
      field: is_bounced_session
      value: "Bounced Session"
    }
  }

  measure: bounce_rate {
    type: number
    sql: ${count_bounced_sessions} / ${sessions.count_sessions} ;;
  }

}
