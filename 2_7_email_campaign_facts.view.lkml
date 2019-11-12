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
        ,s.pre_purchase_visitors
        ,s.first_order_completed_users
        ,s.post_purchase_visitors
        ,s.repeat_order_completed_users
        ,s.order_value
        ,e.bounce_users
        ,e.dropped_users
        ,e.unsubscribe_users
        ,e.spamreport_users
      from(
        select
          email_campaigns.utm  as utm
          ,email_activity.marketing_campaign_id
          ,count(distinct case when (email_activity.event = 'delivered') then email_activity.email else null end) as delivered_users
          ,count(distinct case when (email_activity.event = 'open') then email_activity.email else null end) as open_users
          ,count(distinct case when (email_activity.event = 'click') then email_activity.email else null end) as click_users

          ,count(distinct case when (email_activity.event = 'bounce') then email_activity.email else null end) as bounce_users
          ,count(distinct case when (email_activity.event = 'dropped') then email_activity.email else null end) as dropped_users
          ,count(distinct case when (email_activity.event = 'unsubscribe') then email_activity.email else null end) as unsubscribe_users
          ,count(distinct case when (email_activity.event = 'spamreport') then email_activity.email else null end) as spamreport_users

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
          ,COUNT(DISTINCT CASE WHEN sf.is_pre_purchase_at_session  THEN s.looker_visitor_id  ELSE NULL END) AS pre_purchase_visitors
          ,COUNT(DISTINCT CASE WHEN (sf.count_order_completed  > 0) AND sf.is_pre_purchase_at_session THEN s.looker_visitor_id  ELSE NULL END) AS first_order_completed_users
          ,COUNT(DISTINCT CASE WHEN NOT COALESCE(sf.is_pre_purchase_at_session , FALSE) THEN s.looker_visitor_id  ELSE NULL END) AS post_purchase_visitors
          ,COUNT(DISTINCT CASE WHEN (sf.count_order_completed  > 0) AND (NOT COALESCE(sf.is_pre_purchase_at_session , FALSE)) THEN s.looker_visitor_id  ELSE NULL END) AS repeat_order_completed_users
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
  dimension: marketing_campaign_id {
    type:  string
    sql: ${TABLE}.marketing_campaign_id ;;
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
  dimension: pre_purchase_visitors {
    type:  number
    sql: ${TABLE}.pre_purchase_visitors ;;
  }
  dimension: first_order_completed_users {
    type:  number
    sql: ${TABLE}.first_order_completed_users ;;
  }
  dimension: post_purchase_visitors {
    type:  number
    sql: ${TABLE}.post_purchase_visitors ;;
  }
  dimension: repeat_order_completed_users {
    type:  number
    sql: ${TABLE}.repeat_order_completed_users ;;
  }


  dimension: bounce_users {
    type:  number
    sql: ${TABLE}.bounce_users ;;
  }
  dimension: dropped_users {
    type:  number
    sql: ${TABLE}.dropped_users ;;
  }
  dimension: unsubscribe_users {
    type:  number
    sql: ${TABLE}.unsubscribe_users ;;
  }
  dimension: spamreport_users {
    type:  number
    sql: ${TABLE}.spamreport_users ;;
  }






  measure: unique_delivered_campaigns {
    type: count_distinct
    sql: ${marketing_campaign_id} ;;
    filters: {
      field: delivered_users
      value: "NOT NULL"
    }
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
  measure: outlink_conversion {
    type:  number
    sql:  ${total_outlinked_users}/nullif(${total_visitors},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: total_order_completed_users {
    type:  sum
    sql:  ${order_completed_users};;
    group_label: "Campaign Facts"
  }
  measure: order_completed_conversion {
    type:  number
    sql:  ${total_order_completed_users}/nullif(${total_outlinked_users},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: total_order_value {
    type:  sum
    sql:  ${order_value} ;;
    value_format_name: decimal_0
    group_label: "Campaign Facts"
  }
  measure: sales_per_email {
    type:  number
    sql: ${total_order_value}/nullif(${total_delivered_users},0) ;;
    value_format_name: decimal_3
    group_label: "Campaign Facts"
  }

  measure: total_pre_purchase_visitors {
    type:  sum
    sql:  ${pre_purchase_visitors};;
    group_label: "Campaign Facts"
  }
  measure: total_first_order_completed_users {
    type:  sum
    sql:  ${first_order_completed_users};;
    group_label: "Campaign Facts"
  }
  measure: first_order_completed_conversion {
    type:  number
    sql:  ${total_first_order_completed_users}/nullif(${total_pre_purchase_visitors},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: total_post_purchase_visitors {
    type:  sum
    sql:  ${post_purchase_visitors};;
    group_label: "Campaign Facts"
  }
  measure: total_repeat_order_completed_users {
    type:  sum
    sql:  ${repeat_order_completed_users};;
    group_label: "Campaign Facts"
  }
  measure: repeat_order_completed_conversion {
    type:  number
    sql:  ${total_repeat_order_completed_users}/nullif(${total_post_purchase_visitors},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: first_order_user_ratio {
    type:  number
    sql:  ${total_first_order_completed_users}/nullif(${total_order_completed_users},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: repeat_order_user_ratio {
    type:  number
    sql:  ${total_repeat_order_completed_users}/nullif(${total_order_completed_users},0);;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }



  measure: total_bounce_users {
    type:  sum
    sql:  ${bounce_users};;
    group_label: "Campaign Facts"
  }
  measure: total_dropped_users {
    type:  sum
    sql:  ${dropped_users};;
    group_label: "Campaign Facts"
  }
  measure: total_unsubscribe_users {
    type:  sum
    sql:  ${unsubscribe_users};;
    group_label: "Campaign Facts"
  }
  measure: total_spamreport_users {
    type:  sum
    sql:  ${spamreport_users};;
    group_label: "Campaign Facts"
  }

}
