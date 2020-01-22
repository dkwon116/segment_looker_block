view: products_viewed_in_list_current {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.product_list_viewed ;;
    sql: SELECT
          results.list_viewed_id
          , results.timestamp
          , results.anonymous_id
          , type
          , trim(results.name, '"') as product_name
          , trim(results.brand, '"') as product_brand
          , trim(results.product_id, '"') as product_id
          , trim(results.url, '"') as product_url
--          , cast(results.position as INT64) as position_in_list
          ,if(ifnull(safe_cast(results.position as INT64),ifnull(safe_cast(split(trim(results.position,'"'),',')[safe_offset(0)] as INT64),-1)+ifnull(safe_cast(split(trim(results.position,'"'),',')[safe_offset(1)] as INT64),-1)+1)<1,
            null,
            ifnull(safe_cast(results.position as INT64),ifnull(safe_cast(split(trim(results.position,'"'),',')[safe_offset(0)] as INT64),-1)+ifnull(safe_cast(split(trim(results.position,'"'),',')[safe_offset(1)] as INT64),-1)+1)
          ) as position_in_list
        FROM (
          WITH product_data as
            (
              SELECT
                id as list_viewed_id
                , timestamp as timestamp
                , anonymous_id as anonymous_id
                , type
                , SPLIT(trim(products,'[]'), '},' ) as products_array
              FROM
                javascript.product_list_viewed_view
              WHERE timestamp >= CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS TIMESTAMP)
            )
          SELECT
            list_viewed_id
            , timestamp as timestamp
            , anonymous_id as anonymous_id
            , type
            , JSON_EXTRACT(CONCAT(product, '}'), "$.brand") as brand
            , JSON_EXTRACT(CONCAT(product, '}'), "$.name") as name
            , JSON_EXTRACT(CONCAT(product, '}'), "$.product_id") as product_id
            , JSON_EXTRACT(CONCAT(product, '}'), "$.url") as url
            , JSON_EXTRACT(CONCAT(product, '}'), "$.position") as position
          FROM product_data
            CROSS JOIN UNNEST(products_array) as product
          ) as results ;;
  }

}
