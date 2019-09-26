view: event_facts {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql: select t.timestamp
        , t.anonymous_id
        , t.event_id
        , t.event_source
        , t.event
        , s.session_id
        , t.looker_visitor_id
        , t.received
        , t.referrer as referrer
        , t.campaign_source as campaign_source
        , t.campaign_medium as campaign_medium
        , t.campaign_name as campaign_name
        , t.campaign_content as campaign_content
        , t.campaign_term as campaign_term
        , t.ip as ip
        , t.page_url as url
        , t.journey_type
        , t.journey_prop
        , t.page_path
        , coalesce(o.vendor, os.retailer) as vendor
        , o.total as order_value
        , row_number() over(partition by s.session_id order by t.timestamp) as track_sequence_number
        , row_number() over(partition by s.session_id, t.event_source order by t.timestamp) as source_sequence_number
        , first_value(t.referrer) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_referrer
        , first_value(t.campaign_source) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_source
        , first_value(t.campaign_medium) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_medium
        , first_value(t.campaign_name) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_campaign
        , first_value(t.campaign_content) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_content
        , first_value(t.campaign_term) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_term
        , first_value(t.user_agent) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as user_agent
        , first_value(o.transaction_at IGNORE NULLS) over (partition by t.looker_visitor_id order by o.order_sequence_number rows between unbounded preceding and unbounded following) as first_purchased
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${sessions.SQL_TABLE_NAME} as s
      on t.looker_visitor_id = s.looker_visitor_id
        and t.timestamp >= s.session_start_at
        and (t.timestamp < s.next_session_start_at or s.next_session_start_at is null)
      left join ${orders.SQL_TABLE_NAME} as o
      on t.looker_visitor_id = o.user_id
        and t.event_id = CONCAT(cast(o.transaction_at as string), o.user_id, '-r')
      left join javascript.outlink_sent_view as os
      on t.looker_visitor_id = os.user_id
        and t.event_id = CONCAT(cast(os.timestamp AS string), os.anonymous_id, '-t')
       ;;
  }

  dimension: event_id {
    primary_key: yes
    #     hidden: true
    sql: ${TABLE}.event_id ;;
  }

  dimension: session_id {
    sql: ${TABLE}.session_id ;;
  }

#   dimension: order_id {
#     sql: ${TABLE}.order_id ;;
#   }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: event_source {
    sql: ${TABLE}.event_source ;;
  }

  dimension_group: received {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.received ;;
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
    group_label: "Session UTM"
    sql: ${TABLE}.first_referrer ;;
  }

  dimension: first_referrer_domain {
    group_label: "Session UTM"
    sql: NET.REG_DOMAIN(${first_referrer}) ;;
  }

  dimension: first_campaign {
    group_label: "Session UTM"
    type:  string
    sql: ${TABLE}.first_campaign ;;
  }

  dimension: first_source {
    group_label: "Session UTM"
    type:  string
    sql: ${TABLE}.first_source ;;
  }

  dimension: first_medium {
    group_label: "Session UTM"
    type:  string
    sql: ${TABLE}.first_medium ;;
  }

  dimension: first_content {
    group_label: "Session UTM"
    type:  string
    sql: ${TABLE}.first_content ;;
  }

  dimension: first_term {
    group_label: "Session UTM"
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
    sql: ${TABLE}.track_sequence_number ;;
  }

  dimension: source_sequence_number {
    group_label: "Event Context"
    type: number
    sql: ${TABLE}.source_sequence_number ;;
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

  dimension: journey_type {
    type: string
    sql: ${TABLE}.journey_type  ;;
  }

  dimension: journey_prop {
    type: string
    sql: ${TABLE}.journey_prop ;;
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: unique_outlinked_user {
    group_label: "Unique Users"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "outlink_sent"
    }
  }

  measure: unique_product_viewed_user {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "Product"
    }
  }

  measure: outlinked_user_by_vendor {
    group_label: "Unique Users"
    type: count_distinct
    sql:
    CASE
      WHEN {% condition vendor_to_count %} ${vendor} {% endcondition %} AND ${event} = 'outlink_sent'
      THEN ${looker_visitor_id}
      ELSE ""
    END
  ;;
  }

  measure: ordered_user_by_vendor {
    group_label: "Unique Users"
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

  measure: unique_ordered_user {
    group_label: "Unique Users"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: event
      value: "order_completed"
    }
  }

  measure: count_events {
    type: count
    drill_fields: [user_facts.looker_visitor_id, users.name, user_agent]
  }

  measure: events_per_visitor {
    type: number
    sql: ${count_events} / ${count_visitors} ;;
    value_format_name: decimal_1
    drill_fields: [event, looker_visitor_id, users.name, count_events]
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
