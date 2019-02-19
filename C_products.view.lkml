view: products {
  sql_table_name: mysql_smile_ventures.products ;;

  dimension: cloned_from_product_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.cloned_from_product_id ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
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
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active ;;
  }

  dimension: attributes {
    type: string
    sql: ${TABLE}.attributes ;;
  }

  dimension: attributes_json {
    type: string
    sql: ${TABLE}.attributes_json ;;
  }

  dimension: available {
    type: yesno
    sql: ${TABLE}.available ;;
  }

  dimension: brand_id {
    type: string
    # hidden: yes
    sql: ${TABLE}.brand_id ;;
  }

  dimension: cashback_rate {
    type: number
    sql: ${TABLE}.cashback_rate ;;
  }

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: coupon_discount_rate {
    type: number
    sql: ${TABLE}.coupon_discount_rate ;;
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

  dimension: description_en {
    type: string
    sql: ${TABLE}.description_en ;;
  }

  dimension: description_kr {
    type: string
    sql: ${TABLE}.description_kr ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: is_on_promotion {
    type: yesno
    sql: ${TABLE}.is_on_promotion ;;
  }

  dimension: korean_customs_code {
    type: string
    sql: ${TABLE}.korean_customs_code ;;
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}.manufacturer ;;
  }

  dimension: material {
    type: string
    sql: ${TABLE}.material ;;
  }

  dimension: md_comment {
    type: string
    sql: ${TABLE}.md_comment ;;
  }

  dimension: md_rate {
    type: number
    sql: ${TABLE}.md_rate ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: name_en {
    type: string
    sql: ${TABLE}.name_en ;;
  }

  dimension: name_kr {
    type: string
    sql: ${TABLE}.name_kr ;;
  }

  dimension_group: normalized {
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
    sql: ${TABLE}.normalized_at ;;
  }

  dimension: origin {
    type: string
    sql: ${TABLE}.origin ;;
  }

  dimension: precautions {
    type: string
    sql: ${TABLE}.precautions ;;
  }

  dimension: release_date {
    type: string
    sql: ${TABLE}.release_date ;;
  }

  dimension_group: sale_ends {
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
    sql: ${TABLE}.sale_ends_at ;;
  }

  dimension_group: sale_starts {
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
    sql: ${TABLE}.sale_starts_at ;;
  }

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
  }

  dimension: service_area {
    type: string
    sql: ${TABLE}.service_area ;;
  }

  dimension: size_details {
    type: string
    sql: ${TABLE}.size_details ;;
  }

  dimension: sizechart_id {
    type: string
    sql: ${TABLE}.sizechart_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: supplier {
    type: string
    sql: ${TABLE}.supplier ;;
  }

  dimension: tag_description {
    type: string
    sql: ${TABLE}.tag_description ;;
  }

  dimension: tag_keyword {
    type: string
    sql: ${TABLE}.tag_keyword ;;
  }

  dimension: tag_title {
    type: string
    sql: ${TABLE}.tag_title ;;
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

  dimension: us_tax_code {
    type: string
    sql: ${TABLE}.us_tax_code ;;
  }

  measure: count {
    type: count
    drill_fields: [cloned_from_product_id, name, brands.name, brands.id, products_categories.count]
  }
}
