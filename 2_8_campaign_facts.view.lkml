view: campaign_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        c.utm
        ,coalesce(email.delivered_users) as delivered_users
        ,coalesce(email.open_users) as open_users
        ,coalesce(email.click_users) as click_users
      from ${campaigns.SQL_TABLE_NAME} c
      left join ${email_campaign_facts.SQL_TABLE_NAME} AS email on upper(email.utm)=upper(c.utm)
 ;;
  }

  dimension: utm {
    type:  string
    sql: ${TABLE}.utm ;;
    hidden: yes
  }
  measure: delivered_users {
    type:  sum
    sql: ${TABLE}.delivered_users ;;
    group_label: "Campaign Facts"
  }
  measure: open_users {
    type:  sum
    sql: ${TABLE}.open_users ;;
    group_label: "Campaign Facts"
  }
  measure: open_conversion {
    type:  number
    sql: ${open_users}/nullif(${delivered_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: click_users {
    type:  sum
    sql: ${TABLE}.click_users ;;
    group_label: "Campaign Facts"
  }
  measure: click_conversion {
    type:  number
    sql: ${click_users}/nullif(${open_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }
  measure: ctr {
    type:  number
    sql: ${click_users}/nullif(${delivered_users},0) ;;
    value_format_name: percent_2
    group_label: "Campaign Facts"
  }


}
