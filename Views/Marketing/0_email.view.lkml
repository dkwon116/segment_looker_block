view: email_activity {
  derived_table: {
    sql_trigger_value: select count(*) from sendgrid.activity_view ;;
    sql:
      select
        s.*
        ,u.id as looker_visitor_id
      from sendgrid.activity_view s
      left join ${catch_users.SQL_TABLE_NAME} u on u.email=s.email
 ;;
  }


  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension_group: start {
    type: time
    timeframes: [time, date, hour_of_day, day_of_week_index, week, hour, month, quarter, raw]
    sql: TIMESTAMP_SECONDS(${TABLE}.timestamp) ;;
  }

#   dimension_group: date {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}.date ;;
#   }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: ip {
    type: string
    sql: ${TABLE}.ip ;;
    hidden: yes
  }

  dimension_group: loaded {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.loaded_at ;;
    hidden: yes
  }

  dimension: marketing_campaign_id {
    type: number
    sql: ${TABLE}.marketing_campaign_id ;;
  }

  dimension: marketing_campaign_name {
    type: string
    sql: ${TABLE}.marketing_campaign_name ;;
  }

  dimension: marketing_campaign_split_id {
    type: number
    sql: ${TABLE}.marketing_campaign_split_id ;;
  }

  dimension: marketing_campaign_version {
    type: string
    sql: ${TABLE}.marketing_campaign_version ;;
  }

  dimension: processed {
    type: number
    sql: ${TABLE}.processed ;;
    hidden: yes
  }

  dimension: reason {
    type: string
    sql: ${TABLE}.reason ;;
  }

  dimension_group: received {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.received_at ;;
  }

  dimension: response {
    type: string
    sql: ${TABLE}.response ;;
  }

  dimension: sg_content_type {
    type: string
    sql: ${TABLE}.sg_content_type ;;
  }

  dimension: sg_event_id {
    type: string
    sql: ${TABLE}.sg_event_id ;;
  }

  dimension: sg_message_id {
    type: string
    sql: ${TABLE}.sg_message_id ;;
    hidden: yes
  }

  dimension: sg_template_id {
    type: string
    sql: ${TABLE}.sg_template_id ;;
    hidden: yes
  }

  dimension: sg_template_name {
    type: string
    sql: ${TABLE}.sg_template_name ;;
  }

  dimension: sg_user_id {
    type: number
    sql: ${TABLE}.sg_user_id ;;
  }

  dimension: singlesend_id {
    type: string
    sql: ${TABLE}.singlesend_id ;;
    hidden: yes
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: template_id {
    type: string
    sql: ${TABLE}.template_id ;;
  }



  dimension: tls {
    type: number
    sql: ${TABLE}.tls ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
  }

  dimension: useragent {
    type: string
    sql: ${TABLE}.useragent ;;
  }

  dimension: device {
    type: string
    sql:  CASE
            WHEN ${useragent} LIKE '%iPhone%' THEN "iPhone"
            WHEN ${useragent} LIKE '%Android%' THEN "Android"
            WHEN ${useragent} LIKE '%Macintosh%' THEN "Mac"
            WHEN ${useragent} LIKE '%Windows%' THEN "Windows"
            ELSE "Other"
          END;;
  }

  dimension: is_mobile {
    type: yesno
    sql: CASE
          WHEN ${device} IN ("iPhone", "Android") THEN true
          ELSE false
        END;;
  }

  dimension_group: uuid_ts {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.uuid_ts ;;
  }

  measure: count {
    type: count
    drill_fields: [id, marketing_campaign_name, sg_template_name]
  }

  measure: unique_campaigns {
    type: count_distinct
    sql: ${marketing_campaign_id} ;;
  }

  measure: unique_delivered_campaigns {
    type: count_distinct
    sql: ${marketing_campaign_id} ;;
    filters: {
      field: event
      value: "delivered"
    }
  }

  measure: users_delivered {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "delivered"
    }
  }

  measure: users_clicked {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "click"
    }
  }

  measure: users_opened {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "open"
    }
  }

  measure: users_unsubscribed {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "unsubscribe"
    }
  }

  measure: users_bounced {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "bounce"
    }
  }

  measure: users_spamreport {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "spamreport"
    }
  }

  measure: users_dropped {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "dropped"
    }
  }

  measure: users_deferred {
    type: count_distinct
    sql: ${email} ;;
    filters: {
      field: event
      value: "deferred"
    }
  }




  measure: unique_open_users_per_delivered_users {
    type: number
    sql: ${users_opened} / nullif(${users_delivered},0) ;;
    value_format_name: percent_0
  }

  measure: unique_click_users_per_open_users {
    type: number
    sql: ${users_clicked} / nullif(${users_opened},0) ;;
    value_format_name: percent_0
  }

  measure: click_through_rate {
    type: number
    sql: ${users_clicked} / NULLIF(${users_delivered}, 0) ;;
    value_format_name: percent_1
  }
}
