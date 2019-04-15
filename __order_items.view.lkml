view: order_items {
  derived_table: {
    sql_trigger_value: select count(*) from mysql_smile_ventures.rakuten_events ;;
    sql: WITH normalized_event as (
        SELECT
          re.order_id
          , CASE
            -- remove duplicate for Mr Porter. Between events MR Porter prepends M / R / MR
            WHEN re.advertiser_id = 36586 THEN IF(STARTS_WITH(re.sku_number, "M") OR STARTS_WITH(re.sku_number, "R"), substr(re.sku_number, STRPOS(re.sku_number, "_") + 1), re.sku_number)
            -- ssense sometimes add extra at the end of sku_id
            WHEN re.advertiser_id = 41610 THEN substr(re.sku_number, 1, 13)
            ELSE re.sku_number END as sku_id
          ,re.product_name as product_name
          ,re.transaction_date as transaction_at
          ,re.advertiser_id as vendor_id
          ,ROUND(re.sale_amount, 2) as sale_amount
          ,re.currency as currency
          ,re.process_date as process_at
          ,re.u1 as encoded_user_id
          ,re.quantity as quantity
          ,re.is_event
          ,r.name as vendor
          ,CASE
            WHEN re.sale_amount >= 0 THEN "purchase"
            ELSE "return" END as order_type
          -- decode user_id
          ,IF(REGEXP_CONTAINS(re.u1, r"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$"), SAFE_CONVERT_BYTES_TO_STRING(FROM_BASE64(re.u1)), re.u1) as decoded_user_id
        FROM mysql_smile_ventures.rakuten_events as re
        LEFT JOIN ${retailers.SQL_TABLE_NAME} as r
          ON re.advertiser_id = r.vendor_id

        WHERE re.sale_amount IS NOT NULL
        )
        -- group by single order item. order_id and sku_id should be unique
        SELECT
          CONCAT(e.order_id, "-", e.sku_id) as id
          ,e.order_id
          ,e.sku_id
          ,e.transaction_at
          ,e.vendor
          ,e.order_type
          ,e.quantity
          ,e.user_id
          ,e.product_name
          ,e.sale_amount
          ,ROUND(e.sale_amount * c.rate) as krw_amount
          ,e.process_at
          , CASE
            -- Matches Fashion
            WHEN e.vendor_id = 39265 THEN substr(e.sku_id, 1, 8)
            -- Farfetch
            WHEN e.vendor_id = 37938 THEN IF(STARTS_WITH(e.sku_id, "R"), substr(e.sku_id, 3, 8), substr(e.sku_id, 1, 8))
            ELSE e.sku_id END
          as vendor_product_id
          ,IF(e.is_event = "N", true, false) as is_confirmed
        FROM (
        -- normalize to single record by selecting is_event = n record, if exists
          SELECT
            e.order_id
            ,e.sku_id
            ,e.vendor
            ,e.vendor_id
            ,e.order_type
            ,first_value(e.quantity) over (partition by e.order_id, e.sku_id, e.order_type order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as quantity
            ,e.currency
            ,IF(STARTS_WITH(e.decoded_user_id, "seg_"), SUBSTR(e.decoded_user_id, 5, 36), SUBSTR(e.decoded_user_id, 1, 36)) as user_id
            ,first_value(e.is_event) over (partition by e.order_id, e.sku_id, e.order_type order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as is_event
            ,first_value(e.transaction_at) over (partition by e.order_id, e.sku_id order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as transaction_at
            ,first_value(e.product_name) over (partition by e.order_id, e.sku_id, e.order_type order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as product_name
            ,first_value(e.sale_amount) over (partition by e.order_id, e.sku_id, e.order_type order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as sale_amount
            ,first_value(e.process_at) over (partition by e.order_id, e.sku_id, e.order_type order by e.is_event, e.process_at rows between unbounded preceding and unbounded following) as process_at
          FROM normalized_event as e) as e
          LEFT JOIN ${currencies.SQL_TABLE_NAME} as c
            -- if on sat (7) - mon (2), then get previous friday / otherwise get previous day
            ON DATE_SUB(DATE(e.transaction_at), INTERVAL 1 DAY) = c.date
              AND e.currency = c.unit
          GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14


    ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
    primary_key: yes
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: sku_id {
    type: string
    sql: ${TABLE}.sku_id ;;
  }

  dimension: vendor_product_id {
    type: string
    sql: ${TABLE}.vendor_product_id ;;
  }

  dimension: product_name {
    type:  string
    sql: ${TABLE}.product_name ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: process_at {
    type: time
    sql: ${TABLE}.process_at ;;
    timeframes: [time, date, month, year]
  }

  dimension_group: transaction_at {
    type: time
    sql: ${TABLE}.transaction_at ;;
    timeframes: [time, date, month, year]
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: sale_amount {
    type: number
    sql: ${TABLE}.sale_amount ;;
  }

  dimension: krw_amount {
    type: number
    sql: ${TABLE}.krw_amount ;;
  }

  dimension: order_type {
    type: string
    sql: ${TABLE}.order_type ;;
  }

  dimension: is_confirmed {
    type: yesno
    sql: ${TABLE}.is_confirmed ;;
  }

  measure: total_sales {
    type: sum
    sql: ${krw_amount} ;;
  }

  measure: count {
    type: count
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: gross_sales {
    type: sum
    sql: ${krw_amount} ;;
    filters: {
      field: order_type
      value: "purchase"
    }
  }

  measure: sales_net_of_returns {
    type: sum
    sql: ${krw_amount} ;;
  }
}
