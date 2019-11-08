view: email_campaign_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        e.utm
        ,e.marketing_campaign_id
        ,e.delivered_users
        ,e.open_users
        ,e.click_users
        ,s.visitors
        ,s.outlinked_users
        ,s.order_completed_users
        ,s.order_value
      from(
        select
          email_campaigns.utm  as utm
          ,email_activity.marketing_campaign_id
          ,count(distinct case when (email_activity.event = 'delivered') then email_activity.email  else null end) as delivered_users
          ,count(distinct case when (email_activity.event = 'open') then email_activity.email  else null end) as open_users
          ,count(distinct case when (email_activity.event = 'click') then email_activity.email  else null end) as click_users
        from ${email_activity.SQL_TABLE_NAME} as email_activity
        join ${email_campaigns.SQL_TABLE_NAME} as email_campaigns on email_activity.marketing_campaign_id=email_campaigns.marketing_campaign_id
        group by 1,2
      ) e
      join(
        select
          s.last_utm
          ,count(distinct s.looker_visitor_id ) as visitors
          ,count(distinct case when (sf.count_outlinked  > 0) then s.looker_visitor_id  else null end) as outlinked_users
          ,count(distinct case when (sf.count_order_completed  > 0) then s.looker_visitor_id  else null end) as order_completed_users
          ,coalesce(round(coalesce(cast( ( sum(distinct (cast(round(coalesce(sf.order_value ,0)*(1/1000*1.0), 9) as numeric) + (cast(cast(concat('0x', substr(to_hex(md5(cast(sf.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(sf.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - sum(distinct (cast(cast(concat('0x', substr(to_hex(md5(cast(sf.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(sf.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) as float64), 0), 6), 0) as order_value
        from ${sessions.SQL_TABLE_NAME} s
        join ${session_facts.SQL_TABLE_NAME} sf on sf.session_id=s.session_id
        where s.last_source='sendgrid'
        group by 1
      ) s on s.last_utm=e.utm
 ;;
  }

  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
    hidden: yes
  }
  dimension: delivered_users {
    type:  number
    sql: ${TABLE}.delivered_users ;;
  }
  dimension: open_users {
    type:  number
    sql: ${TABLE}.open_users ;;
  }
  dimension: click_users {
    type:  number
    sql: ${TABLE}.click_users ;;
  }
  dimension: visitors {
    type:  number
    sql: ${TABLE}.visitors ;;
  }
  dimension: outlinked_users {
    type:  number
    sql: ${TABLE}.outlinked_users ;;
  }
  dimension: order_completed_users {
    type:  number
    sql: ${TABLE}.order_completed_users ;;
  }
  dimension: order_value {
    type:  number
    sql: ${TABLE}.order_value ;;
  }


  measure: total_delivered_users {
    type:  sum
    sql: ${delivered_users} ;;
    group_label: "Campaign Facts"
  }
  measure: total_open_users {
    type:  sum
    sql: ${open_users} ;;
    group_label: "Campaign Facts"
  }
  measure: open_rate {
    type:  number
    sql: ${total_open_users}/nullif(${total_delivered_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: total_click_users {
    type:  sum
    sql: ${click_users} ;;
    group_label: "Campaign Facts"
  }
  measure: click_rate {
    type:  number
    sql: ${total_click_users}/nullif(${total_open_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: ctr {
    type:  number
    sql: ${click_users}/nullif(${total_delivered_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: total_visitors {
    type:  sum
    sql: ${visitors} ;;
    group_label: "Campaign Facts"
  }
  measure: total_outlinked_users {
    type:  sum
    sql:  ${outlinked_users};;
    group_label: "Campaign Facts"
  }
  measure: total_order_completed_users {
    type:  sum
    sql:  ${order_completed_users};;
    group_label: "Campaign Facts"
  }
  measure: total_order_value {
    type:  sum
    sql:  ${order_value} ;;
    value_format_name: decimal_3
    group_label: "Campaign Facts"
  }
  measure: sales_per_email {
    type:  number
    sql: ${total_order_value}/nullif(${total_delivered_users},0) ;;
    value_format_name: decimal_3
    group_label: "Campaign Facts"
  }
}