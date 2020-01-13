# duration of journey group
# number of product viewed / list viewed / outlinked / added_to_wishlist


view: journey_group_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${journey_groups.SQL_TABLE_NAME} ;;
    sql:
      select
        j.journey_group_id
        ,j.session_id
        ,j.looker_visitor_id
        ,min(e.timestamp) as start_at
        ,max(e.timestamp) as end_at
        ,timestamp_diff(max(e.timestamp), min(e.timestamp), second) as journey_group_duration_seconds

          -- event facts
        , count(case when e.event_source = 'tracks' then 1 else null end) as number_of_track_events
        , count(case when e.event_source = 'pages' then 1 else null end) as number_of_page_events
        , count(case when e.event = "signed_up" then event_id else null end) as number_of_signed_up_events
        , count(case when e.event = 'Product' then event_id else null end) as count_product_viewed
        , count(distinct case when e.event = 'Product' then REGEXP_EXTRACT(e.page_path,"^/.*/(.*)$") else null end) as unique_count_product_viewed
        , count(case when e.event = 'product_list_viewed' then event_id else null end) as count_product_list_viewed
        , count(distinct case when e.event = 'product_list_viewed' then REGEXP_EXTRACT(e.page_path,"^/.*/(.*)$") else null end) as unique_count_product_list_viewed
        , count(case when e.event = 'outlink_sent' then event_id else null end) as count_outlinked
        , count(case when e.event = 'concierge_clicked' then event_id else null end) as count_concierge_clicked
        , count(case when e.event = 'product_added_to_wishlist' then event_id else null end) as count_added_to_wishlist

      from ${event_facts.SQL_TABLE_NAME} e
        inner join ${journey_groups.SQL_TABLE_NAME} as j
          on j.journey_group_id=e.journey_group_id

      group by 1,2,3
