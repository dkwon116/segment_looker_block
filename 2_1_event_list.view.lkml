# Derived Table of Event Names used for Filter Suggestions

view: event_list {
  derived_table: {
    sql_trigger_value: SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'US/Pacific') ;;
    sql: SELECT
        event as event_types
      FROM ${mapped_events.SQL_TABLE_NAME}
      GROUP BY 1
       ;;
  }

  dimension: event_types {
    type: string
    sql: ${TABLE}.event_types ;;
  }
}

view: utm_values {
  derived_table: {
    sql_trigger_value: SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'US/Pacific') ;;
    sql: SELECT
          campaign_source
          , campaign_medium
          , campaign_name
          , campaign_content
          , campaign_term
      FROM ${mapped_events.SQL_TABLE_NAME}
      GROUP BY 1, 2, 3, 4, 5
       ;;
  }

  dimension: campaign_source {
    type: string
    sql: ${TABLE}.campaign_source ;;
  }

  dimension: campaign_medium {
    type: string
    sql: ${TABLE}.campaign_medium ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
  }

  dimension: campaign_content {
    type: string
    sql: ${TABLE}.campaign_content ;;
  }

  dimension: campaign_term {
    type: string
    sql: ${TABLE}.campaign_term ;;
  }
}
