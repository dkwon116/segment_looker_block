view: ticket_events_view {
  sql_table_name: zendesk.ticket_events_view ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: _x {
    type: string
    sql: ${TABLE}._x ;;
  }

  dimension: added_tags {
    type: string
    sql: ${TABLE}.added_tags ;;
  }

  dimension: assignee_id {
    type: number
    sql: ${TABLE}.assignee_id ;;
  }

  dimension: brand_id {
    type: string
    sql: ${TABLE}.brand_id ;;
  }

  dimension: comment_present {
    type: yesno
    sql: ${TABLE}.comment_present ;;
  }

  dimension: comment_public {
    type: yesno
    sql: ${TABLE}.comment_public ;;
  }

  dimension: context_client {
    type: string
    sql: ${TABLE}.context_client ;;
  }

  dimension: context_latitude {
    type: number
    sql: ${TABLE}.context_latitude ;;
  }

  dimension: context_location {
    type: string
    sql: ${TABLE}.context_location ;;
  }

  dimension: context_longitude {
    type: number
    sql: ${TABLE}.context_longitude ;;
  }

  dimension: custom_ticket_field_id {
    type: string
    sql: ${TABLE}.custom_ticket_field_id ;;
  }

  dimension: custom_ticket_field_new_value {
    type: string
    sql: ${TABLE}.custom_ticket_field_new_value ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: group_id {
    type: number
    sql: ${TABLE}.group_id ;;
  }

  dimension: is_public {
    type: string
    sql: ${TABLE}.is_public ;;
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

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: previous_value {
    type: string
    sql: ${TABLE}.previous_value ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.priority ;;
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

  dimension: rel {
    type: string
    sql: ${TABLE}.rel ;;
  }

  dimension: removed_tags {
    type: string
    sql: ${TABLE}.removed_tags ;;
  }

  dimension: requester_id {
    type: number
    sql: ${TABLE}.requester_id ;;
  }

  dimension: revision_id {
    type: number
    sql: ${TABLE}.revision_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: subject {
    type: string
    sql: ${TABLE}.subject ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }

  dimension: ticket_event_id {
    type: number
    sql: ${TABLE}.ticket_event_id ;;
  }

  dimension: ticket_event_via {
    type: string
    sql: ${TABLE}.ticket_event_via ;;
  }

  dimension: ticket_form_id {
    type: string
    sql: ${TABLE}.ticket_form_id ;;
  }

  dimension: ticket_id {
    type: string
    sql: ${TABLE}.ticket_id ;;
  }

  dimension_group: timestamp {
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
    sql: ${TABLE}.timestamp ;;
  }

  dimension: updater_id {
    type: string
    sql: ${TABLE}.updater_id ;;
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

  dimension: via {
    type: string
    sql: ${TABLE}.via ;;
  }

  dimension: via_reference_id {
    type: number
    sql: ${TABLE}.via_reference_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
