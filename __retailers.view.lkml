view: retailers {
  derived_table: {
      sql_trigger_value: SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'US/Pacific') ;;
      sql:
        SELECT e.advertiser_id as vendor_id
          , o.vendor as name
        FROM mysql_smile_ventures.rakuten_events as e
        LEFT JOIN mysql_smile_ventures.rakuten_orders as o
          ON e.id = o.rakuten_event_id
        WHERE o.vendor IS NOT NULL
        GROUP BY 1, 2
      ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
}
