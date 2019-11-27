view: search_suggestion_clicked {
  sql_table_name: javascript.search_suggestion_clicked_view ;;

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

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: list_id {
    type: string
    sql: ${TABLE}._id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: position {
    type: number
    sql: ${TABLE}.position ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
  }

  measure: average_character_count {
    type: average
    sql: length(${query}) ;;
    value_format_name: decimal_2
  }


}
