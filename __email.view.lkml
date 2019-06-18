view: email_activity {
  sql_table_name: sendgrid.activity_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: reason {
    type: string
    sql: ${TABLE}.reason ;;
  }

  dimension: response {
    type: string
    sql: ${TABLE}.response ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: timestamp {
    type: time
    sql: TIMESTAMP(DATETIME(TIMESTAMP_SECONDS(${TABLE}.timestamp))) ;;
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
  }

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
  }

  dimension: url_offset_index {
    type: number
    sql: ${TABLE}.url_offset_index ;;
  }

  dimension: url_offset_type {
    type: string
    sql: ${TABLE}.url_offset_type ;;
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
    hidden: yes
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

  dimension: useragent {
    type: string
    sql: ${TABLE}.useragent ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: tls {
    type: number
    sql: ${TABLE}.tls ;;
    hidden: yes
  }

  dimension: sg_event_id {
    type: string
    sql: ${TABLE}.sg_event_id ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: smtp_id {
    type: string
    sql: ${TABLE}.smtp_id ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [id, sg_template_name]
  }
}
