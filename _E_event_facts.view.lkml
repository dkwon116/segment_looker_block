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
        , row_number() over(partition by s.session_id order by t.timestamp) as track_sequence_number
        , row_number() over(partition by s.session_id, t.event_source order by t.timestamp) as source_sequence_number
        , first_value(t.referrer) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_referrer
        , first_value(t.campaign_source) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_source
        , first_value(t.campaign_medium) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_medium
        , first_value(t.campaign_name) over (partition by s.session_id order by t.timestamp rows between unbounded preceding and unbounded following) as first_campaign
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

  dimension_group: received {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.received ;;
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

  measure: count_visitors {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: count_events {
    type: count
  }
}
