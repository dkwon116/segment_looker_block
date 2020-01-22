view: product_events {
  derived_table: {
    # combine all track events related to product
    # product list viewed, product viewed, added to wishlist, added to cart, order complete
    sql_trigger_value: select count(*) from ${mapped_events.SQL_TABLE_NAME} ;;
    sql:

        select *
        from(
        (select * from ${product_events_current.SQL_TABLE_NAME})
        union all
        (select * from ${product_events_historical.SQL_TABLE_NAME})
        )


      --   with list_facts as (
      --     select
      --       c.id as id
      --       , c.name as name
      --       , c.type as type
      --     from aurora_smile_ventures.categories as c

      --     union distinct

      --     select
      --       b.id as id
      --       , b.name as name
      --       , "brand" as type
      --     from aurora_smile_ventures.brands as b
      --   )

      --   select e.product_event_id
      --   , e.event_id
      --   , e.looker_visitor_id
      --   , e.event
      --   , e.product_id
      --   , e.source_path
      --   , CASE
      --         WHEN e.source_path = '/' THEN 'Daily'
      --         WHEN e.source_path LIKE '/view/%' THEN 'Product'
      --         WHEN e.source_path LIKE '/sale%' THEN 'Sale'
      --         WHEN e.source_path LIKE '/new-arrival%' THEN 'New'
      --         WHEN e.source_path LIKE '/brands/view%' THEN 'Brand'
      --         WHEN e.source_path LIKE '/search/products%' THEN 'Search'
      --         WHEN e.source_path LIKE '/user/wishlist%' THEN 'Wishlist'
      --         WHEN e.source_path LIKE '/catch' THEN 'Daily'
      --         WHEN e.source_path LIKE '/category%' THEN
      --           CASE
      --             WHEN lf.type = 'hashtag' THEN 'Hashtag'
      --             WHEN lf.type = 'collection' THEN 'Daily'
      --             ELSE 'Category'
      --           END
      --         WHEN e.source_path LIKE 'direct' THEN "Direct"
      --         ELSE 'NA'
      --       END as source
      --   , e.source_id as source_id
      --   , lf.name as source_name
      --   , e.timestamp
      --   , e.type
      --   , e.retailer
      -- from (
      --   select CONCAT(t.product_id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , t.product_id as product_id
      --     , coalesce(t.prev_path, tf.prev_path) as source_path
      --     , CASE
      --       WHEN coalesce(t.prev_path, tf.prev_path) LIKE '/category%' THEN SUBSTR(coalesce(t.prev_path, tf.prev_path), 11)
      --       WHEN coalesce(t.prev_path, tf.prev_path) LIKE '/brands/view%' THEN SUBSTR(coalesce(t.prev_path, tf.prev_path), 14)
      --       WHEN coalesce(t.prev_path, tf.prev_path) LIKE '/view%' THEN SUBSTR(coalesce(t.prev_path, tf.prev_path), 7)
      --       ELSE '' END as source_id
      --     , 'product_viewed' as event
      --     , me.timestamp
      --     , null as type
      --     , t.retailer
      --   from javascript.product_viewed_view as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
      --     on t.id=me.event_id
      --   left join ${track_facts.SQL_TABLE_NAME} as tf
      --     on me.event_id = tf.event_id

      --   union all

      --   select CONCAT(t.product_id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , t.product_id as product_id
      --     , tf.current_path as source_path
      --     , CASE
      --         WHEN tf.current_path LIKE '/category%' THEN SUBSTR(tf.current_path, 11)
      --         WHEN tf.current_path LIKE '/brands/view%' THEN SUBSTR(tf.current_path, 14)
      --         WHEN tf.current_path LIKE '/view%' THEN SUBSTR(tf.current_path, 7)
      --       END as source_id
      --     , 'product_list_viewed' as event
      --     , me.timestamp
      --     , t.type
      --     , null as retailer
      --   from ${products_viewed_in_list.SQL_TABLE_NAME} as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
      --     on t.list_viewed_id=me.event_id
      --   left join ${track_facts.SQL_TABLE_NAME} as tf
      --     on me.event_id = tf.event_id

      --   union all

      --   select CONCAT(t.product_id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , t.product_id as product_id
      --     , tf.current_path as source_path
      --     , CASE
      --         WHEN tf.current_path LIKE '/category%' THEN SUBSTR(tf.current_path, 11)
      --         WHEN tf.current_path LIKE '/brands/view%' THEN SUBSTR(tf.current_path, 14)
      --         WHEN tf.current_path LIKE '/view%' THEN SUBSTR(tf.current_path, 7)
      --       END as source_id
      --     , 'product_clicked' as event
      --     , me.timestamp
      --     , t.type
      --     , null as retailer
      --   from ${product_clicked.SQL_TABLE_NAME} as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
      --     on t.id=me.event_id
      --   left join ${track_facts.SQL_TABLE_NAME} as tf
      --     on me.event_id = tf.event_id

      --   union all

      --   select CONCAT(t.product_id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , t.product_id as product_id
      --     , tf.current_path as source_path
      --     , CASE
      --       WHEN tf.current_path LIKE '/category%' THEN SUBSTR(tf.current_path, 11)
      --       WHEN tf.current_path LIKE '/brands/view%' THEN SUBSTR(tf.current_path, 14)
      --       WHEN tf.current_path LIKE '/view%' THEN SUBSTR(tf.current_path, 7)
      --       ELSE '' END as source_id
      --     , 'added_to_wishlist' as event
      --     , me.timestamp
      --     , null as type
      --     , t.retailer
      --   from javascript.product_added_to_wishlist_view as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
      --     on t.id=me.event_id
      --   left join ${track_facts.SQL_TABLE_NAME} as tf
      --     on me.event_id = tf.event_id

      --   union all

      --   select CONCAT(t.product_id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , t.product_id as product_id
      --     , tf.current_path as source_path
      --     , CASE
      --       WHEN tf.current_path LIKE '/category%' THEN SUBSTR(tf.current_path, 11)
      --       WHEN tf.current_path LIKE '/brands/view%' THEN SUBSTR(tf.current_path, 14)
      --       WHEN tf.current_path LIKE '/view%' THEN SUBSTR(tf.current_path, 7)
      --       ELSE '' END as source_id
      --     , 'outlink_sent' as event
      --     , me.timestamp
      --     , null as type
      --     , t.retailer
      --   from javascript.outlink_sent_view as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') = me.event_id
      --     on t.id=me.event_id
      --   left join ${track_facts.SQL_TABLE_NAME} as tf
      --     on me.event_id = tf.event_id
      --   where t.product_id is not null

      --   union all

      --   select CONCAT(pm.id, me.event_id) as product_event_id
      --     , me.event_id as event_id
      --     , me.looker_visitor_id
      --     , pm.id as product_id
      --     , t.vendor as source_path
      --     , '' as source_id
      --     , 'order_completed' as event
      --     , me.timestamp
      --     , null as type
      --     , t.vendor as retailer
      --   from ${order_items.SQL_TABLE_NAME} as t
      --   inner join ${mapped_events.SQL_TABLE_NAME} as me
      --   --on CONCAT(cast(t.transaction_at as string), t.user_id, '-r') = me.event_id
      --     on t.order_id=me.event_id
      --   left join ${product_maps.SQL_TABLE_NAME} as pm
      --     ON t.vendor_product_id = pm.affiliate_product_id
      --   where t.order_type = "P" and pm.id is not null

      -- ) as e
      -- left join list_facts as lf
      --   on e.source_id = lf.id

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

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
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

  dimension: source_path {
    type: string
    sql: ${TABLE}.source_path ;;
  }

  dimension: source_id {
    type: string
    sql: ${TABLE}.source_id ;;
  }

  dimension: source_name {
    type: string
    sql: ${TABLE}.source_name ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, hour, date, week, month, raw]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: retailer {
    type: string
    sql: ${TABLE}.retailer ;;
  }

  measure: count {
    type: count
  }

  measure: unique_users {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
  }

  measure: count_product_viewed {
    type: count
    filters: {
      field: event
      value: "product_viewed"
    }
  }

  measure: count_product_viewed_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "product_viewed"
    }
  }

  measure: count_product_list_viewed {
    type: count
    filters: {
      field: event
      value: "product_list_viewed"
    }
  }

  measure: count_product_list_viewed_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "product_list_viewed"
    }
  }

  measure: count_product_clicked_viewed {
    type: count
    filters: {
      field: event
      value: "product_clicked"
    }
  }

  measure: count_product_clicked_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "product_clicked"
    }
  }

  measure: ctr {
    type: number
    sql: ${count_product_clicked_viewed} / NULLIF(${count_product_list_viewed}, 0) ;;
    value_format_name: percent_2
  }



  measure: count_outlink_sent {
    type: count
    filters: {
      field: event
      value: "outlink_sent"
    }
  }

  measure: count_outlink_sent_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "outlink_sent"
    }
  }

  measure: count_added_to_wishlist {
    type: count
    filters: {
      field: event
      value: "added_to_wishlist"
    }
  }

  measure: count_added_to_wishlist_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "added_to_wishlist"
    }
  }

  measure: count_purchased {
    type: count
    filters: {
      field: event
      value: "order_completed"
    }
  }

  measure: count_purchased_user {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
    filters: {
      field: event
      value: "order_completed"
    }
  }

  measure: list_to_detail_conversion_rate {
    type: number
    sql: ${count_product_viewed_user} / NULLIF(${count_product_list_viewed_user}, 0) ;;
    value_format_name: percent_0
  }

  measure: product_viewed_conversion_rate {
    type: number
    sql: ${count_product_viewed_user} / NULLIF(${sessions.unique_visitor_count}, 0) ;;
    value_format_name: percent_0
  }


}
