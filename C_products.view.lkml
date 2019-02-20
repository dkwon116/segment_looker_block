view: products {
  sql_table_name: mysql_smile_ventures.products ;;

  dimension: cloned_from_product_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.cloned_from_product_id ;;
    hidden: yes
  }

  dimension: _fivetran_deleted {
    type: yesno
    hidden: yes
    sql: ${TABLE}._fivetran_deleted ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    hidden: yes
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

  dimension: product_active {
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
    hidden: yes
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
    hidden: yes
  }

  dimension: coupon_discount_rate {
    type: number
    sql: ${TABLE}.coupon_discount_rate ;;
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
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: description_en {
    type: string
    sql: ${TABLE}.description_en ;;
    hidden: yes
  }

  dimension: description_kr {
    type: string
    sql: ${TABLE}.description_kr ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: korean_customs_code {
    type: string
    sql: ${TABLE}.korean_customs_code ;;
    hidden: yes
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}.manufacturer ;;
    hidden: yes
  }

  dimension: material {
    type: string
    sql: ${TABLE}.material ;;
  }

  dimension: md_comment {
    type: string
    sql: ${TABLE}.md_comment ;;
    hidden: yes
  }

  dimension: md_rate {
    type: number
    sql: ${TABLE}.md_rate ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: name_en {
    type: string
    sql: ${TABLE}.name_en ;;
    hidden: yes
  }

  dimension: name_kr {
    type: string
    sql: ${TABLE}.name_kr ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: release_date {
    type: string
    sql: ${TABLE}.release_date ;;
    hidden: yes
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
    hidden: yes
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
    hidden: yes
  }

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
    hidden: yes
  }

  dimension: service_area {
    type: string
    sql: ${TABLE}.service_area ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: tag_keyword {
    type: string
    sql: ${TABLE}.tag_keyword ;;
    hidden: yes
  }

  dimension: tag_title {
    type: string
    sql: ${TABLE}.tag_title ;;
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

  dimension: us_tax_code {
    type: string
    sql: ${TABLE}.us_tax_code ;;
    hidden: yes
  }

  measure: product_count {
    type: count
    drill_fields: [cloned_from_product_id, name, brands.name, brands.id, products_categories.count]
  }
}
