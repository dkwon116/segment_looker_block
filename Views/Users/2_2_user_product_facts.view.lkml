view: user_product_facts {
  derived_table: {
    # combine all track events related to product
    # product list viewed, product viewed, added to wishlist, added to cart, order complete
    sql_trigger_value: select count(*) from ${user_products.SQL_TABLE_NAME} ;;
    sql:
      select *
      from(
        (select
          looker_visitor_id
          ,gender
          ,'retailer' as type
          ,retailer as type_id
          ,retailer as type_name
          ,count(distinct case when event='product_viewed' then product_id else null end) as count_view
          ,count(distinct case when event='added_to_wishlist' then product_id else null end) as count_wishlist
          ,count(distinct case when event='outlink_sent' then product_id else null end) as count_outlink
          ,count(distinct case when event='order_completed' then product_id else null end) as count_order
        from ${user_products.SQL_TABLE_NAME}
        where retailer is not null
        group by 1,2,3,4,5
        )
        union all
        (select
          looker_visitor_id
          ,gender
          ,'brand' as type
          ,brand_id as type_id
          ,brand_name as type_name
          ,count(distinct case when event='product_viewed' then product_id else null end) as count_view
          ,count(distinct case when event='added_to_wishlist' then product_id else null end) as count_wishlist
          ,count(distinct case when event='outlink_sent' then product_id else null end) as count_outlink
          ,count(distinct case when event='order_completed' then product_id else null end) as count_order
        from ${user_products.SQL_TABLE_NAME}
        where brand_name is not null
        group by 1,2,3,4,5
        )
        union all
        (select
          looker_visitor_id
          ,gender
          ,'category' as type
          ,category_id as type_id
          ,category_name as type_name
          ,count(distinct case when event='product_viewed' then product_id else null end) as count_view
          ,count(distinct case when event='added_to_wishlist' then product_id else null end) as count_wishlist
          ,count(distinct case when event='outlink_sent' then product_id else null end) as count_outlink
          ,count(distinct case when event='order_completed' then product_id else null end) as count_order
        from ${user_products.SQL_TABLE_NAME}
        where category_name is not null
        group by 1,2,3,4,5
        )
        union all
        (select
          looker_visitor_id
          ,gender
          ,'main_category' as type
          ,category2_id as type_id
          ,category2_name as type_name
          ,count(distinct case when event='product_viewed' then product_id else null end) as count_view
          ,count(distinct case when event='added_to_wishlist' then product_id else null end) as count_wishlist
          ,count(distinct case when event='outlink_sent' then product_id else null end) as count_outlink
          ,count(distinct case when event='order_completed' then product_id else null end) as count_order
        from ${user_products.SQL_TABLE_NAME}
        where category2_name is not null
        group by 1,2,3,4,5
        )
      )
      where not (count_view=1 and (count_wishlist+count_outlink+count_order)=0)
       ;;
  }

}
