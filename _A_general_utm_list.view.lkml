view: general_utm_list {
  sql_table_name: google_sheets.general_utm_list;;


  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }
  dimension: medium {
    type: string
    sql: ${TABLE}.medium ;;
  }
  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }
  dimension: content {
    type: string
    sql: ${TABLE}.content ;;
  }
  dimension: term {
    type: string
    sql: ${TABLE}.term ;;
  }
  dimension: utm {
    type: string
    sql: concat(${TABLE}.source,",",${TABLE}.medium,",",${TABLE}.campaign,",",${TABLE}.term) ;;
  }
  dimension: ad_id {
    type: string
    sql: ${TABLE}.ad_id ;;
  }
}
