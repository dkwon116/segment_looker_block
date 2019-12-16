view: event_facts {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        t.event_id
        , es.session_id
        , j.journey_id
        , jg.journey_group_id
        , p.page_path_id
        , t.anonymous_id
        , t.looker_visitor_id
        , t.timestamp
        , t.event
        , t.event_source
        , t.referrer as referrer
        , t.campaign_source as campaign_source
        , t.campaign_medium as campaign_medium
        , t.campaign_name as campaign_name
        , t.campaign_content as campaign_content
        , t.campaign_term as campaign_term
        , t.ip as ip
        , t.page_url as url
        , t.page_path
        , coalesce(o.vendor, os.retailer) as vendor
        , o.total as order_value
        , es.event_sequence as event_sequence
        , es.source_sequence as source_sequence
        , s.first_referrer
        , s.first_source
        , s.first_medium
        , s.first_campaign
        , s.first_content
        , s.first_term
        , s.user_agent as user_agent
        , CASE
            WHEN s.user_agent LIKE '%Mobile%' THEN "Mobile"
            ELSE "Desktop" END as platform
        , CASE
            -- Discovery engaged for anyone started Discovery journey
            WHEN t.event in ("Search","Product Search", "Hashtag", "Category", "New", "Sale", "Brand") THEN "Discovery"
            -- Cashback engaged for anyone started Cashback related journey
            WHEN t.event in ("retailer_clicked", "About Cashback", "How to Cashback", "Cashback Retailer", "Retailer Coupon", "Promotions") THEN "Cashback"
            ELSE "Other"
          END as event_type
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${event_sessions.SQL_TABLE_NAME} as es
        on t.event_id = es.event_id
        and t.looker_visitor_id = es.looker_visitor_id
      left join ${sessions.SQL_TABLE_NAME} as s
        on s.session_id = es.session_id
      left join ${journeys.SQL_TABLE_NAME} as j
        on j.session_id=es.session_id
        and es.event_sequence between j.first_journey_event_sequence and j.last_journey_event_sequence
      left join ${journey_groups.SQL_TABLE_NAME} as jg
        on jg.session_id=es.session_id
        and es.event_sequence between jg.first_journey_group_event_sequence and jg.last_journey_group_event_sequence
      left join ${page_path.SQL_TABLE_NAME} as p
        on p.session_id=es.session_id
        and es.event_sequence between p.first_page_path_event_sequence and p.last_page_path_event_sequence
      left join ${orders.SQL_TABLE_NAME} as o
        on t.looker_visitor_id = o.user_id
        and t.event_id=o.order_id
      left join javascript.outlink_sent_view as os
        on t.looker_visitor_id = os.user_id
        and t.event_id=os.id
      ;;
  }

  dimension: event_id {
    primary_key: yes
    #     hidden: true
    sql: ${TABLE}.event_id ;;
  }

  dimension: journey_id {
    type: string
    sql: ${TABLE}.journey_id ;;
  }

  dimension: journey_group_id {
    type: string
    sql: ${TABLE}.journey_group_id ;;
  }

  dimension: page_path_id {
    type: string
    sql: ${TABLE}.page_path_id ;;
  }

  dimension: session_id {
    sql: ${TABLE}.session_id ;;
  }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: event_source {
    sql: ${TABLE}.event_source ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, hour, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: first_referrer {
    group_label: "Attribution"
    sql: ${TABLE}.first_referrer ;;
  }

  dimension: first_referrer_domain {
    group_label: "Attribution"
    sql: NET.REG_DOMAIN(${first_referrer}) ;;
  }

  dimension: first_campaign {
    group_label: "Attribution"
    type:  string
    sql: ${TABLE}.first_campaign ;;
  }

  dimension: first_source {
    group_label: "Attribution"
    type:  string
    sql: ${TABLE}.first_source ;;
  }

  dimension: first_medium {
    group_label: "Attribution"
    type:  string
    sql: ${TABLE}.first_medium ;;
  }

  dimension: first_content {
    group_label: "Attribution"
    type:  string
    sql: ${TABLE}.first_content ;;
  }

  dimension: first_term {
    group_label: "Attribution"
    type:  string
    sql: ${TABLE}.first_term ;;
  }

  dimension: ip {
    group_label: "Event Context"
    sql: ${TABLE}.ip ;;
  }

  dimension: referrer {
    group_label: "Event Context"
    sql: ${TABLE}.referrer ;;
  }

  dimension: url {
    group_label: "Event Context"
    sql: ${TABLE}.url ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/19?UserID= {{value | encode_url}}"
      icon_url: "https://looker.com/favicon.ico"
    }
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: sequence_number {
    group_label: "Event Context"
    type: number
    sql: ${TABLE}.event_sequence ;;
  }

  dimension: source_sequence {
    group_label: "Event Context"
    type: number
    sql: ${TABLE}.source_sequence ;;
  }

  dimension: user_agent {
    group_label: "Event Context"
    type: string
    sql: ${TABLE}.user_agent ;;
  }

  dimension: vendor {
    type: string
    sql: CASE
            WHEN lower(${TABLE}.vendor) LIKE "%saks%" THEN "Saks"
            WHEN lower(${TABLE}.vendor) LIKE '%neiman%' THEN "Neiman"
            WHEN lower(${TABLE}.vendor) IN ("net-a-porter", "netaporter") THEN "NAP"
            WHEN lower(${TABLE}.vendor) LIKE "%barneys%" THEN "Barneys"
            WHEN lower(${TABLE}.vendor) LIKE "%bergdorf%" THEN "Bergdorf"
            WHEN lower(${TABLE}.vendor) LIKE "%browns%" THEN "Browns"
            ELSE lower(${TABLE}.vendor)
          END;;
  }

  dimension: order_value {
    type: number
    sql: ${TABLE}.order_value ;;
    value_format_name: decimal_0
  }

  dimension: device {
    group_label: "Event Context"
    type: string
    sql:  CASE
            WHEN ${user_agent} LIKE '%iPhone%' THEN "iPhone"
            WHEN ${user_agent} LIKE '%Android%' THEN "Android"
            WHEN ${user_agent} LIKE '%Macintosh%' THEN "Mac"
            WHEN ${user_agent} LIKE '%Windows%' THEN "Windows"
            ELSE "Other"
          END;;
  }

  dimension: platform {
    group_label: "Event Context"
    type: string
    sql:  ${TABLE}.platform ;;
  }

  dimension: in_app {
    group_label: "Event Context"
    type: string
    sql:  CASE
            WHEN ${user_agent} LIKE '%KAKAO%' THEN "Kakao"
            WHEN ${user_agent} LIKE '%Instagram%' THEN "Insta"
            WHEN ${user_agent} LIKE '%NAVER%' THEN "Naver"
            ELSE "Other"
          END;;
  }

  measure: unique_visitor_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "All"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }


  measure: unique_product_viewed_visitor_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "Product Viewed"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "Product"
    }
  }

  measure: unique_outlinked_visitor_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "Outlinked"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "outlink_sent"
    }
  }

  measure: unique_order_completed_visitor_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "Order Completed"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "order_completed"
    }
  }

  measure: unique_vendor_outlinked_user_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "Vendor Outlinked"
    type: count_distinct
    sql:
    CASE
      WHEN {% condition vendor_to_count %} ${vendor} {% endcondition %} AND ${event} = 'outlink_sent'
      THEN ${looker_visitor_id}
      ELSE ""
    END
  ;;
  }

  measure: unique_vendor_ordered_visitor_count {
    group_label: "Number of Unique Visitors"
    group_item_label: "Vendor Ordered"
    type: count_distinct
    sql:
    CASE
      WHEN {% condition vendor_to_count %} ${vendor} {% endcondition %} AND ${event} = 'order_completed'
      THEN ${looker_visitor_id}
      ELSE ""
    END
  ;;
  }

  filter: vendor_to_count {
#     type: string
    suggest_dimension: vendor
  }

  measure: count {
    label: "Number of Events"
    type: count
    drill_fields: [user_facts.looker_visitor_id, users.name, user_agent]
  }

  measure: events_per_visitor {
    label: "Number of Events per Visitor"
    type: number
    sql: ${count} / NULLIF(${unique_visitor_count},0) ;;
    value_format_name: decimal_1
    drill_fields: [event, looker_visitor_id, users.name, count]
  }


