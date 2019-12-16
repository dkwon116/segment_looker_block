view: general_utm_list {
  derived_table: {
    sql_trigger_value: select count(*) from google_sheets.general_utm_list ;;
    sql:
  SELECT
    _row
    ,title
    ,ad_id
    ,spend
    ,landing_url
    ,replace(source," ","") as source
    ,replace(medium," ","") as medium
    ,replace(campaign," ","") as campaign
    ,replace(content," ","") as content
    ,replace(term," ","") as term
    ,length
    ,short_url
    ,replace(utm," ","") as utm
  from google_sheets.general_utm_list
  where utm is not null
    ;;
  }


  dimension: ad_id {
    type: string
    sql: ${TABLE}.ad_id ;;
  }
  dimension: spend {
    type: number
    sql: ${TABLE}.spend ;;
  }
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

}
