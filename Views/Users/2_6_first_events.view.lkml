view: first_events {
  derived_table: {
    sql_trigger_value: select count(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql:

      select
        e.looker_visitor_id
        ,u.signed_up
        ,e.first_product_added_to_wishlist
        ,e.first_outlink_sent
        ,e.first_order_completed
        ,e.second_order_completed
      from(
        select
        distinct
          e.looker_visitor_id
          ,first_value(if(e.event = "product_added_to_wishlist",e.timestamp,null) ignore nulls) over (w) as first_product_added_to_wishlist
          ,first_value(if(e.event = "outlink_sent",e.timestamp,null) ignore nulls) over (w) as first_outlink_sent
          ,first_value(if(e.event = "order_completed",e.timestamp,null) ignore nulls) over (w) as first_order_completed
          ,nth_value(if(e.event = "order_completed",e.timestamp,null), 2 ignore nulls) over (w) as second_order_completed
        from ${event_facts.SQL_TABLE_NAME} e
        where e.event in ("product_added_to_wishlist","outlink_sent","order_completed")
        window w as (partition by e.looker_visitor_id order by e.timestamp rows between unbounded preceding and unbounded following)
      ) e
      left join(
        select
          id
          ,min(created_at) as signed_up
        from ${catch_users.SQL_TABLE_NAME}
        group by 1
      ) u on u.id=e.looker_visitor_id
      ;;
  }

#
#       select
#         e.looker_visitor_id
# --        ,min(e.timestamp) as first_date
# --        ,max(e.timestamp) as last_date
#         ,min(u.created_at) as signed_up
# --        ,min(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as first_product_added_to_wishlist
# --        ,max(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as last_product_added_to_wishlist
# --        ,count(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as number_of_product_added_to_wishlist
#         ,min(if(e.event = "outlink_sent",e.timestamp,null)) as first_outlink_sent
# --        ,max(if(e.event = "outlink_sent",e.timestamp,null)) as last_outlink_sent
# --        ,count(if(e.event = "outlink_sent",e.timestamp,null)) as number_of_outlink_sent
#         ,min(if(e.event = "order_completed",e.timestamp,null)) as first_order_completed
# --        ,max(if(e.event = "order_completed",e.timestamp,null)) as last_order_completed
# --        ,count(if(e.event = "order_completed",e.timestamp,null)) as number_of_order_completed
#       from ${event_facts.SQL_TABLE_NAME} e
#       left join ${catch_users.SQL_TABLE_NAME} as u on e.looker_visitor_id = u.id
#       where e.event in ("signed_up","outlink_sent","product_added_to_wishlist","order_completed")
#       group by 1

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
    primary_key: yes
  }



}
