view: event_facts {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
    select
        t.event_id
        , j.journey_id
        , es.session_id

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
        , first_value(t.referrer) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_referrer
        , first_value(t.campaign_source) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_source
        , first_value(t.campaign_medium) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_medium
        , first_value(t.campaign_name) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_campaign
        , first_value(t.campaign_content) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_content
        , first_value(t.campaign_term) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_term
        , first_value(t.user_agent) over (partition by es.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as user_agent
        , first_value(o.transaction_at IGNORE NULLS) over (partition by t.looker_visitor_id order by o.order_sequence_number rows between unbounded preceding and unbounded following) as first_purchased
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${event_sessions.SQL_TABLE_NAME} as es
        on t.event_id = es.event_id
        and t.looker_visitor_id = es.looker_visitor_id
      left join ${journeys.SQL_TABLE_NAME} as j
        on j.session_id=es.session_id
        and es.event_sequence between j.first_journey_event_sequence and j.last_journey_event_sequence
      left join ${orders.SQL_TABLE_NAME} as o
        on t.looker_visitor_id = o.user_id
        --and t.event_id = CONCAT(cast(o.transaction_at as string), o.user_id, '-r')
        and t.event_id=o.order_id
      left join javascript.outlink_sent_view as os
        on t.looker_visitor_id = os.user_id
        --and t.event_id = CONCAT(cast(os.timestamp AS string), os.anonymous_id, '-t')
        and t.event_id=outlink_sent_view.id
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

  dimension_group: first_purchased {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.first_purchased ;;
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

  dimension: is_user_at_event {
    group_label: "Event Flag"
    type: yesno
    sql: IF(${anonymous_id}=${looker_visitor_id}, false, true)  ;;
  }

  dimension: is_pre_purchase {
    group_label: "Event Flag"
    type: yesno
    sql: IF(${first_purchased_time} IS NULL, true,
    IF(${timestamp_time} <= ${first_purchased_time}, true, false))  ;;
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
    sql:  CASE
            WHEN ${user_agent} LIKE '%Mobile%' THEN "Mobile"
            ELSE "Desktop" END;;
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
    sql: ${count} / ${unique_visitor_count} ;;
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
