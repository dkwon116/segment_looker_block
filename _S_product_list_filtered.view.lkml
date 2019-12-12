view: product_list_filtered {
  sql_table_name: javascript.product_list_filtered_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

#  dimension: event_id {
#    type: string
#    sql: CONCAT(cast(${TABLE}.timestamp AS string), ${TABLE}.anonymous_id, '-t') ;;
#  }

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

  dimension: filters {
    type: string
    sql: ${TABLE}.filters ;;
    hidden: yes
  }

  dimension: sorts {
    type: string
    sql: ${TABLE}.filters ;;
    hidden: yes
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: list_id {
    type: string
    sql: ${TABLE}.list_id ;;
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
    hidden: yes
  }

  dimension: list_type {
    type: string
    sql: CASE
          WHEN ${type} = 'daily' THEN 'Daily'
          WHEN ${type} = 'hashtag' THEN 'Hashtag'
          WHEN ${type} = 'category' THEN 'Category'
          WHEN ${type} = 'brand' THEN 'Brand'
          WHEN ${context_page_path} = '/sale' THEN 'Sale'
          WHEN ${context_page_path} LIKE '%/new-arrival%' THEN 'New'
          WHEN ${context_page_path} LIKE '%/brands/view%' THEN 'Brand'
          WHEN ${context_page_path} LIKE '%/wishlist%' THEN 'Wishlist'
          WHEN ${context_page_path} LIKE '%/search%' THEN 'Search'
          ELSE 'NA'
          END;;
  }

  dimension: section {
    type: string
    sql: ${TABLE}.section_name ;;
  }

  dimension: is_curated {
    type: yesno
    sql: IF(${list_type} IN ('Daily', 'Hashtag'), true, false) ;;
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

  measure: product_list_viewed_count {
    type: count
    drill_fields: [category, list_id, list_type, product_list_viewed_count]
  }

#   measure: count_visitors {
#     type: count_distinct
#     sql: ${event_facts.looker_visitor_id} ;;
#   }
}
