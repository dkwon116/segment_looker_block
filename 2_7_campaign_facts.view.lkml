view: campaign_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        c.utm
        ,coalesce(email.delievered_users) as delievered_users
        ,coalesce(email.open_users) as open_users
        ,coalesce(email.open_conversion) as open_conversion
        ,coalesce(email.click_users) as click_users
        ,coalesce(email.click_conversion) as click_conversion
        ,coalesce(email.ctr) as ctr
      from ${campaigns.SQL_TABLE_NAME} c
      left join(
        SELECT
          email_campaigns.utm  AS utm,
          COUNT(DISTINCT CASE WHEN (email_activity.event = 'delivered') THEN email_activity.email  ELSE NULL END) AS delievered_users,
          COUNT(DISTINCT CASE WHEN (email_activity.event = 'open') THEN email_activity.email  ELSE NULL END) AS open_users,
          (COUNT(DISTINCT CASE WHEN (email_activity.event = 'open') THEN email_activity.email  ELSE NULL END)) / nullif((COUNT(DISTINCT CASE WHEN (email_activity.event = 'delivered') THEN email_activity.email  ELSE NULL END)),0)  AS open_conversion,
          COUNT(DISTINCT CASE WHEN (email_activity.event = 'click') THEN email_activity.email  ELSE NULL END) AS click_users,
          (COUNT(DISTINCT CASE WHEN (email_activity.event = 'click') THEN email_activity.email  ELSE NULL END)) / nullif((COUNT(DISTINCT CASE WHEN (email_activity.event = 'open') THEN email_activity.email  ELSE NULL END)),0)  AS click_conversion,
          (COUNT(DISTINCT CASE WHEN (email_activity.event = 'click') THEN email_activity.email  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN (email_activity.event = 'delivered') THEN email_activity.email  ELSE NULL END)), 0)  AS ctr
        FROM ${email_activity.SQL_TABLE_NAME} as email_activity
        LEFT JOIN ${email_campaigns.SQL_TABLE_NAME} AS email_campaigns ON email_activity.marketing_campaign_id=email_campaigns.marketing_campaign_id
        WHERE email_campaigns.utm IS NOT NULL
        GROUP BY 1
      ) email on upper(email.utm)=upper(c.utm)

 ;;
  }

  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
    hidden: yes
  }
  measure: delievered_users {
    type:  average
    sql: ${TABLE}.delievered_users ;;
    group_label: "Campaign Facts"
  }
  measure: open_users {
    type:  average
    sql: ${TABLE}.open_users ;;
    group_label: "Campaign Facts"
  }
  measure: open_conversion {
    type:  average
    sql: ${TABLE}.open_conversion ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: click_users {
    type:  average
    sql: ${TABLE}.click_users ;;
    group_label: "Campaign Facts"
  }
  measure: click_conversion {
    type:  average
    sql: ${TABLE}.click_conversion ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: ctr {
    type:  average
    sql: ${TABLE}.ctr ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }


}
