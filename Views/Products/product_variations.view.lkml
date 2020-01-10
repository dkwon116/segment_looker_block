view: product_variations {
#   sql_table_name: aurora_smile_ventures.product_variations ;;
  drill_fields: [cloned_from_product_variation_id]

  derived_table: {
    sql_trigger_value: select count(*) from aurora_smile_ventures.product_variations ;;
    sql:
      select t.*
      from(
        select
          *
          ,trunc(first_value(if(active=true,list_price,null) ignore nulls) over (partition by product_id order by price rows between unbounded preceding and unbounded following)) as lowest_price
          ,trunc(first_value(if(active=true,price,null) ignore nulls) over (partition by product_id order by price rows between unbounded preceding and unbounded following)) as lowest_sale_price
        from aurora_smile_ventures.product_variations
      ) t
      ;;
  }


  dimension: cloned_from_product_variation_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.cloned_from_product_variation_id ;;
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

  dimension: barcode1 {
    type: string
    sql: ${TABLE}.barcode1 ;;
  }

  dimension: barcode2 {
    type: string
    sql: ${TABLE}.barcode2 ;;
  }

  dimension: barcode3 {
    type: string
    sql: ${TABLE}.barcode3 ;;
  }

  dimension: color {
    type: string
    sql: ${TABLE}.color ;;
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

  dimension: discount_price {
    type: number
    sql: ${TABLE}.discount_price ;;
  }

  dimension: galleria_discount_rate {
    type: number
    sql: ${TABLE}.galleria_discount_rate ;;
  }

  dimension: galleria_global_discount_rate {
    type: number
    sql: ${TABLE}.galleria_global_discount_rate ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: is_gift {
    type: yesno
    sql: ${TABLE}.is_gift ;;
  }

  dimension: is_on_sale {
    type: yesno
    sql: ${TABLE}.is_on_sale ;;
  }

  dimension: list_price {
    type: number
    sql: ${TABLE}.list_price ;;
  }

  dimension: naver_total_discount_rate {
    type: number
    sql: ${TABLE}.naver_total_discount_rate ;;
  }

  dimension: position {
    type: number
    sql: ${TABLE}.position ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
  }

  dimension: lowest_price {
    type: number
    sql: ${TABLE}.lowest_price ;;
  }

  dimension: lowest_sale_price {
    type: number
    sql: ${TABLE}.lowest_sale_price ;;
  }

  dimension: price_modifier {
    type: number
    sql: ${TABLE}.price_modifier ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: promo_period {
    type: string
    sql: ${TABLE}.promo_period ;;
  }

  dimension: promotion_price {
    type: number
    sql: ${TABLE}.promotion_price ;;
  }

  dimension: size {
    type: string
    sql: ${TABLE}.size ;;
  }

  dimension: size_id {
    type: string
    sql: ${TABLE}.size_id ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  dimension: smile_ventures_discount_rate {
    type: number
    sql: ${TABLE}.smile_ventures_discount_rate ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: type2 {
    type: string
    sql: ${TABLE}.type2 ;;
  }

  dimension: type3 {
    type: string
    sql: ${TABLE}.type3 ;;
  }

  dimension: upc {
    type: string
    sql: ${TABLE}.upc ;;
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

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }

  dimension: value2 {
    type: string
    sql: ${TABLE}.value2 ;;
  }

  dimension: value3 {
    type: string
    sql: ${TABLE}.value3 ;;
  }

  dimension: vendor_list_price {
    type: number
    sql: ${TABLE}.vendor_list_price ;;
  }

  dimension: vendor_price {
    type: number
    sql: ${TABLE}.vendor_price ;;
  }

  dimension: vendor_price_currency {
    type: string
    sql: ${TABLE}.vendor_price_currency ;;
  }

  dimension: vendor_sku {
    type: string
    sql: ${TABLE}.vendor_sku ;;
  }

  dimension: vendor_store_id {
    type: string
    sql: ${TABLE}.vendor_store_id ;;
  }

  measure: count {
    type: count
    drill_fields: [cloned_from_product_variation_id, product_variation_maps.count]
  }

}
