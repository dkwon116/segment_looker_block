view: product_list_viewed {
  sql_table_name: javascript.product_list_viewed_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: event_id {
    type: string
    sql: CONCAT(cast(${TABLE}.timestamp AS string), ${TABLE}.anonymous_id, '-t') ;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_library_name {
    type: string
    hidden: yes
    sql: ${TABLE}.context_library_name ;;
  }

  dimension: context_library_version {
    type: string
    hidden: yes
    sql: ${TABLE}.context_library_version ;;
  }

  dimension: context_page_path {
    type: string
    sql: ${TABLE}.context_page_path ;;
  }

  dimension: context_page_referrer {
    type: string
    hidden: yes
    sql: ${TABLE}.context_page_referrer ;;
  }

  dimension: context_page_search {
    type: string
    hidden: yes
    sql: ${TABLE}.context_page_search ;;
  }

  dimension: context_page_title {
    type: string
    hidden: yes
    sql: ${TABLE}.context_page_title ;;
  }

  dimension: context_page_url {
    type: string
    sql: ${TABLE}.context_page_url ;;
  }

  dimension: context_user_agent {
    type: string
    hidden: yes
    sql: ${TABLE}.context_user_agent ;;
  }

  dimension: event {
    type: string
    hidden: yes
    sql: ${TABLE}.event ;;
  }

  dimension: event_text {
    type: string
    hidden: yes
    sql: ${TABLE}.event_text ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: list_id {
    type: string
    sql: ${TABLE}.list_id ;;
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

  dimension_group: original_timestamp {
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
    sql: ${TABLE}.original_timestamp ;;
  }

  dimension: page_number {
    type: number
    sql: ${TABLE}.page_number ;;
  }

  dimension: product_count {
    type: number
    sql: ${TABLE}.product_count ;;
  }

  dimension: products {
    type: string
    sql: ${TABLE}.products ;;
    hidden: yes
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

  dimension_group: sent {
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
    sql: ${TABLE}.sent_at ;;
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

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: list_type {
    type: string
    sql: CASE
    WHEN ${type} = 'daily' THEN 'Daily'
    WHEN ${type} = 'hashtag' THEN 'Hashtag'
    WHEN ${type} = 'category' THEN 'Category'
    WHEN ${context_page_path} = '/sale' THEN 'Sale'
    WHEN ${context_page_path} LIKE '%/new-arrival%' THEN 'New'
    WHEN ${context_page_path} LIKE '%/brands/view%' THEN 'Brand'
    ELSE 'NA'
    END;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
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

  measure: product_list_count {
    type: count
    drill_fields: [id, context_library_name]
  }

  measure: product_list_viewed_users {
    type: count_distinct
    sql:  event_facts.looker_visitor_id;;
  }
}
