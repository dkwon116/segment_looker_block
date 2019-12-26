view: email_campaigns {
  derived_table: {
    sql_trigger_value: select count(*) from ${email_activity.SQL_TABLE_NAME} ;;
    sql:

    CREATE TEMP FUNCTION decodeurl(a STRING)
    RETURNS STRING
    LANGUAGE js AS "return decodeURIComponent(a)";

      select
        distinct
        e.marketing_campaign_id
        ,e.marketing_campaign_name
        ,t.delivered_at
        ,concat(first_value(e.source) over (w),',',first_value(e.medium) over (w),',',first_value(e.campaign) over (w),',',first_value(e.content) over (w),',',first_value(e.term) over (w)) as utm
        ,first_value(e.source) over (w) as source
        ,first_value(e.medium) over (w) as medium
        ,first_value(e.campaign) over (w) as campaign
        ,first_value(e.content) over (w) as content
        ,first_value(e.term) over (w) as term
      from(
        select
          e.marketing_campaign_id
          ,e.marketing_campaign_name
          ,split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)] as source
          ,split(split(e.url,'utm_medium=')[safe_offset(1)],'&')[safe_offset(0)] as medium
          ,split(split(e.url,'utm_campaign=')[safe_offset(1)],'&')[safe_offset(0)] as campaign
          ,split(split(e.url,'utm_content=')[safe_offset(1)],'&')[safe_offset(0)] as content
          ,decodeurl(split(split(e.url,'utm_term=')[safe_offset(1)],'&')[safe_offset(0)]) as term
          ,count(1) as click_cnt
        from ${email_activity.SQL_TABLE_NAME} e
        where e.event='click'
        and e.marketing_campaign_id is not null
        and split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)]='sendgrid'
        and split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)] is not null
        and split(split(e.url,'utm_medium=')[safe_offset(1)],'&')[safe_offset(0)] is not null
        and split(split(e.url,'utm_campaign=')[safe_offset(1)],'&')[safe_offset(0)] is not null
        and split(split(e.url,'utm_content=')[safe_offset(1)],'&')[safe_offset(0)] is not null
        and split(split(e.url,'utm_term=')[safe_offset(1)],'&')[safe_offset(0)] is not null
        group by 1,2,3,4,5,6,7
      ) e
      left join(
        select
          e.marketing_campaign_id
          ,TIMESTAMP_SECONDS(min(e.timestamp)) as delivered_at
        from ${email_activity.SQL_TABLE_NAME} e
        where e.event='delivered'
        and e.marketing_campaign_id is not null
        group by 1
      ) t on t.marketing_campaign_id=e.marketing_campaign_id
      window w as (partition by e.marketing_campaign_id order by e.click_cnt desc rows between unbounded preceding and unbounded following)
 ;;
  }

  dimension: marketing_campaign_id {
    type:  string
    sql: ${TABLE}.marketing_campaign_id ;;
    hidden: yes
  }
  dimension: marketing_campaign_name {
    type:  string
    sql: ${TABLE}.marketing_campaign_name ;;
    hidden: yes
  }
  dimension_group: delivered_at {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.delivered_at ;;
  }
  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
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
  dimension: term {
    type:  string
    sql: ${TABLE}.term ;;
    group_label: "UTM"
  }


 }
