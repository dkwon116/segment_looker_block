view: email_activity {
  sql_table_name: sendgrid.activity_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension_group: date {
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
    sql: ${TABLE}.date ;;
  }

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
    hidden: yes
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

  dimension: timestamp {
    type: number
    sql: ${TABLE}.timestamp ;;
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

  measure: users_delievered {
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

  measure: click_through_rate {
    type: number
    sql: ${users_clicked} / NULLIF(${users_delievered}, 0) ;;
    value_format_name: percent_1
  }
}
