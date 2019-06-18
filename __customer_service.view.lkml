view: customer_service_log {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from google_sheets.cs_history ;;
    sql: select
        cs.id as id
        ,coalesce(cs.user_id, u1.id, u2.id, u3.id) as user_id
        ,coalesce(cs.phone, u1.phone, u2.phone, u3.phone) as phone
        ,coalesce(cs.email, u1.email, u2.email, u3.email) as email
        ,CAST(CONCAT(date, " ",REPLACE(time," ",""), ":00") AS TIMESTAMP) as timestamp
        ,cs.is_biz_hour
        ,cs.is_concierge
        ,cs.order_completed
        ,cs.installment
        ,coalesce(cs.name, u1.first_name, u2.first_name, u3.first_name) as name
        ,cs.description
        ,cs.retailer
        ,cs.agent
        ,cs.brand
        ,cs.retailer_order_id
      from google_sheets.cs_history as cs
      left join mysql_smile_ventures.users as u1 ON cs.user_id = u1.id
      left join mysql_smile_ventures.users as u2 ON cs.email = u2.email
      left join mysql_smile_ventures.users as u3 ON REPLACE(cs.phone, "-", "") = REPLACE(u3.phone, "-", "")
      where cs._fivetran_deleted = false
       ;;
  }

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
  }

  dimension: agent {
    type: string
    sql: ${TABLE}.agent ;;
  }

  dimension: ars_order_id {
    type: string
    sql: ${TABLE}.ars_order_id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: installment {
    type: string
    sql: ${TABLE}.installment ;;
  }

  dimension: is_biz_hour {
    type: string
    sql: ${TABLE}.is_biz_hour ;;
  }

  dimension: is_concierge {
    type: string
    sql: ${TABLE}.is_concierge ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: order_completed {
    type: string
    sql: ${TABLE}.order_completed ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: retailer {
    type: string
    sql: ${TABLE}.retailer ;;
  }

  dimension: retailer_order_id {
    type: string
    sql: ${TABLE}.retailer_order_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
