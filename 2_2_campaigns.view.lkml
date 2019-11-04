view: campaigns {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        c.*
        ,coalesce(email.marketing_campaign_id) as marketing_campaign_id
        ,coalesce(email.marketing_campaign_name) as marketing_campaign_name
      from(
        select
          upper(s.first_utm) as utm
          ,upper(s.first_source) as source
          ,upper(s.first_medium) as medium
          ,upper(s.first_campaign) as campaign
          ,upper(s.first_content) as content
          ,upper(s.first_term) as term
          ,timestamp(safe_cast(concat('20',substr(s.first_term,1,2),'-',substr(s.first_term,3,2),'-',substr(s.first_term,5,2),' 00:00:00') as datetime)) as start_timestamp
          ,timestamp_add(timestamp(safe_cast(concat('20',substr(s.first_term,1,2),'-',substr(s.first_term,3,2),'-',substr(s.first_term,5,2),' 00:00:00') as datetime)), interval 168 hour) as end_timestamp
          ,min(s.session_start_at) as first_session_timestamp
        from ${sessions.SQL_TABLE_NAME} s
        where s.first_utm is not null
        group by 1,2,3,4,5,6,7,8
      ) c
      left join ${email_campaigns.SQL_TABLE_NAME} email on upper(email.utm)=upper(c.utm)
 ;;
  }

  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
    primary_key: yes
    group_label: "UTM"
  }
  dimension: source {
    type:  string
    sql: ${TABLE}.source ;;
    group_label: "UTM"
  }
  dimension: medium {
    type:  string
    sql: ${TABLE}.medium ;;
    group_label: "UTM"
  }
  dimension: campaign {
    type:  string
    sql: ${TABLE}.campaign ;;
    group_label: "UTM"
  }
  dimension: content {
    type:  string
    sql: ${TABLE}.content ;;
    group_label: "UTM"
  }
  dimension: term {
    type:  string
    sql: ${TABLE}.term ;;
    group_label: "UTM"
  }
  dimension: marketing_campaign_id {
    type:  string
    sql: ${TABLE}.marketing_campaign_id ;;
  }
  dimension: marketing_campaign_name {
    type:  string
    sql: ${TABLE}.marketing_campaign_name ;;
  }
  dimension_group: start {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.start_timestamp ;;
  }

  dimension_group: first_timestamp {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.first_timestamp ;;
  }

}
