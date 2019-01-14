view: weekly_activities {
  derived_table: {
    sql_trigger_value: select current_date() ;;
#     sortkeys: ["signup_month"]
    distribution: "user_id"
    sql: SELECT
                u.looker_visitor_id as user_id
              , cast(TIMESTAMP_TRUNC (u.first_visited, week) as date) as first_week
              , week_list.product_view_week as product_view_week
              , COALESCE(data.weekly_views, 0) as weekly_views
              , row_number() over() AS key
            FROM
              user_facts as u

            LEFT JOIN

              (
                SELECT
                  DISTINCT(cast(TIMESTAMP_TRUNC (e.timestamp, week) as date) as product_view_week
                FROM ${mapped_events.SQL_TABLE_NAME} as e
                WHERE e.event = "Product"
              ) as week_list
            ON week_list.product_view_week >= cast(TIMESTAMP_TRUNC (u.first_week, week) as date)

            LEFT JOIN

              (
                SELECT
                      me.looker_visitor_id as user_id
                    , cast(TIMESTAMP_TRUNC (me.timestamp, week) as date) as product_view_week
                    , COUNT(distinct me.id) AS weekly_views
                FROM ${mapped_events.SQL_TABLE_NAME} as me
                WHERE me.event = "Product"
                GROUP BY 1,2
              ) as data
            ON data.product_view_week = week_list.product_view_week
            AND data.user_id = u.user_id
             ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_visit {
    type: time
    timeframes: [week]
    sql: ${TABLE}.first_week ;;
  }

  dimension_group: product_view {
    type: time
    timeframes: [week]
    sql: ${TABLE}.product_view_week ;;
  }

  dimension: months_since_first_visit {
    type: number
    sql: datediff('month', ${TABLE}.first_week, ${TABLE}.product_view_week) ;;
  }

  dimension: weekly_views {
    type: number
    sql: ${TABLE}.weekly_views ;;
  }

#   dimension: monthly_spend {
#     type: number
#     sql: ${TABLE}.monthly_spend ;;
#   }

  measure: total_users {
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [users.id, users.age, users.name, user_order_facts.lifetime_orders]
  }

  measure: total_active_users {
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [users.id, users.age, users.name, user_order_facts.lifetime_orders]

    filters: {
      field: weekly_views
      value: ">0"
    }
  }

  measure: percent_of_cohort_active {
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${total_active_users} / nullif(${total_users},0) ;;
    drill_fields: [user_id, weekly_views]
  }

#   measure: total_amount_spent {
#     type: sum
#     value_format_name: usd
#     sql: ${monthly_spend} ;;
#     drill_fields: [detail*]
#   }

#   measure: spend_per_user {
#     type: number
#     value_format_name: usd
#     sql: ${total_amount_spent} / nullif(${total_users},0) ;;
#     drill_fields: [user_id, monthly_purchases, total_amount_spent]
#   }
#
#   measure: spend_per_active_user {
#     type: number
#     value_format_name: usd
#     sql: ${total_amount_spent} / nullif(${total_active_users},0) ;;
#     drill_fields: [user_id, total_amount_spent]
#   }

  dimension: key {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.key ;;
  }

  set: detail {
    fields: [user_id, first_visit_week, weekly_views]
  }
}
