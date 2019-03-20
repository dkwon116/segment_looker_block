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
        , t.ip as ip
        , t.page_url as url
        , row_number() over(partition by s.session_id order by t.timestamp) as track_sequence_number
        , row_number() over(partition by s.session_id, t.event_source order by t.timestamp) as source_sequence_number
        , first_value(t.referrer) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_referrer
        , first_value(t.campaign_source) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_source
        , first_value(t.campaign_medium) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_medium
        , first_value(t.campaign_name) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_campaign
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

  dimension: order_id {
    sql: ${TABLE}.order_id ;;
  }

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
    timeframes: [time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension_group: first_purchased {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.first_purchased ;;
  }

  dimension: first_referrer {
    sql: ${TABLE}.first_referrer ;;
  }

  dimension: first_referrer_domain {
    sql: NTH_VALUE(split(${first_referrer},'/'),3) ;;
  }

  dimension: first_referrer_domain_mapped {
    sql: CASE
    WHEN ${first_referrer} like '%facebook%' THEN 'Facebook'
    WHEN ${first_referrer} like '%google%' THEN 'Google'
    WHEN ${first_referrer} like '%naver%' THEN 'Naver'
    WHEN ${first_referrer} like '%instagram%' THEN 'Instagram'
    WHEN ${first_referrer} like '%catchfashion%' THEN 'Catch'
    ELSE ${first_referrer} END ;;
  }

  dimension: ip {
    sql: ${TABLE}.ip ;;
  }

  dimension: url {
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
    type: yesno
    sql: IF(${anonymous_id}=${looker_visitor_id}, false, true)  ;;
  }

  dimension: is_pre_purchase {
    type: yesno
    sql: IF(${first_purchased_time} IS NULL, true,
    IF(${timestamp_time} <= ${first_purchased_time}, true, false))  ;;
  }

  dimension: sequence_number {
    type: number
    sql: ${TABLE}.track_sequence_number ;;
  }

  dimension: source_sequence_number {
    type: number
    sql: ${TABLE}.source_sequence_number ;;
  }

  dimension: first_campaign {
    type:  string
    sql: ${TABLE}.first_campaign ;;
  }

  dimension: first_source {
    type:  string
    sql: ${TABLE}.first_source ;;
  }

  dimension: first_medium {
    type:  string
    sql: ${TABLE}.first_medium ;;
  }

  dimension: user_agent {
    type: string
    sql: ${TABLE}.user_agent ;;
  }

  dimension: device {
    type: string
    sql:  CASE
            WHEN ${user_agent} LIKE '%iPhone%' THEN "iPhone"
            WHEN ${user_agent} LIKE '%Android%' THEN "Android"
            ELSE "Other"
          END;;
  }

  dimension: is_mobile {
    type: yesno
    sql: CASE
          WHEN ${device} IN ("iPhone", "Android") THEN true
          ELSE false
        END;;
  }

  dimension: in_app {
    type: string
    sql:  CASE
            WHEN ${user_agent} LIKE '%KAKAO%' THEN "Kakao"
            WHEN ${user_agent} LIKE '%Instagram%' THEN "Insta"
            WHEN ${user_agent} LIKE '%NAVER%' THEN "Naver"
            ELSE "Other"
          END;;
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
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
