view: catch_users {
  sql_table_name: mysql_smile_ventures.users ;;

  dimension: id {
    primary_key: yes
    type: string
    tags: ["user_id"]
    sql: ${TABLE}.id ;;
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/19?UserID= {{value | encode_url}}"
      icon_url: "https://looker.com/favicon.ico"
    }
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
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
    sql: ${TABLE}._fivetran_synced ;;
    hidden: yes
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension_group: birthday {
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
    sql: ${TABLE}.birthday ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: customs_code {
    type: string
    sql: ${TABLE}.customs_code ;;
    hidden: yes
  }

  dimension: email {
    group_label: "Info"
    type: string
    tags: ["email"]
    sql: ${TABLE}.email ;;
  }

  dimension: email_source {
    group_label: "Info"
    type: string
    sql: CASE
      WHEN ${email} LIKE "%naver%" THEN "Naver"
      WHEN ${email} LIKE "%gmail%" THEN "Gmail"
      WHEN ${email} IS NULL THEN "No Email"
      ELSE "Other" END;;
  }

  dimension: entity_name {
    type: string
    sql: ${TABLE}.entity_name ;;
    hidden: yes
  }

  dimension: facebook_id {
    type: string
    sql: ${TABLE}.facebook_id ;;
    hidden: yes
  }

  dimension: favourite_brands {
    type: string
    sql: ${TABLE}.favourite_brands ;;
    hidden: yes
  }

  dimension: name {
    group_label: "Info"
    type: string
    sql: CONCAT(${last_name}, ${first_name}) ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
    hidden: yes
  }

  dimension: gender {
    group_label: "Info"
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: gender_preference {
    type: string
    sql: ${TABLE}.gender_preference ;;
    hidden: yes
  }

  dimension: ip {
    type: string
    sql: ${TABLE}.ip ;;
    hidden: yes
  }

  dimension: is_temporary_password {
    type: yesno
    sql: ${TABLE}.is_temporary_password ;;
    hidden: yes
  }

  dimension: kakaotalk_id {
    type: string
    sql: ${TABLE}.kakaotalk_id ;;
    hidden: yes
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
    hidden: yes
  }

  dimension_group: last_sign_in {
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
    sql: ${TABLE}.last_sign_in ;;
  }

  dimension: level {
    type: string
    sql: ${TABLE}.level ;;
    hidden: yes
  }

  dimension: password {
    type: string
    sql: ${TABLE}.password ;;
    hidden: yes
  }

  dimension: phone {
    group_label: "Info"
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: referred_by {
    type: string
    sql: ${TABLE}.referred_by ;;
    hidden: yes
  }

  dimension: role {
    type: string
    sql: ${TABLE}.role ;;
    hidden: yes
  }

  dimension: terms_accepted {
    type: yesno
    sql: ${TABLE}.terms_accepted ;;
    hidden: yes
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

  measure: count {
    type: count
    drill_fields: [id, entity_name, first_name, last_name]
  }
}
