view: order_items {
  derived_table: {
    sql_trigger_value: select count(*) from data_data_api_db.affiliate_order_item ;;
    sql:
        -- group by single order item. order_id and sku_id should be unique
        WITH raw_order_items as (
          SELECT
            CONCAT(e.order_id, "-", e.sku_number, "-", e.order_type) as id
            ,e.order_id
            ,e.sku_number as sku_id
            ,first_value(e.transaction_date) over (partition by e.order_id order by e.transaction_date rows between unbounded preceding and unbounded following) as transaction_at
            ,coalesce(r.name, r2.name) as vendor
            ,e.order_type
            ,IF(e.order_type = "P", e.quantity, 0 - e.quantity) as quantity
            ,e.user_id
            ,e.product_name
            ,e.sale_amount
            ,e.krw_amount
            ,e.process_date as process_at
            ,e.advertiser_id
            , CASE
              -- Matches Fashion
              WHEN e.advertiser_id = "39265" THEN substr(e.sku_number, 1, 7)
              -- Farfetch
              WHEN e.advertiser_id = "37938" THEN IF(STARTS_WITH(e.sku_number, "R"), substr(e.sku_number, 3, 8), substr(e.sku_number, 1, 8))
              ELSE e.sku_number END
            as vendor_product_id
            ,IF(e.confirmed, true, false) as is_confirmed
          FROM data_data_api_db.affiliate_order_item as e
          LEFT JOIN ${retailers.SQL_TABLE_NAME} as r
            ON e.advertiser_id = r.vendor_id
          LEFT JOIN ${retailers.SQL_TABLE_NAME} as r2
            ON e.advertiser_id = r2.partnerize_id
          WHERE e._fivetran_deleted = false AND e.order_id NOT IN (SELECT order_id FROM google_sheets.test_orders)
        )

        SELECT
          oi.id
          , oi.order_id
          , oi.sku_id
          , IF(EXTRACT(YEAR from oi.transaction_at) = 2019 AND (EXTRACT(MONTH from oi.transaction_at) IN (5, 7) AND EXTRACT(DAY from oi.transaction_at) > 27) OR (EXTRACT(MONTH from oi.transaction_at) = 6 AND EXTRACT(DAY from oi.transaction_at) > 26), TIMESTAMP_ADD(oi.transaction_at, INTERVAL 96 HOUR), oi.transaction_at) as transaction_at
          , oi.vendor
          , oi.order_type
          , oi.quantity
          , oi.user_id
          , oi.product_name
          , oi.sale_amount
          , oi.krw_amount
          , IF(EXTRACT(YEAR from oi.transaction_at) = 2019 AND (EXTRACT(MONTH from oi.transaction_at) IN (5, 7) AND EXTRACT(DAY from oi.transaction_at) > 27) OR (EXTRACT(MONTH from oi.transaction_at) = 6 AND EXTRACT(DAY from oi.transaction_at) > 26), TIMESTAMP_ADD(oi.process_at, INTERVAL 96 HOUR), oi.process_at) as process_at
          , oi.advertiser_id
          , oi.vendor_product_id
          , oi.is_confirmed
        FROM raw_order_items as oi


-- shift last 4 days of the month from May ~ June
-- create order filters for obsolete > google spreadsheet

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
    timeframes: [time, hour, date, month, year, raw]
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

  dimension: catch_product_id {
    type: string
    sql: ${product_maps.product_id} ;;
  }

  dimension: advertiser_id {
    type: number
    sql: ${TABLE}.advertiser_id ;;
  }

  measure: total_sales {
    type: sum
    sql: ${krw_amount} / 1000 ;;
    value_format_name: decimal_0
    filters: {
      field: order_type
      value: "P"
    }
  }

  measure: average_item_value {
    type: number
    sql:  ${total_sales} / NULLIF(${total_units}, 0);;
    value_format_name: decimal_0
  }

  measure: count {
    type: count
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

#   measure: gross_sales {
#     type: sum
#     sql: ${krw_amount} ;;
#     filters: {
#       field: order_type
#       value: "P"
#     }
#   }

  measure: sales_net_of_returns {
    type: sum
    sql: ${krw_amount} ;;
  }

  measure: distinct_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: total_units {
    type: sum
    sql: ${quantity} ;;
    filters: {
      field: order_type
      value: "P"
    }
  }

  measure: count_products {
    type: count_distinct
    sql: ${vendor_product_id} ;;
  }

  measure: count_products_in_catch {
    type: count_distinct
    sql: ${catch_product_id} ;;
  }

  measure: catch_match_rate {
    type: number
    sql: ${count_products_in_catch} / ${count_products} ;;
    value_format_name: percent_0
  }
}
