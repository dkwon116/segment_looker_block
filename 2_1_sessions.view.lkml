# - explore: sessions_pg_trk
view: sessions {
  derived_table: {
#     list sessions by user
    sql_trigger_value: select count(*) from ${mapped_events.SQL_TABLE_NAME} ;;
    sql:
      select
        s.*
        ,if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)) as last_utm
        ,split(if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)),',')[safe_offset(0)] as last_source
        ,split(if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)),',')[safe_offset(1)] as last_medium
        ,split(if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)),',')[safe_offset(2)] as last_campaign
        ,split(if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)),',')[safe_offset(3)] as last_content
        ,split(if(s.first_utm is not null,s.first_utm,if(timestamp_diff(s.session_start_at,last_value(if(s.first_utm is null,null,s.session_start_at) ignore nulls) over (w),hour)<=72,last_value(s.first_utm ignore nulls) over (w),null)),',')[safe_offset(4)] as last_term
      from(
        select
          concat(cast(row_number() over(w) AS string),' - ',looker_visitor_id) as session_id
          ,looker_visitor_id
          ,timestamp as session_start_at
          ,row_number() over(w) as session_sequence_number
          ,lead(timestamp) over(w) as next_session_start_at
          ,user_agent as user_agent

          ,referrer as first_referrer
          ,campaign_source as first_source
          ,campaign_medium as first_medium
          ,campaign_name as first_campaign
          ,campaign_content as first_content
          ,campaign_term as first_term
          ,if(campaign_source is null and campaign_medium is null and campaign_name is null and campaign_content is null and campaign_term is null
            ,null
            ,concat(ifnull(campaign_source,''),',',ifnull(campaign_medium,''),',',ifnull(campaign_name,''),',',ifnull(campaign_content,''),',',ifnull(campaign_term,'')))
            as first_utm

        from ${mapped_events.SQL_TABLE_NAME}
        where (idle_time_minutes > 30 or idle_time_minutes is null)
        window w as (partition by looker_visitor_id order by timestamp)
      )s
      window w as (partition by s.looker_visitor_id order by s.session_start_at)

 ;;
  }

  dimension: session_id {
    hidden: yes
    sql: ${TABLE}.session_id ;;
    primary_key: yes
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension_group: start {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.session_start_at ;;
  }

  dimension: session_sequence_number {
    type: number
    sql: ${TABLE}.session_sequence_number ;;
  }

  dimension: next_session_start_at {
    sql: ${TABLE}.next_session_start_at ;;
  }

  dimension_group: today {
    type: time
    hidden: yes
    timeframes: [day_of_week_index, hour_of_day]
    sql: CURRENT_TIMESTAMP() ;;
  }

  dimension: is_same_day_of_week_as_today {
    type: yesno
    sql: ${today_day_of_week_index} = ${start_day_of_week_index} ;;
    group_label: "Date Comp"
  }

  dimension: is_up_to_same_hour_of_day {
    type: yesno
    sql: ${today_hour_of_day} >= ${start_hour_of_day};;
    group_label: "Date Comp"
  }

  dimension: is_last_24hours {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, hour) < 24  ;;
    group_label: "Date Comp"
  }

  dimension: is_last_7days {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${start_raw}, day) < 7  ;;
    group_label: "Date Comp"
  }

  dimension: is_first_session {
    group_label: "Session Flags"
    type: string
    sql: CASE WHEN ${session_sequence_number} = 1 THEN 'First Session'
           ELSE 'Repeat Session'
      END
       ;;
  }


  dimension: first_referrer {
    sql: ${TABLE}.first_referrer ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: first_referrer_domain {
    sql: NET.REG_DOMAIN(${first_referrer}) ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: first_referral_name {
    sql: split(${first_referrer_domain}, ".")[OFFSET(0)]  ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: first_utm {
    type:  string
    sql: ${TABLE}.first_utm ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: first_campaign {
    type:  string
    sql: ${TABLE}.first_campaign ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: first_source {
    type:  string
    sql: ${TABLE}.first_source ;;
    drill_fields: [first_campaign, first_medium]
    group_label: "Attribution"
    hidden: yes
  }

  dimension: first_medium {
    type:  string
    sql: ${TABLE}.first_medium ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: first_content {
    type:  string
    sql: ${TABLE}.first_content ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: first_term {
    type:  string
    sql: ${TABLE}.first_term ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_referrer {
    sql: ${TABLE}.last_referrer ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: last_referrer_domain {
    sql: NET.REG_DOMAIN(${last_referrer}) ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: last_referral_name {
    sql: split(${last_referrer_domain}, ".")[OFFSET(0)]  ;;
    group_label: "Attribution"
    type: string
    hidden: yes
  }

  dimension: last_utm {
    type:  string
    sql: ${TABLE}.last_utm ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_source {
    type:  string
    sql: ${TABLE}.last_source ;;
    drill_fields: [first_campaign, first_medium]
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_medium {
    type:  string
    sql: ${TABLE}.last_medium ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_campaign {
    type:  string
    sql: ${TABLE}.last_campaign ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_content {
    type:  string
    sql: ${TABLE}.last_content ;;
    group_label: "Attribution"
    hidden: yes
  }

  dimension: last_term {
    type:  string
    sql: ${TABLE}.last_term ;;
    group_label: "Attribution"
    hidden: yes
  }










  measure: count {
    type: count
    drill_fields: [session_detail*]
    group_label: "Session Facts"
    group_item_label: "Number of Sessions"
  }

  measure: unique_session_count {
    type: count_distinct
    sql: ${session_id} ;;
    group_label: "Session Facts"
    group_item_label: "Number of Unique Sessions"
  }

  measure: first_count {
    type: count
    drill_fields: [session_detail*]
    group_label: "Session Facts"
    group_item_label: "Number of First Sessions"

    filters: {
      field: is_first_session
      value: "First Session"
    }
  }

  measure: repeat_count {
    type: count
    drill_fields: [session_detail*]
    group_label: "Session Facts"
    group_item_label: "Number of Repeat Sessions"

    filters: {
      field: is_first_session
      value: "Repeat Session"
    }
  }

  measure: unique_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    drill_fields: [user_detail*]
    label: "Number of Unique Visitors"
  }


  measure: unique_first_session_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id} ;;

    filters: {
      field: is_first_session
      value: "First Session"
    }
    label: "Number of Unique First Session Visitors"
  }

  measure: unique_repeat_session_visitor_count {
    type: count_distinct
    sql: ${looker_visitor_id};;

    filters: {
      field: is_first_session
      value: "Repeat Session"
    }
    label: "Number of Unique Repeat Session Visitors"
  }

  measure: sessions_per_unique_visitor {
    type: number
    value_format_name: decimal_2
    sql: ${count} / nullif(${unique_visitor_count}, 0) ;;
  }

  measure: unique_repeat_session_visitors_per_unique_visitor {
    type: number
    sql: ${unique_repeat_session_visitor_count} / ${unique_visitor_count} ;;
    value_format_name: percent_0
  }

  measure: repeat_session_per_session {
    type: number
    value_format_name: percent_0
    sql: ${repeat_count} / ${count} ;;
    group_label: "Session Facts"
  }

  measure: percent_of_total_count {
    type: percent_of_total
    sql: ${count} ;;
  }

  set: session_detail {
    fields: [session_facts.campaign_details*]
  }

  set: user_detail {
    fields: [start_date, users.name, looker_visitor_id, user_facts.first_visited_date, user_facts.first_source]
  }
}
