view: user_products {
  derived_table: {
    sql_trigger_value: select count(*) from ${product_events.SQL_TABLE_NAME} ;;
    sql:
      select
        distinct
        t.*,
        p.gender,
        p.brand_id,
        p.brand_name,
        c.gender as category_gender,
        c.id as category_id,
        c.name as category_name,
        c.category2_id as category2_id,
        c.category2_name as category2_name
        from(
          select looker_visitor_id, product_id, event, upper(retailer) as retailer
          from ${product_events.SQL_TABLE_NAME}
          where looker_visitor_id is not null
          and product_id is not null
          and event in ('product_viewed','added_to_wishlist','outlink_sent','order_completed')
        ) t
        join ${product_facts.SQL_TABLE_NAME} p on p.id=t.product_id
        join ${products_categories.SQL_TABLE_NAME} pc on pc.product_id=t.product_id and pc._fivetran_deleted=false
        join ${categories.SQL_TABLE_NAME} c on c.id=pc.category_id and c.type='category' and c.category2_name is not null

       ;;
  }

}
