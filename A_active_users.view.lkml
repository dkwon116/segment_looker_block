view: dates {
  derived_table: {
    sql_trigger_value: SELECT CURRENT_DATE() ;;
    sql:
      SELECT cast(date as date) as date
      FROM UNNEST(GENERATE_DATE_ARRAY(DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR), CURRENT_DATE)) date;;
  }
}

view: active_users {
  derived_table: {
    sql_trigger_value: SELECT CURRENT_DATE();;

    sql: WITH daily_use AS (
        SELECT
          e.looker_visitor_id as user_id
          , cast(TIMESTAMP_TRUNC(e.timestamp, day) as date) as activity_date
        FROM ${mapped_events.SQL_TABLE_NAME} as e
        GROUP BY 1, 2
      )

      SELECT
            daily_use.user_id as user_id
          , wd.date as date
          , MIN( DATE_DIFF(wd.date, daily_use.activity_date, day) ) as days_since_last_action
      FROM ${dates.SQL_TABLE_NAME} AS wd
      CROSS JOIN daily_use
        WHERE wd.date BETWEEN daily_use.activity_date AND DATE_ADD(daily_use.activity_date, INTERVAL 30 DAY)
      GROUP BY 1,2
       ;;
  }

  dimension_group: date {
    type: time
    timeframes: [date, month, quarter, quarter_of_year, year, raw]
    sql: CAST( ${TABLE}.date AS TIMESTAMP);;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: days_since_last_action {
    type: number
    sql: ${TABLE}.days_since_last_action ;;
    value_format_name: decimal_0
  }

  dimension: active_this_day {
    type: yesno
    sql: ${days_since_last_action} <  1 ;;
  }

  dimension: active_last_7_days {
    type: yesno
    sql: ${days_since_last_action} < 7 ;;
  }

  dimension: is_last_30_days {
    type: yesno
    sql: timestamp_diff(CURRENT_TIMESTAMP, ${date_raw}, day) < 30  ;;
  }

  measure: user_count_active_30_days {
    label: "Monthly Active Users"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [user_id, users.id, users.name]
  }

  measure: user_count_active_this_day {
    label: "Daily Active Users"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [user_id, users.id, users.name]

    filters: {
      field: active_this_day
      value: "yes"
    }
  }

  measure: user_count_active_7_days {
    label: "Weekly Active Users"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [user_id, users.id, users.name]

    filters: {
      field: active_last_7_days
      value: "yes"
    }
  }
}
