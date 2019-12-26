view: retailer_clicked {
  sql_table_name: javascript.retailer_clicked_view ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: event {
    type: string
    hidden: yes
    sql: ${TABLE}.event ;;
  }

  dimension: path_type {
    type: string
    sql: ${TABLE}.path_type ;;
  }

  dimension: retailer {
    type: string
    sql: ${TABLE}.retailer ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

}
