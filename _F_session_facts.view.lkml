view: session_facts {
  derived_table: {
#     information about session
    # Rebuilds after track_facts rebuilds
    sql_trigger_value: select COUNT(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql: select
          s.session_id
        , t2s.first_referrer
        , max(t2s.timestamp) as end_at
        , t2s.first_source as first_source
        , t2s.first_medium as first_medium
        , t2s.first_campaign as first_campaign
        , count(case when t2s.event_source = 'tracks' then 1 else null end) as tracks_count
        , count(case when t2s.event_source = 'pages' then 1 else null end) as pages_count
        , count(case when t2s.event = 'product_viewed' then event_id else null end) as count_product_viewed
        , count(case when t2s.event = 'product_list_viewed' then event_id else null end) as count_product_list_viewed
        , count(case when t2s.event = 'outlink_sent' then event_id else null end) as count_outlinked
        , count(case when t2s.event = 'concierge_clicked' then event_id else null end) as count_concierge_clicked
        , count(case when t2s.event = 'order_completed' then event_id else null end) as count_order_completed
      from ${sessions.SQL_TABLE_NAME} as s
        inner join ${event_facts.SQL_TABLE_NAME} as t2s
          on s.session_id = t2s.session_id
      group by 1,2,4,5,6
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
    sql: CASE
    WHEN ${first_referrer} like '%facebook%' THEN 'Facebook'
    WHEN ${first_referrer} like '%google%' THEN 'Google'
    WHEN ${first_referrer} like '%naver%' THEN 'Naver'
    WHEN ${first_referrer} like '%instagram%' THEN 'Instagram'
    WHEN ${first_referrer} like '%catchfashion%' THEN 'Catch'
    WHEN ${first_referrer} IS NULL THEN 'Direct'
    ELSE 'Other' END ;;
  }

  dimension: first_campaign {
    type:  string
    sql: ${TABLE}.first_campaign ;;
  }

  dimension: first_source {
    type:  string
    sql: ${TABLE}.first_source ;;
    drill_fields: [first_campaign, first_medium]
  }

  dimension: first_medium {
    type:  string
    sql: ${TABLE}.first_medium ;;
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
    sql: timestamp_diff(TIMESTAMP(${end_time}), TIMESTAMP(${sessions.start_time}), minute) ;;
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

  dimension: concierge_clicked {
    type: number
    sql: ${TABLE}.count_concierge_clicked ;;
  }

  dimension: order_completed {
    type: number
    sql: ${TABLE}.count_order_completed ;;
  }

  # dimension: days_since_first_visit {
  #   hidden: yes
  #   type: number
  #   sql: DATEDIFF(${sessions.start_raw}, ${user_facts.first_visited});;
  # }

  # dimension: weeks_since_first_visit {
  #   type: number
  #   sql: FLOOR(${days_since_first_visit}/(7)) ;;
  # }

  # dimension: months_since_first_visit {
  #   type: number
  #   sql: FLOOR(${days_since_first_visit}/(30)) ;;
  # }

  # dimension: months_since_first_visit_tier {
  #   type: tier
  #   tiers: [1,3,6,12,24]
  #   style: integer
  #   sql: ${months_since_first_visit} ;;
  # }

  # ----- Measures -----

  measure: pages_per_session {
    type: average
    sql: ${pages_count} ;;
    value_format_name: "decimal_1"
  }

  measure: avg_session_duration_minutes {
    type: average
    value_format_name: decimal_1
    sql: ${session_duration_minutes};;

#     filters: {
#       field: session_duration_minutes
#       value: "> 0"
#     }
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

  measure: cumulative_session_duration {
    type: sum
    sql: ${session_duration_minutes} ;;
  }

  measure: average_session_duration_per_user {
    type: number
    sql: ${cumulative_session_duration} / ${sessions.count_visitors} ;;
  }


######################################
#   Product list measures

  measure: product_list_viewed_total {
    type: sum
    sql: ${product_lists_viewed} ;;
    group_label: "Product List Viewed"
#     drill_fields: []
  }

  measure: product_list_viewed_per_session {
    type: average
    sql: ${product_lists_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product List Viewed"
    drill_fields: [campaign_details*, product_viewed_details*]
  }

  measure: total_product_list_viewed_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Product List Viewed"

    filters: {
      field: product_lists_viewed
      value: ">0"
    }
  }

  measure: product_list_viewed_per_converted_user {
    type: number
    sql: ${product_list_viewed_total} / NULLIF(${total_product_list_viewed_users}, 0);;
    value_format_name:decimal_2
    group_label: "Product List Viewed"
  }

  measure: product_list_viewed_conversion_rate {
    type: number
    sql: ${total_product_list_viewed_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_0
    group_label: "Product List Viewed"
    drill_fields: [product_viewed_details*]
  }


######################################
#   Product viewed measures
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
    drill_fields: [campaign_details*, product_viewed_details*]
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

  measure: total_product_viewed_activated_user {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Product Viewed"

    filters: {
      field: products_viewed
      value: ">4"
    }
  }

  measure: products_viewed_per_converted_user {
    type: number
    sql: ${products_viewed_total} / NULLIF(${total_product_viewed_users}, 0);;
    value_format_name:decimal_2
    group_label: "Product Viewed"
  }

  measure: product_viewed_conversion_rate {
    type: number
    sql: ${total_product_viewed_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
    drill_fields: [product_viewed_details*]
  }

  measure: product_viewed_activation_rate {
    type: number
    sql: ${total_product_viewed_activated_user} / ${sessions.count_visitors} ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
    drill_fields: [product_viewed_details*]
  }


######################################
#   measures for outlink
  measure: outlinked_total {
    type: sum
    sql: ${outlinked} ;;
    group_label: "Outlinked"
  }

  measure: outlinked_per_session {
    type: average
    sql: ${outlinked} ;;
    value_format_name:decimal_2
    group_label: "Outlinked"
    drill_fields: [campaign_details*, product_viewed_details*]
  }

  measure: total_outlinked_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Outlinked"

    filters: {
      field: outlinked
      value: ">0"
    }
  }

  measure: outlinked_per_converted_user {
    type: number
    sql: ${outlinked_total} / NULLIF(${total_outlinked_users}, 0) ;;
    value_format_name:decimal_2
    group_label: "Outlinked"
  }

  measure: outlinked_conversion_rate {
    type: number
    sql: ${total_outlinked_users} / NULLIF(${sessions.count_visitors}, 0) ;;
    value_format_name: percent_0
    group_label: "Outlinked"
  }

#   measures for concierge
  measure: concierge_clicked_total {
    type: sum
    sql: ${concierge_clicked} ;;
    group_label: "Concierge"
  }

  measure: concierge_per_session {
    type: average
    sql: ${concierge_clicked} ;;
    value_format_name:decimal_2
    group_label: "Concierge"
    drill_fields: [campaign_details*, product_viewed_details*]
  }

  measure: total_concierge_clicked_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Concierge"

    filters: {
      field: concierge_clicked
      value: ">0"
    }
  }

  measure: concierge_conversion_rate {
    type: number
    sql: ${total_concierge_clicked_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_2
    group_label: "Concierge"
  }

  measure: count_bounced_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;

    filters: {
      field: is_bounced_session
      value: "Bounced Session"
    }
  }


######################################
#   measures for outlink

  measure: order_completed_total {
    type: sum
    sql: ${order_completed} ;;
    group_label: "Order Completed"
  }

  measure: order_completed_per_session {
    type: average
    sql: ${order_completed} ;;
    value_format_name:decimal_2
    group_label: "Order Completed"
    drill_fields: [campaign_details*]
  }

  measure: total_order_completed_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Order Completed"

    filters: {
      field: order_completed
      value: ">0"
    }
  }

  measure: order_completed_per_converted_user {
    type: number
    sql: ${order_completed_total} / NULLIF(${total_order_completed_users}, 0);;
    value_format_name:decimal_2
    group_label: "Order Completed"
  }

  measure: order_completed_conversion_rate {
    type: number
    sql: ${total_order_completed_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_2
    group_label: "Order Completed"
    drill_fields: [order_completed_details*]
  }


  measure: bounce_rate {
    type: number
    sql: ${count_bounced_sessions} / ${sessions.count_sessions} ;;
    value_format_name: percent_2
    drill_fields: [campaign_details*]
  }


  set: campaign_details {
    fields: [first_source, sessions.count_sessions, bounce_rate, pages_per_session, avg_session_duration_minutes, product_viewed_conversion_rate]
  }

  set: product_viewed_details {
    fields: [first_source, product_viewed_activation_rate, products_viewed_per_session, product_viewed_conversion_rate]
  }

  set: order_completed_details {
    fields: []
  }
}
