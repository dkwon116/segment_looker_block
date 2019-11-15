view: product_searched {
  sql_table_name: javascript.product_searched_view ;;

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

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: query {
    type: string
    sql: ${TABLE}.query ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: product_count {
    type: number
    sql: ${TABLE}.count ;;
  }


  measure: count{
    type: count
    filters: {
      field: event
      value: "product_searched"
    }
  }

  measure: no_result_count {
    type: count
    filters: {
      field: product_count
      value: "0"
    }
  }

  measure: no_result_rate {
    type: number
    sql: ${no_result_count} / nullif(${count},0) ;;
    value_format_name: percent_1
  }

  measure: avg_products_in_result {
    type: average
    sql: ${product_count} ;;
  }
}