################################################
##   SIMPLE FUNNEL

  filter: event1 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
    group_label: "Session Funnel"
  }


  filter: event2 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
    group_label: "Session Funnel"
  }


  filter: event3 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
    group_label: "Session Funnel"
  }

  filter: event4 {
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
    group_label: "Session Funnel"
  }

  measure: event1_session_count {
    type: number
    group_label: "Session Funnel"
    sql: COUNT(
            DISTINCT CASE WHEN
            {% condition event1 %} ${event} {% endcondition %}
              THEN ${session_id}
            ELSE NULL END
        ) ;;
  }

  measure: event2_session_count {
    type: number
    group_label: "Session Funnel"
    sql: COUNT(
            DISTINCT CASE WHEN
            {% condition event2 %} ${event} {% endcondition %}
              THEN ${session_id}
            ELSE NULL END
        ) ;;
  }

  measure: event3_session_count {
    type: number
    group_label: "Session Funnel"
    sql: COUNT(
            DISTINCT CASE WHEN
            {% condition event3 %} ${event} {% endcondition %}
              THEN ${session_id}
            ELSE NULL END
        ) ;;
  }

  measure: event4_session_count {
    type: number
    group_label: "Session Funnel"
    sql: COUNT(
            DISTINCT CASE WHEN
            {% condition event4 %} ${event} {% endcondition %}
              THEN ${session_id}
            ELSE NULL END
        ) ;;
  }
}
