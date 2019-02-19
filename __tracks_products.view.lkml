view: _tracks_products {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from javascript.tracks_view ;;
    sql:
    select CONCAT(cast(u.timestamp AS string), u.anonymous_id, '-t') as event_id
      , u.product_id as product_id
      , u.event
    from (
      select d.timestamp, d.anonymous_id, d.product_id, d.event
      from javascript.product_viewed_view as d

      union all

      select w.timestamp, w.anonymous_id, w.product_id, w.event
      from javascript.product_added_to_wishlist_view as w

      union all

      select c.timestamp, c.anonymous_id, c.product_id, c.event
      from javascript.concierge_clicked_view as c

      union all

      select l.timestamp, l.anonymous_id, l.product_id, 'list_viewed' as event
      from ${products_viewed_in_list.SQL_TABLE_NAME} as l
    ) as u
    ;;
  }

  dimension: event_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.event_id ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  measure: count {
    type: count
  }
}
