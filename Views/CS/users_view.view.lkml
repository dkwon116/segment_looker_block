view: users_view {
  sql_table_name: zendesk.users_view ;;
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

  dimension: chat_only {
    type: yesno
    sql: ${TABLE}.chat_only ;;
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

  dimension: custom_role_id {
    type: number
    sql: ${TABLE}.custom_role_id ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}.external_id ;;
  }

  dimension_group: last_login {
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
    sql: ${TABLE}.last_login_at ;;
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

  dimension: locale {
    type: string
    sql: ${TABLE}.locale ;;
  }

  dimension: locale_id {
    type: number
    sql: ${TABLE}.locale_id ;;
  }

  dimension: moderator {
    type: yesno
    sql: ${TABLE}.moderator ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: only_private_comments {
    type: yesno
    sql: ${TABLE}.only_private_comments ;;
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}.organization_id ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
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

  dimension: restricted_agent {
    type: yesno
    sql: ${TABLE}.restricted_agent ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}.role ;;
  }

  dimension: shared {
    type: yesno
    sql: ${TABLE}.shared ;;
  }

  dimension: shared_agent {
    type: yesno
    sql: ${TABLE}.shared_agent ;;
  }

  dimension: suspended {
    type: yesno
    sql: ${TABLE}.suspended ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }

  dimension: ticket_restriction {
    type: string
    sql: ${TABLE}.ticket_restriction ;;
  }

  dimension: time_zone {
    type: string
    sql: ${TABLE}.time_zone ;;
  }

  dimension: two_factor_auth_enabled {
    type: yesno
    sql: ${TABLE}.two_factor_auth_enabled ;;
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
    type: number
    sql: ${TABLE}.url ;;
  }

  dimension: user_fields_age {
    type: number
    sql: ${TABLE}.user_fields_age ;;
  }

  dimension: user_fields_agent_ooo {
    type: yesno
    sql: ${TABLE}.user_fields_agent_ooo ;;
  }

  dimension_group: user_fields_created {
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
    sql: ${TABLE}.user_fields_created_at ;;
  }

  dimension: user_fields_custom_field {
    type: string
    sql: ${TABLE}.user_fields_custom_field ;;
  }

  dimension: user_fields_gender {
    type: string
    sql: ${TABLE}.user_fields_gender ;;
  }

  dimension: user_fields_id {
    type: string
    sql: ${TABLE}.user_fields_id ;;
  }

  dimension: user_fields_joined_from {
    type: string
    sql: ${TABLE}.user_fields_joined_from ;;
  }

  dimension: user_fields_referral_code {
    type: string
    sql: ${TABLE}.user_fields_referral_code ;;
  }

  dimension: user_fields_referred_by {
    type: string
    sql: ${TABLE}.user_fields_referred_by ;;
  }

  dimension: user_fields_total_tickets {
    type: number
    sql: ${TABLE}.user_fields_total_tickets ;;
  }

  dimension: user_fields_used_tickets {
    type: number
    sql: ${TABLE}.user_fields_used_tickets ;;
  }

  dimension: user_fields_vip {
    type: yesno
    sql: ${TABLE}.user_fields_vip ;;
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

  dimension: verified {
    type: yesno
    sql: ${TABLE}.verified ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
