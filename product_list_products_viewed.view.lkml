view: products_viewed_in_list {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.product_list_viewed ;;
    sql: SELECT
          results.event_id,
          cast(results.name as STRING) as product_name,
          cast(results.brand as STRING) as product_brand,
          cast(results.product_id as STRING) as product_id,
          cast(results.url as STRING) as product_url,
          cast(results.position as INT64) as position_in_list
        FROM (
          WITH product_data as
            (
              SELECT
                id as event_id
                , SPLIT(trim(products,'[]'), '},' ) as products_array
              FROM
                javascript.product_list_viewed_view
            )
          SELECT
            event_id
            , JSON_EXTRACT(CONCAT(product, '}'), "$.brand") as brand
            , JSON_EXTRACT(CONCAT(product, '}'), "$.name") as name
            , JSON_EXTRACT(CONCAT(product, '}'), "$.product_id") as product_id
            , JSON_EXTRACT(CONCAT(product, '}'), "$.url") as url
            , JSON_EXTRACT(CONCAT(product, '}'), "$.position") as position
          FROM product_data
            CROSS JOIN UNNEST(products_array) as product
          ) as results ;;
    }


  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_url {
    type: string
    sql: ${TABLE}.product_url ;;
  }

  dimension: position_in_list {
    type: string
    sql: ${TABLE}.position_in_list ;;
  }

  measure: count {
    type: count
  }

}
