view: retailers {
  derived_table: {
      sql_trigger_value: SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'US/Pacific') ;;
      sql:
        SELECT r.mid as vendor_id
          , r.retailer_list as name
        FROM google_sheets.retailers as r
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
