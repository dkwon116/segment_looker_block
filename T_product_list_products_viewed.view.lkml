view: products_viewed_in_list {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.product_list_viewed ;;
    sql: SELECT
          results.id
          , results.timestamp
          , results.anonymous_id
          , trim(results.name, '"') as product_name
          , trim(results.brand, '"') as product_brand
          , trim(results.product_id, '"') as product_id
          , trim(results.url, '"') as product_url
          , cast(results.position as INT64) as position_in_list
        FROM (
          WITH product_data as
            (
              SELECT
                id as id
                , timestamp as timestamp
                , anonymous_id as anonymous_id
                , SPLIT(trim(products,'[]'), '},' ) as products_array
              FROM
                javascript.product_list_viewed_view
            )
          SELECT
            id
            , timestamp as timestamp
            , anonymous_id as anonymous_id
            , JSON_EXTRACT(CONCAT(product, '}'), "$.brand") as brand
            , JSON_EXTRACT(CONCAT(product, '}'), "$.name") as name
            , JSON_EXTRACT(CONCAT(product, '}'), "$.product_id") as product_id
            , JSON_EXTRACT(CONCAT(product, '}'), "$.url") as url
            , JSON_EXTRACT(CONCAT(product, '}'), "$.position") as position
          FROM product_data
            CROSS JOIN UNNEST(products_array) as product
          ) as results ;;
    }


  dimension: id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
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

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: product_name {
    group_label: "Products in List"
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: brand {
    group_label: "Products in List"
    type: string
    sql: ${TABLE}.product_brand ;;
  }

  dimension: product_id {
    group_label: "Products in List"
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: url {
    group_label: "Products in List"
    type: string
    sql: ${TABLE}.product_url ;;
  }

  dimension: position_in_list {
    group_label: "Products in List"
    type: string
    sql: ${TABLE}.position_in_list * (product_list_viewed.page_number + 1) ;;
  }

  measure: product_count {
    type: count
  }

}
