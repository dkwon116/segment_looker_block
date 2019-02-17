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
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${sessions.SQL_TABLE_NAME} as s
      on t.looker_visitor_id = s.looker_visitor_id
        and t.timestamp >= s.session_start_at
        and (t.timestamp < s.next_session_start_at or s.next_session_start_at is null)
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
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
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
}
