view: search_suggestion_viewed {
  sql_table_name: javascript.search_suggestion_viewed_view ;;

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

  dimension: suggestions {
    type: string
    sql: ${TABLE}.suggestions ;;
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

}
