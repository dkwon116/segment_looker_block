view: session_facts {
  derived_table: {
#     information about session
    # Rebuilds after track_facts rebuilds
    sql_trigger_value: select COUNT(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql: select
          s.session_id
        , t2s.first_referrer
        , t2s.first_source as first_source
        , t2s.first_medium as first_medium
        , t2s.first_campaign as first_campaign
        , t2s.first_content as first_content
        , t2s.first_term as first_term
        , t2s.first_purchased as first_ordered
        , max(t2s.timestamp) as end_at
        , sum(case when t2s.event = 'order_completed' then t2s.order_value else 0 end) as order_value
        , count(case when t2s.event_source = 'tracks' then 1 else null end) as tracks_count
        , count(case when t2s.event_source = 'pages' then 1 else null end) as pages_count
        , count(case when t2s.event = "signed_up" then event_id else null end) as count_signed_up
        , count(case when t2s.event = 'Product' then event_id else null end) as count_product_viewed
        , count(case when t2s.event = 'product_list_viewed' then event_id else null end) as count_product_list_viewed
        , count(case when t2s.event = 'outlink_sent' then event_id else null end) as count_outlinked
        , count(case when t2s.event = 'concierge_clicked' then event_id else null end) as count_concierge_clicked
        , count(case when t2s.event = 'product_added_to_wishlist' then event_id else null end) as count_added_to_wishlist
        , count(case when t2s.event = 'order_completed' then event_id else null end) as count_order_completed
      from ${sessions.SQL_TABLE_NAME} as s
        inner join ${event_facts.SQL_TABLE_NAME} as t2s
          on s.session_id = t2s.session_id
      group by 1,2,3,4,5,6,7,8
       ;;
  }

  # ----- Dimensions -----

  dimension: session_id {
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: first_referrer {
    sql: ${TABLE}.first_referrer ;;
    group_label: "First"
  }

  dimension: first_referrer_domain {
    sql: split_part(${first_referrer},'/',3) ;;
    group_label: "First"
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
    group_label: "First"
  }

  dimension: first_campaign {
    type:  string
    sql: ${TABLE}.first_campaign ;;
    group_label: "First"
  }

  dimension: first_source {
    type:  string
    sql: ${TABLE}.first_source ;;
    drill_fields: [first_campaign, first_medium]
    group_label: "First"
  }

  dimension: first_medium {
    type:  string
    sql: ${TABLE}.first_medium ;;
    group_label: "First"
  }

  dimension: first_content {
    type:  string
    sql: ${TABLE}.first_content ;;
    group_label: "First"
  }

  dimension: first_term {
    type:  string
    sql: ${TABLE}.first_term ;;
    group_label: "First"
  }

  dimension: is_pre_purchase {
    type: yesno
    sql: IF(${TABLE}.first_ordered IS NULL, true,
      IF(${sessions.start_raw} <= ${TABLE}.first_ordered, true, false))  ;;
    group_label: "Session Flags"
  }

  dimension_group: end {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.end_at ;;
  }

  dimension: tracks_count {
    type: number
    sql: ${TABLE}.tracks_count ;;
    group_label: "Event Counts"
  }

  dimension: pages_count {
    type:  number
    sql: ${TABLE}.pages_count ;;
    group_label: "Event Counts"
  }

  dimension: total_events {
    type: number
    sql: ${tracks_count} + ${pages_count} ;;
    group_label: "Event Counts"
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
    sql:
      CASE WHEN ${total_events} = 1 THEN 'Bounced Session'
      ELSE 'Not Bounced Session' END
       ;;
    group_label: "Session Flags"
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

  dimension: signed_up {
    type:  number
    sql: ${TABLE}.count_signed_up ;;
    group_label: "Event Counts"
  }

  dimension: products_viewed {
    type: number
    sql: ${TABLE}.count_product_viewed ;;
    group_label: "Event Counts"
  }

  dimension: product_lists_viewed {
    type: number
    sql: ${TABLE}.count_product_list_viewed ;;
    group_label: "Event Counts"
  }

  dimension: outlinked {
    type: number
    sql: ${TABLE}.count_outlinked ;;
    group_label: "Event Counts"
  }

  dimension: concierge_clicked {
    type: number
    sql: ${TABLE}.count_concierge_clicked ;;
    group_label: "Event Counts"
  }

  dimension: added_to_wishlist {
    type: number
    sql: ${TABLE}.count_added_to_wishlist ;;
    group_label: "Event Counts"
  }

  dimension: order_completed {
    type: number
    sql: ${TABLE}.count_order_completed ;;
    group_label: "Event Counts"
  }

  dimension: order_value {
    type: number
    sql: ${TABLE}.order_value ;;
    value_format_name: decimal_0
  }

  dimension_group: since_first_visited {
    type: duration
    intervals: [day, week, month]
    sql_start: ${user_facts.first_visited_raw} ;;
    sql_end: ${sessions.start_raw} ;;
  }

  dimension_group: since_sign_up {
    type: duration
    intervals: [day, week, month]
    sql_start: ${user_facts.signed_up_raw} ;;
    sql_end: ${sessions.start_raw} ;;
  }

  dimension_group: since_first_purchase {
    type: duration
    intervals: [day, week, month]
    sql_start: ${user_facts.first_purchased_raw} ;;
    sql_end: ${sessions.start_raw} ;;
  }

  # ----- Measures -----

  measure: total_pages {
    type: sum
    sql: ${pages_count} ;;
    value_format_name: "decimal_0"
  }

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
    value_format_name: decimal_1
  }

  measure: cumulative_session_duration {
    type: sum
    sql: ${session_duration_minutes} ;;
    value_format_name: decimal_2
  }

  measure: average_session_duration_per_user {
    type: number
    sql: ${cumulative_session_duration} / ${sessions.count_visitors} ;;
    value_format_name: decimal_2
  }

  measure: total_signed_up {
    type: sum
    sql: ${signed_up} ;;
  }

  measure: signup_conversion {
    type: number
    sql: ${total_signed_up} / ${sessions.count_visitors};;
    value_format_name: percent_2
  }

  measure: pre_purchase_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    filters: {
      field: is_pre_purchase
      value: "yes"
    }
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

  measure: products_viewed_per_user {
    type: number
    sql: ${products_viewed_total} / ${sessions.count_visitors} ;;
    value_format_name: decimal_2
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

  measure: outlinked_user_value {
    type: number
    sql: ${total_order_value} / nullif(${total_outlinked_users}, 0) ;;
    value_format_name: decimal_0
    group_label: "Outlinked"
  }


######################################
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
#   measures for wishlist
  measure: added_to_wishlist_total {
    type: sum
    sql: ${added_to_wishlist} ;;
    group_label: "Wishlist"
  }

  measure: added_to_wishlist_per_session {
    type: average
    sql: ${added_to_wishlist} ;;
    value_format_name:decimal_2
    group_label: "Wishlist"
    drill_fields: [campaign_details*, product_viewed_details*]
  }

  measure: total_added_to_wishlist_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Wishlist"

    filters: {
      field: added_to_wishlist
      value: ">0"
    }
  }

  measure: added_to_wishlist_conversion_rate {
    type: number
    sql: ${total_added_to_wishlist_users} / ${sessions.count_visitors} ;;
    value_format_name: percent_2
    group_label: "Wishlist"
  }


######################################
#   measures for outlink

  measure: order_completed_total {
    type: sum
    sql: ${order_completed} ;;
    group_label: "Order Completed"
  }

  measure: total_order_value {
    type: sum
    sql: ${order_value} ;;
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

  measure: outlink_to_order_completed_conversion_rate {
    type: number
    sql: ${total_order_completed_users} / NULLIF(${total_outlinked_users}, 0) ;;
    value_format_name: percent_0
    group_label: "Order Completed"
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
