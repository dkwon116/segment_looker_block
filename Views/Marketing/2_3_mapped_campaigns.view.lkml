view: mapped_campaigns {

  derived_table: {
#     list sessions by user
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:

select
  t.mapped_utm
  ,t.mapped_source
  ,t.mapped_medium
  ,t.mapped_campaign
  ,t.mapped_content
  ,t.mapped_term
  ,t.mapped_first_session_timestamp
  ,s.mapped_spend/1000 as mapped_spend
from(
  select
    coalesce(m.mapped_utm,c.utm) as mapped_utm
    ,coalesce(m.mapped_source,c.source) as mapped_source
    ,coalesce(m.mapped_medium,c.medium) as mapped_medium
    ,coalesce(m.mapped_campaign,c.utm) as mapped_campaign
    ,coalesce(m.mapped_content,c.utm) as mapped_content
    ,coalesce(m.mapped_term,c.utm) as mapped_term
    ,min(c.first_session_timestamp) as mapped_first_session_timestamp
  from ${campaigns.SQL_TABLE_NAME} c
  left join ${general_utm_list_mapped_utm.SQL_TABLE_NAME} m on m.utm=c.utm
  group by 1,2,3,4,5,6
) t
left join ${general_utm_list_mapped_spend.SQL_TABLE_NAME} s on s.mapped_utm=t.mapped_utm

 ;;
  }

  dimension: mapped_utm {
    type: string
    sql: ${TABLE}.mapped_utm;;
  }

  dimension: mapped_source {
    type: string
    sql: ${TABLE}.mapped_source ;;
  }

  dimension: mapped_medium {
    type: string
    sql: ${TABLE}.mapped_medium ;;
  }

  dimension: mapped_campaign {
    type: string
    sql: ${TABLE}.mapped_campaign ;;
  }

  dimension: mapped_content {
    type: string
    sql: ${TABLE}.mapped_content ;;
  }

  dimension: mapped_term {
    type: string
    sql: ${TABLE}.mapped_term ;;
  }

  dimension: mapped_spend {
    type:  number
    sql: ${TABLE}.mapped_spend ;;
  }

  dimension_group: mapped_first_session_timestamp {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: ${TABLE}.mapped_first_session_timestamp ;;
  }



}
