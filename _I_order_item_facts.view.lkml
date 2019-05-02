view: order_item_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${order_items.SQL_TABLE_NAME} ;;
    sql: SELECT
          oi.vendor_product_id
          , pm.internal_vendor_product_id
          , pm.product_id
        from ${order_items.SQL_TABLE_NAME} as oi
        left join mysql_smile_ventures.product_maps as pm
         ON oi.vendor_product_id = pm.internal_vendor_product_id
          AND lower(oi.vendor) = lower(pm.vendor)
        group by 1, 2, 3
    ;;
  }
}