;;
  }

  # ----- Dimensions -----

  dimension: journey_group_id  {
    primary_key: yes
    sql: ${TABLE}.journey_group_id;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    hidden: yes
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
    hidden: yes
  }

  dimension_group: start {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.start_at ;;
  }

  dimension_group: end {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.end_at ;;
  }

  dimension: journey_group_duration_seconds {
    type: number
    sql: ${TABLE}.journey_group_duration_seconds ;;
  }

  dimension: journey_group_duration_seconds_tier {
    type: tier
    sql: ${TABLE}.journey_group_duration_seconds ;;
    tiers: [1, 5, 10, 20, 30, 60]
  }

  dimension: number_of_track_events {
    type: number
    sql: ${TABLE}.number_of_track_events ;;
    group_label: "Event Counts"
  }

  dimension: number_of_track_events_tier {
    type: tier
    sql: ${number_of_track_events} ;;
    tiers: [1, 5, 10, 20, 30, 60]
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

  dimension: product_viewed {
    type: number
    sql: ${TABLE}.count_product_viewed ;;
    group_label: "Event Counts"
  }

  dimension: unique_product_viewed {
    type: number
    sql: ${TABLE}.unique_count_product_viewed ;;
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

  dimension: number_of_engagements {
    type: number
    sql: ${TABLE}.count_product_viewed + ${TABLE}.count_outlinked + ${TABLE}.count_concierge_clicked + ${TABLE}.count_added_to_wishlist ;;
    group_label: "Event Counts"
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
    group_label: "Journey Facts"
  }

  measure: total_journey_group_duration {
    type: sum
    sql: ${journey_group_duration_seconds} ;;
    value_format_name: decimal_0
    group_label: "Journey Facts"
  }

  measure: avg_journey_group_duration {
    type: average
    value_format_name: decimal_1
    sql: ${journey_group_duration_seconds};;
    group_label: "Journey Facts"
  }

  measure: avg_journey_group_duration_per_session {
    type: number
    value_format_name: decimal_1
    sql: ${total_journey_group_duration}/nullif(${sessions.count},0);;
    group_label: "Journey Facts"
  }

  measure: var_journey_group_duration {
    type: number
    sql: var_samp(${journey_group_duration_seconds}) ;;
    group_label: "Journey Facts"
  }

  measure: avg_track_events {
    type: average
    value_format_name: decimal_1
    sql: ${number_of_track_events}::float ;;
    group_label: "Journey Facts"
  }

  measure: avg_events {
    type: average
    sql: ${number_of_events} ;;
    value_format_name: decimal_1
    group_label: "Journey Facts"
  }

  measure: journey_group_duration_per_unique_visitor {
    type: number
    sql: ${total_journey_group_duration} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: decimal_2
  }

  measure: total_discovery_journey_group_duration {
    type: sum
    sql: ${journey_group_duration_seconds} ;;
    group_label: "Product Discovery"
    group_item_label: "Total Duration"

    filters: {
      field: journey_groups.is_discovery
      value: "yes"
    }
  }

  measure: avg_discovery_journey_duration {
    type: average
    sql: ${journey_group_duration_seconds} ;;
    group_label: "Product Discovery"
    group_item_label: "Avg Duration"
    value_format_name: decimal_0

    filters: {
      field: journey_groups.is_discovery
      value: "yes"
    }
  }

  measure: discovery_journey_group_duration_per_discovery_journey_user {
    type: number
    sql: ${total_discovery_journey_group_duration} / NULLIF(${journey_groups.unique_discovery_journey_visitor_count}, 0) ;;
    value_format_name: decimal_0
    group_label: "Product Discovery"
    group_item_label: "Journey Group Duration per Discovery User"
  }

######################################

#   Engagement measures

  measure: engaged_journey_group_count {
    type: count
    group_label: "Engagements"
    filters: {
      field: number_of_engagements
      value: ">0"
    }
  }

  measure: engaged_total {
    type: sum
    sql: ${number_of_engagements} ;;
    group_label: "Engagements"
  }

  measure: engaged_per_journey_group {
    type: average
    sql: ${number_of_engagements} ;;
    value_format_name:decimal_2
    group_label: "Engagements"
  }

  measure: engaged_per_engaged_journey_group {
    type: average
    sql: ${number_of_engagements} ;;
    value_format_name:decimal_2
    group_label: "Engagements"
    filters: {
      field: number_of_engagements
      value: ">0"
    }
  }

  measure: engaged_conversion_rate_per_journey_group {
    type: number
    sql: ${engaged_journey_group_count} / NULLIF(${journey_groups.count},0) ;;
    value_format_name: percent_0
    group_label: "Engagements"
  }






#   Product list measures

  measure: product_list_viewed_journey_group_count {
    type: count
    group_label: "Product List Viewed"
    filters: {
      field: product_lists_viewed
      value: ">0"
    }
  }

  measure: product_list_viewed_total {
    type: sum
    sql: ${product_lists_viewed} ;;
    group_label: "Product List Viewed"
#     drill_fields: []
  }

  measure: product_list_viewed_per_journey_group {
    type: average
    sql: ${product_lists_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product List Viewed"
  }

  measure: total_product_list_viewed_users {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
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
    sql: ${total_product_list_viewed_users} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: percent_0
    group_label: "Product List Viewed"
  }


######################################
#   Product viewed measures
  measure: product_viewed_journey_group_count {
    type: count
    group_label: "Product Viewed"
    filters: {
      field: product_viewed
      value: ">0"
    }
  }

  measure: product_viewed_total {
    type: sum
    sql: ${product_viewed} ;;
    group_label: "Product Viewed"
  }

  measure: product_viewed_per_journey_group {
    type: average
    sql: ${product_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product Viewed"
  }

  measure: product_viewed_per_product_viewed_journey_group {
    type: average
    sql: ${product_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product Viewed"
    filters: {
      field: product_viewed
      value: ">0"
    }
  }

  measure: product_viewed_per_user {
    type: number
    sql: ${product_viewed_total} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: decimal_2
    group_label: "Product Viewed"
  }

  measure: unique_product_viewed_per_product_viewed_journey_group {
    type: average
    sql: ${unique_product_viewed} ;;
    value_format_name:decimal_2
    group_label: "Product Viewed"
    filters: {
      field: product_viewed
      value: ">0"
    }
  }

  measure: total_product_viewed_users {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
    group_label: "Product Viewed"

    filters: {
      field: product_viewed
      value: ">0"
    }
  }

  measure: total_product_viewed_activated_user {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
    group_label: "Product Viewed"

    filters: {
      field: product_viewed
      value: ">4"
    }
  }

  measure: product_viewed_per_converted_user {
    type: number
    sql: ${product_viewed_total} / NULLIF(${total_product_viewed_users}, 0);;
    value_format_name:decimal_2
    group_label: "Product Viewed"
  }

  measure: product_viewed_conversion_rate {
    type: number
    sql: ${total_product_viewed_users} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
  }

  measure: product_viewed_conversion_rate_per_journey_group {
    type: number
    sql: ${product_viewed_journey_group_count} / NULLIF(${journey_groups.count},0) ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
  }

  measure: product_viewed_activation_rate {
    type: number
    sql: ${total_product_viewed_activated_user} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: percent_0
    group_label: "Product Viewed"
  }


######################################
#   measures for outlink
  measure: outlinked_journey_group_count {
    type: count
    group_label: "Outlinked"
    filters: {
      field: outlinked
      value: ">0"
    }
  }

  measure: outlinked_total {
    type: sum
    sql: ${outlinked} ;;
    group_label: "Outlinked"
  }

  measure: outlinked_per_journey_group {
    type: average
    sql: ${outlinked} ;;
    value_format_name:decimal_2
    group_label: "Outlinked"
  }

  measure: total_outlinked_users {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
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
    sql: ${total_outlinked_users} / NULLIF(${journey_groups.unique_visitor_count}, 0) ;;
    value_format_name: percent_2
    group_label: "Outlinked"
  }


######################################
#   measures for concierge
  measure: concierge_journey_group_count {
    type: count
    group_label: "Concierge"
    filters: {
      field: concierge_clicked
      value: ">0"
    }
  }

  measure: concierge_clicked_total {
    type: sum
    sql: ${concierge_clicked} ;;
    group_label: "Concierge"
  }

  measure: concierge_per_journey_group {
    type: average
    sql: ${concierge_clicked} ;;
    value_format_name:decimal_2
    group_label: "Concierge"
  }

  measure: total_concierge_clicked_users {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
    group_label: "Concierge"

    filters: {
      field: concierge_clicked
      value: ">0"
    }
  }

  measure: concierge_conversion_rate {
    type: number
    sql: ${total_concierge_clicked_users} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: percent_2
    group_label: "Concierge"
  }


######################################
#   measures for wishlist
  measure: added_to_wishlist_journey_group_count {
    type: count
    group_label: "Wishlist"
    filters: {
      field: added_to_wishlist
      value: ">0"
    }
  }

  measure: added_to_wishlist_total {
    type: sum
    sql: ${added_to_wishlist} ;;
    group_label: "Wishlist"
  }

  measure: added_to_wishlist_per_journey_group {
    type: average
    sql: ${added_to_wishlist} ;;
    value_format_name:decimal_2
    group_label: "Wishlist"
  }

  measure: total_added_to_wishlist_users {
    type: count_distinct
    sql: ${journey_groups.looker_visitor_id} ;;
    group_label: "Wishlist"

    filters: {
      field: added_to_wishlist
      value: ">0"
    }
  }

  measure: added_to_wishlist_conversion_rate {
    type: number
    sql: ${total_added_to_wishlist_users} / NULLIF(${journey_groups.unique_visitor_count},0) ;;
    value_format_name: percent_2
    group_label: "Wishlist"
  }




}
