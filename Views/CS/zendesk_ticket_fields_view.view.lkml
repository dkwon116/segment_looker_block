view: zendesk_ticket_fields_view {
  sql_table_name: zendesk.ticket_fields_view ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active ;;
  }

  dimension: collapsed_for_agents {
    type: yesno
    sql: ${TABLE}.collapsed_for_agents ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: editable_in_portal {
    type: yesno
    sql: ${TABLE}.editable_in_portal ;;
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
  }

  dimension: position {
    type: number
    sql: ${TABLE}.position ;;
  }

  dimension: raw_description {
    type: string
    sql: ${TABLE}.raw_description ;;
  }

  dimension: raw_title {
    type: string
    sql: ${TABLE}.raw_title ;;
  }

  dimension: raw_title_in_portal {
    type: string
    sql: ${TABLE}.raw_title_in_portal ;;
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

  dimension: regexp_for_validation {
    type: string
    sql: ${TABLE}.regexp_for_validation ;;
  }

  dimension: removable {
    type: yesno
    sql: ${TABLE}.removable ;;
  }

  dimension: required {
    type: yesno
    sql: ${TABLE}.required ;;
  }

  dimension: required_in_portal {
    type: yesno
    sql: ${TABLE}.required_in_portal ;;
  }

  dimension: slug {
    type: string
    sql: ${TABLE}.slug ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: title_in_portal {
    type: string
    sql: ${TABLE}.title_in_portal ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension_group: updated {
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
    sql: ${TABLE}.updated_at ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
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

  dimension: visible_in_portal {
    type: yesno
    sql: ${TABLE}.visible_in_portal ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
