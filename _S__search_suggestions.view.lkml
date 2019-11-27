
view: search_suggestions {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.search_suggestion_viewed_view ;;
    sql:
        (select
          s.id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,s.event
          ,s.gender
          ,s.query
          ,s.type
          ,s._id as list_id
          ,s.name as category
          ,s.position
        from ${search_suggestion_clicked.SQL_TABLE_NAME} as s
        join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v on a2v.alias = s.anonymous_id
        )

        union all

        (select
          s.id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,s.event
          ,s.gender
          ,s.query
          ,s.suggestion_type as type
          ,s.suggestion_id as list_id
          ,s.suggestion_name as category
          ,cast(s.suggestion_position as int64) as position
        from ${search_suggestion_viewed_in_list.SQL_TABLE_NAME} as s
        join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v on a2v.alias = s.anonymous_id
        )
          ;;
  }


  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: event {
    type: string
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
    sql: ${TABLE}.list_id ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: position {
    type: number
    sql: ${TABLE}.position ;;
  }
  dimension: query_length {
    type: number
    sql: length(${query}) ;;
  }

  measure: view_count {
    type: count
#     sql: ${id} ;;
    filters: {
      field: event
      value: "search_suggestion_viewed"
    }
  }

  measure: unique_suggestion_view_count {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: event
      value: "search_suggestion_viewed"
    }
  }

  measure: click_count {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: event
      value: "search_suggestion_clicked"
    }
  }

  measure: avg_typed_to_click {
    type: average
    sql: length(${query}) ;;
    filters: {
      field: event
      value: "search_suggestion_clicked"
    }
    value_format_name: decimal_2
  }

  measure: avg_category_length {
    type: average
    sql: length(${category}) ;;
    filters: {
      field: event
      value: "search_suggestion_clicked"
    }
    value_format_name: decimal_2
  }

  measure: avg_position_to_click {
    type: average
    sql: ${position} ;;
    filters: {
      field: event
      value: "search_suggestion_clicked"
    }
    value_format_name: decimal_2
  }

  measure: suggestion_ctr {
    description: "Suggestion clicked per all possible suggestions"
    type: number
    sql: ${click_count}/nullif(${view_count},0) ;;
    value_format_name: percent_0
  }

  measure: suggestion_view_ctr {
    description: "Suggestion clicked per list of suggestion viewed"
    type: number
    sql: ${click_count}/nullif(${unique_suggestion_view_count},0) ;;
    value_format_name: percent_0
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${event_facts.looker_visitor_id} ;;
  }


}
