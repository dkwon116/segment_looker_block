view: product_events {
  derived_table: {
    # combine all track events related to product
    # product list viewed, product viewed, added to wishlist, added to cart, order complete
    sql_trigger_value: select count(*) from ${mapped_events.SQL_TABLE_NAME} ;;
    sql: select *
        , CASE
              WHEN e.source_path = '/' THEN 'Daily'
              WHEN e.source_path LIKE '/view/%' THEN 'Product'
              WHEN e.source_path LIKE '/category%' THEN
                CASE
                  WHEN c.type = 'category' THEN 'Category'
                  WHEN c.type = 'hashtag' THEN 'Hashtag'
                  WHEN c.type = 'collection' THEN 'Daily'
                END
              WHEN e.source_path LIKE '/sale%' THEN 'Sale'
              WHEN e.source_path LIKE '/new-arrival%' THEN 'New'
              WHEN e.source_path LIKE '/brands/view%' THEN 'Brand'
              WHEN e.source_path LIKE '/search/products%' THEN 'Search'
              WHEN e.source_path LIKE '/user/wishlist%' THEN 'Wishlist'
              ELSE 'NA'
            END as source
        , CASE
            WHEN e.source_path LIKE '/category%' THEN SUBSTR(e.source_path, 11)
            WHEN e.source_path LIKE '/brands/view%' THEN SUBSTR(e.source_path, 14)
            WHEN e.source_path LIKE '/view%' THEN SUBSTR(e.source_path, 6)
          END as source_id

      from (
        select CONCAT(t.product_id, me.event_id) as product_event_id
          , me.event_id as event_id
          , t.product_id as product_id
          , t.prev_path as source_path
          , 'product_viewed' as event
        from javascript.product_viewed_view as t
        inner join ${mapped_events.SQL_TABLE_NAME} as me
        on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id

        union all

        select CONCAT(t.product_id, me.event_id) as product_event_id
          , me.event_id as event_id
          , t.product_id as product_id
          , pl.context_page_path as source_path
          , 'product_list_viewed' as event
        from ${products_viewed_in_list.SQL_TABLE_NAME} as t
        inner join ${mapped_events.SQL_TABLE_NAME} as me
        on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
        left join javascript.product_list_viewed_view as pl
        on t.list_viewed_id = pl.id
      ) as e
      left join mysql_smile_ventures.categories as c
        on SUBSTR(e.source_path, 11) = c.id
       ;;
  }

  dimension: product_event_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.product_event_id ;;
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: source_id {
    type: string
    sql: ${TABLE}.source_id ;;
  }


}
