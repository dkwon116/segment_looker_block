view: product_viewed {
  sql_table_name: javascript.product_viewed_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: cashback_rate {
    type: number
    sql: ${TABLE}.cashback_rate ;;
  }

  dimension: context_campaign_content {
    type: string
    sql: ${TABLE}.context_campaign_content ;;
  }

  dimension: context_campaign_contents {
    type: string
    sql: ${TABLE}.context_campaign_contents ;;
  }

  dimension: context_campaign_medium {
    type: string
    sql: ${TABLE}.context_campaign_medium ;;
  }

  dimension: context_campaign_name {
    type: string
    sql: ${TABLE}.context_campaign_name ;;
  }

  dimension: context_campaign_source {
    type: string
    sql: ${TABLE}.context_campaign_source ;;
  }

  dimension: context_campaign_term {
    type: string
    sql: ${TABLE}.context_campaign_term ;;
  }

  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_library_name {
    type: string
    sql: ${TABLE}.context_library_name ;;
  }

  dimension: context_library_version {
    type: string
    sql: ${TABLE}.context_library_version ;;
  }

  dimension: context_page_path {
    type: string
    sql: ${TABLE}.context_page_path ;;
  }

  dimension: context_page_referrer {
    type: string
    sql: ${TABLE}.context_page_referrer ;;
  }

  dimension: context_page_search {
    type: string
    sql: ${TABLE}.context_page_search ;;
  }

  dimension: context_page_title {
    type: string
    sql: ${TABLE}.context_page_title ;;
  }

  dimension: context_page_url {
    type: string
    sql: ${TABLE}.context_page_url ;;
  }

  dimension: context_user_agent {
    type: string
    sql: ${TABLE}.context_user_agent ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: event_text {
    type: string
    sql: ${TABLE}.event_text ;;
  }

  dimension: image_url {
    type: string
    sql: ${TABLE}.image_url ;;
  }

  dimension: list_price {
    type: number
    sql: ${TABLE}.list_price ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
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

  dimension: prev_path {
    type: string
    sql: ${TABLE}.prev_path ;;
  }

  dimension: prev_path_id {
    type: string
    sql: CASE
    WHEN ${prev_path} LIKE '/category%' THEN SUBSTR(${prev_path}, 11)
    ELSE '' END;;
  }

  dimension: prev_path_type {
    type: string
    sql: CASE
    WHEN ${prev_path} = '/' THEN 'Daily'
    WHEN ${prev_path} LIKE '/view/%' THEN 'Product'
    WHEN ${prev_path} LIKE '/category%' THEN
      CASE
        WHEN ${list_facts.type} = 'hashtag' THEN 'Hashtag'
        WHEN ${list_facts.type} = 'category' THEN 'Category'
        WHEN ${list_facts.type} = 'collection' THEN 'Daily'
      END
    WHEN ${prev_path} LIKE '/sale%' THEN 'Sale'
    WHEN ${prev_path} LIKE '/new-arrival%' THEN 'New'
    WHEN ${prev_path} LIKE '/brands/view%' THEN 'Brand'
    WHEN ${prev_path} LIKE '/search/products%' THEN 'Search'
    WHEN ${prev_path} LIKE '/user/wishlist%' THEN 'Wishlist'
    ELSE 'NA'
    END;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: purchase_type {
    type: string
    sql: ${TABLE}.purchase_type ;;
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

  dimension: retailer {
    type: string
    sql: ${TABLE}.retailer ;;
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

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
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

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
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

  dimension: value {
    type: number
    sql: ${TABLE}.value ;;
  }

  dimension: is_sale {
    type: yesno
    sql: if(${TABLE}.list_price > ${TABLE}.price, true, false) ;;
  }

  measure: count {
    type: count
    drill_fields: [id, context_campaign_name, context_library_name, name, product_id, price, timestamp_raw]
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
  }
}
