view: retailers {
  derived_table: {
      sql_trigger_value: SELECT count(*) from google_sheets.retailers ;;
      sql:
        SELECT r.mid as vendor_id
          , r.partnerize_id as partnerize_id
          , r.retailer_list as name
        FROM google_sheets.retailers as r
        WHERE r._fivetran_deleted = false
      ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: partnerize_id {
    type: string
    sql: ${TABLE}.partnerize_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
}
