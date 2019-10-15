view: session_facts {
  derived_table: {
#     information about session
    # Rebuilds after track_facts rebuilds
    sql_trigger_value: select COUNT(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql:

      select
        t.*
        ,last_value(t.first_source ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_source
        ,last_value(t.first_medium ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_medium
        ,last_value(t.first_campaign ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_campaign
        ,last_value(t.first_content ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_content
        ,last_value(t.first_term ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_term
        ,last_value(if(coalesce(t.first_source,t.first_medium,t.first_campaign,t.first_content,t.first_term) is null,null,t.end_at) ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row) as last_end_at
        ,timestamp_diff(end_at,last_value(if(coalesce(t.first_source,t.first_medium,t.first_campaign,t.first_content,t.first_term) is null,null,t.end_at) ignore nulls) over (partition by t.looker_visitor_id order by t.end_at rows between unbounded preceding and current row),hour) as last_diff_hours
      from(
      select
          s.session_id
        , s.looker_visitor_id
        , t2s.first_referrer
        , t2s.first_source as first_source
        , t2s.first_medium as first_medium
        , t2s.first_campaign as first_campaign
        , t2s.first_content as first_content
        , t2s.first_term as first_term
        , t2s.first_purchased as first_ordered
        , max(t2s.timestamp) as end_at

        -- event facts
        , count(case when t2s.event_source = 'tracks' then 1 else null end) as number_of_track_events
        , count(case when t2s.event_source = 'pages' then 1 else null end) as number_of_page_events
        , count(case when t2s.event = "signed_up" then event_id else null end) as number_of_signed_up_events
        , count(case when t2s.event in ("Search","Product Search", "Hashtag", "Category", "New", "Sale", "Brand") then event_id else null end) as count_product_discovery
        , count(case when t2s.event = 'Product' then event_id else null end) as count_product_viewed
        , count(distinct case when t2s.event = 'Product' then REGEXP_EXTRACT(t2s.page_path,"^/.*/(.*)$") else null end) as unique_count_product_viewed
        , count(case when t2s.event = 'product_list_viewed' then event_id else null end) as count_product_list_viewed
        , count(distinct case when t2s.event = 'product_list_viewed' then REGEXP_EXTRACT(t2s.page_path,"^/.*/(.*)$") else null end) as unique_count_product_list_viewed
        , count(case when t2s.event = 'outlink_sent' then event_id else null end) as count_outlinked
        , count(case when t2s.event = 'concierge_clicked' then event_id else null end) as count_concierge_clicked
        , count(case when t2s.event = 'product_added_to_wishlist' then event_id else null end) as count_added_to_wishlist

        -- order_facts
        , count(case when t2s.event = 'order_completed' then event_id else null end) as count_order_completed
        , sum(case when t2s.event = 'order_completed' then t2s.order_value else 0 end) as order_value

        -- journey facts
        , count(distinct j.journey_id) as number_of_journeys
        , count(distinct case when j.is_discovery = true then j.journey_id else null end) as number_of_discovery_journeys
        , count(distinct case when j.is_search = true then j.journey_id else null end) as number_of_search_journeys

      from ${sessions.SQL_TABLE_NAME} as s
        inner join ${event_facts.SQL_TABLE_NAME} as t2s
          on s.session_id = t2s.session_id
        inner join ${journeys.SQL_TABLE_NAME} as j
          on s.session_id = j.session_id and t2s.journey_id = j.journey_id
      group by 1,2,3,4,5,6,7,8,9
      ) t
       ;;
  }

  # ----- Dimensions -----

  dimension: session_id {
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: first_referrer {
    sql: ${TABLE}.first_referrer ;;
    group_label: "Attribution"
    type: string
  }

  dimension: first_referrer_domain {
    sql: NET.REG_DOMAIN(${first_referrer}) ;;
    group_label: "Attribution"
    type: string
  }

  dimension: first_referral_name {
    sql: split(${first_referrer_domain}, ".")[OFFSET(0)]  ;;
    group_label: "Attribution"
    type: string
  }

  dimension: first_campaign {
    type:  string
    sql: ${TABLE}.first_campaign ;;
    group_label: "Attribution"
  }

  dimension: first_source {
    type:  string
    sql: ${TABLE}.first_source ;;
    drill_fields: [first_campaign, first_medium]
    group_label: "Attribution"
  }

  dimension: first_medium {
    type:  string
    sql: ${TABLE}.first_medium ;;
    group_label: "Attribution"
  }

  dimension: first_content {
    type:  string
    sql: ${TABLE}.first_content ;;
    group_label: "Attribution"
  }

  dimension: first_term {
    type:  string
    sql: ${TABLE}.first_term ;;
    group_label: "Attribution"
  }

  dimension: last_campaign {
    type:  string
    sql: ${TABLE}.last_campaign ;;
    group_label: "Attribution"
  }

  dimension: last_source {
    type:  string
    sql: ${TABLE}.last_source ;;
    drill_fields: [first_campaign, first_medium]
    group_label: "Attribution"
  }

  dimension: last_medium {
    type:  string
    sql: ${TABLE}.last_medium ;;
    group_label: "Attribution"
  }

  dimension: last_content {
    type:  string
    sql: ${TABLE}.last_content ;;
    group_label: "Attribution"
  }

  dimension: last_term {
    type:  string
    sql: ${TABLE}.last_term ;;
    group_label: "Attribution"
  }

  dimension: last_diff_hours {
    type: number
    sql: ${TABLE}.last_diff_hours ;;
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

  dimension: referrer {
    type: number
    sql: ${TABLE}.referrer ;;
  }

  dimension: number_of_track_events_tier {
    type: tier
    sql: ${number_of_track_events} ;;
    tiers: [1, 5, 10, 20, 30, 60]
  }


  dimension: is_bounced_session {
    sql:
      CASE WHEN ${number_of_events} = 1 THEN 'Bounced Session'
      ELSE 'Not Bounced Session' END
       ;;
    group_label: "Session Flags"
  }

  dimension: session_duration_minutes {
    type: number
    sql: timestamp_diff(TIMESTAMP(${end_time}), TIMESTAMP(${sessions.start_time}), minute) ;;
  }

  dimension: session_duration_minutes_tier {
    type: tier
    sql: ${session_duration_minutes} ;;
    tiers: [1, 5, 10, 20, 30, 60]
  }



  dimension: number_of_track_events {
    type: number
    sql: ${TABLE}.number_of_track_events ;;
    group_label: "Event Counts"
  }

  dimension: number_of_page_events {
    type:  number
    sql: ${TABLE}.number_of_page_events ;;
    group_label: "Event Counts"
  }

  dimension: number_of_events {
    type: number
    sql: ${number_of_track_events} + ${number_of_page_events} ;;
    group_label: "Event Counts"
  }

  dimension: number_of_signed_up_events {
    type:  number
    sql: ${TABLE}.number_of_signed_up_events ;;
    group_label: "Event Counts"
  }

  dimension: product_discovery {
    type: number
    sql: ${TABLE}.count_product_discovery ;;
    group_label: "Event Counts"
    description: "Viewed Search, Category, Brand, Hashtag, New, Sale Product List"
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
    sql: ${number_of_page_events} ;;
    value_format_name: "decimal_0"
  }

  measure: avg_page_events {
    type: average
    sql: ${number_of_page_events} ;;
    value_format_name: "decimal_1"
    group_label: "Session Facts"
  }

  measure: avg_session_duration_minutes {
    type: average
    value_format_name: decimal_1
    sql: ${session_duration_minutes};;
    group_label: "Session Facts"
  }

  measure: avg_track_events {
    type: average
    value_format_name: decimal_1
    sql: ${number_of_track_events}::float ;;
    group_label: "Session Facts"
  }

  measure: avg_events {
    type: average
    sql: ${number_of_events} ;;
    value_format_name: decimal_1
    group_label: "Session Facts"
  }

  measure: total_session_duration {
    type: sum
    sql: ${session_duration_minutes} ;;
    value_format_name: decimal_0
    group_label: "Session Facts"
  }

  measure: session_duration_per_unique_visitor {
    type: number
    sql: ${total_session_duration} / ${sessions.unique_visitor_count} ;;
    value_format_name: decimal_2
  }

  measure: unique_pre_purchase_visitor_count {
    description: "Count of distinct users who have not made purchase yet"
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    filters: {
      field: is_pre_purchase
      value: "yes"
    }
  }

  measure: unique_signed_up_visitor {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    filters: {
      field: number_of_signed_up_events
       value: ">0"
    }
  }

  measure: unique_visitor_signup_conversion {
    type: number
    sql: ${unique_signed_up_visitor} / ${sessions.unique_visitor_count};;
    value_format_name: percent_2
  }




######################################
#   Product Discovery measures

  measure: product_discovery_viewed_total {
    type: sum
    sql: ${product_discovery} ;;
    group_label: "Product Discovery"
#     drill_fields: []
  }

  measure: product_discovery_viewed_per_session {
    type: average
    sql: ${product_discovery} ;;
    value_format_name:decimal_2
    group_label: "Product Discovery"
    drill_fields: [campaign_details*, product_viewed_details*]
  }

  measure: total_product_discovery_viewed_users {
    type: count_distinct
    sql: ${sessions.looker_visitor_id} ;;
    group_label: "Product Discovery"

    filters: {
      field: product_discovery
      value: ">0"
    }
  }

  measure: total_product_discovery_viewed_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
    group_label: "Product Discovery"

    filters: {
      field: product_discovery
      value: ">0"
    }
  }

  measure: product_discovery_session_durations {
    type: average
    sql: ${session_duration_minutes} ;;
    group_label: "Product Discovery"
    value_format_name: decimal_1

    filters: {
      field: product_discovery
      value: ">0"
    }

  }

  measure: product_discovery_viewed_per_converted_user {
    type: number
    sql: ${product_discovery_viewed_total} / NULLIF(${total_product_discovery_viewed_users}, 0);;
    value_format_name:decimal_2
    group_label: "Product Discovery"
  }

  measure: product_discovery_viewed_conversion_rate {
    type: number
    sql: ${total_product_discovery_viewed_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_0
    group_label: "Product Discovery"
    drill_fields: [product_viewed_details*]
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

  measure: total_product_list_viewed_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
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
    sql: ${total_product_list_viewed_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_0
    group_label: "Product List Viewed"
    drill_fields: [product_viewed_details*]
  }

  measure: product_list_viewed_conversion_rate_per_session {
    type: number
    sql: ${total_product_list_viewed_sessions} / ${sessions.unique_session_count} ;;
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
    sql: ${products_viewed_total} / ${sessions.unique_visitor_count} ;;
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

  measure: total_product_viewed_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
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
    sql: ${total_product_viewed_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
    drill_fields: [product_viewed_details*]
  }

  measure: product_viewed_conversion_rate_per_session {
    type: number
    sql: ${total_product_viewed_sessions} / ${sessions.unique_session_count} ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
    drill_fields: [product_viewed_details*]
  }

  measure: product_viewed_activation_rate {
    type: number
    sql: ${total_product_viewed_activated_user} / ${sessions.unique_visitor_count} ;;
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

  measure: total_outlinked_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
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
    sql: ${total_outlinked_users} / NULLIF(${sessions.unique_visitor_count}, 0) ;;
    value_format_name: percent_2
    group_label: "Outlinked"
  }

  measure: outlinked_conversion_rate_per_session {
    type: number
    sql: ${total_outlinked_sessions} / NULLIF(${sessions.unique_session_count}, 0) ;;
    value_format_name: percent_2
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

  measure: total_concierge_clicked_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
    group_label: "Concierge"

    filters: {
      field: concierge_clicked
      value: ">0"
    }
  }

  measure: concierge_conversion_rate {
    type: number
    sql: ${total_concierge_clicked_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_2
    group_label: "Concierge"
  }

  measure: concierge_conversion_rate_per_session {
    type: number
    sql: ${total_concierge_clicked_sessions} / ${sessions.unique_session_count} ;;
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

  measure: total_added_to_wishlist_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
    group_label: "Wishlist"

    filters: {
      field: added_to_wishlist
      value: ">0"
    }
  }

  measure: added_to_wishlist_conversion_rate {
    type: number
    sql: ${total_added_to_wishlist_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_2
    group_label: "Wishlist"
  }

  measure: added_to_wishlist_conversion_rate_per_session {
    type: number
    sql: ${total_added_to_wishlist_sessions} / ${sessions.unique_session_count} ;;
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

  measure: total_order_completed_sessions {
    type: count_distinct
    sql: ${sessions.session_id} ;;
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
    sql: ${total_order_completed_users} / ${sessions.unique_visitor_count} ;;
    value_format_name: percent_2
    group_label: "Order Completed"
    drill_fields: [order_completed_details*]
  }

  measure: order_completed_conversion_rate_per_session {
    type: number
    sql: ${total_order_completed_sessions} / ${sessions.unique_session_count} ;;
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
    sql: ${count_bounced_sessions} / ${sessions.count} ;;
    value_format_name: percent_2
    drill_fields: [campaign_details*]
    group_label: "Session Facts"
  }


  set: campaign_details {
    fields: [first_source, sessions.count, bounce_rate, avg_page_events, avg_session_duration_minutes, product_viewed_conversion_rate]
  }

  set: product_viewed_details {
    fields: [first_source, product_viewed_activation_rate, products_viewed_per_session, product_viewed_conversion_rate]
  }

  set: order_completed_details {
    fields: []
  }
}
