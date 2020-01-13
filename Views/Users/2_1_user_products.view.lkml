view: user_products {
  derived_table: {
    sql_trigger_value: select count(*) from ${product_events.SQL_TABLE_NAME} ;;
    sql:
      select distinct t.*, p.gender, p.brand_id, p.brand_name, c.id as category_id, c.category2_name as category_name, c.gender as category_gender
        from(
          select looker_visitor_id, product_id, event, upper(retailer) as retailer
          from ${product_events.SQL_TABLE_NAME}
          where looker_visitor_id is not null
          and product_id is not null
          and event in ('product_viewed','added_to_wishlist','outlink_sent','order_completed')
          -- (select t.user_id ,t.product_id ,'wishlist' as event, upper(retailer) as retailer
          -- from javascript.product_added_to_wishlist_view as t
          -- )
          -- union all
          -- (select t.user_id ,t.product_id,'outlink' as event, upper(retailer) as retailer
          -- from javascript.outlink_sent_view as t
          -- )
          -- union all
          -- (select t.user_id, pm.id as product_id, 'order' as event, upper(t.vendor) as retailer
          -- from ${order_items.SQL_TABLE_NAME} as t
          -- left join ${product_maps.SQL_TABLE_NAME} as pm on t.vendor_product_id = pm.affiliate_product_id
          -- where t.order_type = "P"
          -- )
        ) t
        join ${product_facts.SQL_TABLE_NAME} p on p.id=t.product_id
        join ${products_categories.SQL_TABLE_NAME} pc on pc.product_id=t.product_id and pc._fivetran_deleted=false
        join ${categories.SQL_TABLE_NAME} c on c.id=pc.category_id and c.type='category' and c.category2_name is not null

       ;;
  }

}
