view: first_events {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        e.looker_visitor_id
        ,min(e.timestamp) as first_date
        ,max(e.timestamp) as last_date
        ,min(if(e.event = "signed_up",e.timestamp,null)) as first_signed_up
        ,min(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as first_product_added_to_wishlist
        ,max(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as last_product_added_to_wishlist
        ,count(if(e.event = "product_added_to_wishlist",e.timestamp,null)) as number_of_product_added_to_wishlist
        ,min(if(e.event = "outlink_sent",e.timestamp,null)) as first_outlink_sent
        ,max(if(e.event = "outlink_sent",e.timestamp,null)) as last_outlink_sent
        ,count(if(e.event = "outlink_sent",e.timestamp,null)) as number_of_outlink_sent
        ,min(if(e.event = "order_completed",e.timestamp,null)) as first_order_completed
        ,max(if(e.event = "order_completed",e.timestamp,null)) as last_order_completed
        ,count(if(e.event = "order_completed",e.timestamp,null)) as number_of_order_completed
      from ${event_facts.SQL_TABLE_NAME} e
      where e.event in ("signed_up","outlink_sent","product_added_to_wishlist","order_completed")
      group by 1
      ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
    primary_key: yes
  }



}
