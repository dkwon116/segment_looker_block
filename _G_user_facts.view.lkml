view: user_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      WITH user_sources as (
        SELECT * FROM
          (SELECT
            s.looker_visitor_id
            , first_value(sf.first_source) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_source
            , first_value(sf.first_medium) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_medium
            , first_value(sf.first_campaign) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_campaign
            , last_value(sf.first_source) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_source
            , last_value(sf.first_medium) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_medium
            , last_value(sf.first_campaign) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_campaign
          FROM ${sessions.SQL_TABLE_NAME} as s
          LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
          ON s.session_id = sf.session_id) as source
        group by 1, 2, 3, 4, 5, 6, 7
      )
      SELECT
        s.looker_visitor_id
        , cu.first_name as name
        , us.first_source as first_source
        , us.first_medium as first_medium
        , us.first_campaign as first_campaign
        , cu.id as is_user
        , cu.created_at as signed_up_date
        , COALESCE(ut.type,"Customer") as user_type
        , MIN(s.session_start_at) as first_date
        , MAX(s.session_start_at) as last_date
        , COUNT(s.session_id) as number_of_sessions
        , MIN(o.transaction_at) as first_purchased
        , SUM(sf.count_product_viewed) as products_viewed
        , COUNT(o.order_id) as orders_completed
        , SUM(o.total) as lifetime_order_value

      FROM mysql_smile_ventures.users as cu
      LEFT JOIN ${sessions.SQL_TABLE_NAME} as s
        ON cu.id = s.looker_visitor_id
      LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
        ON s.session_id = sf.session_id
      LEFT JOIN user_sources as us
        ON cu.id = us.looker_visitor_id
      LEFT JOIN ${order_facts.SQL_TABLE_NAME} as o
        ON s.session_id = o.session_id
      LEFT JOIN google_sheets.user_type as ut
        ON cu.id = ut.user_id
      GROUP BY 1,2,3,4,5,6,7,8

       ;;
  }

  #     Define your dimensions and measures here, like this:
  dimension: looker_visitor_id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.looker_visitor_id ;;
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/19?UserID= {{value | encode_url}}"
      icon_url: "https://looker.com/favicon.ico"
    }
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: is_user {
    type: yesno
    sql: ${TABLE}.is_user IS NOT NULL ;;
  }

  dimension: is_user_id {
    type: string
    sql: ${TABLE}.is_user ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
  }

  dimension: number_of_sessions {
    type: number
    sql: ${TABLE}.number_of_sessions ;;
  }

  dimension: number_of_sessions_tiered {
    type: tier
    sql: ${number_of_sessions} ;;
    tiers: [
      1,
      2,
      3,
      4,
      5,
      10
    ]
  }

  dimension_group: first_visited {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.first_date ;;
  }

  dimension_group: last_visited {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.last_date ;;
  }

  dimension_group: signed_up {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.signed_up_date ;;
  }

  dimension: products_viewed {
    type: number
    sql: ${TABLE}.products_viewed ;;
  }

  dimension: orders_completed {
    type: number
    sql: ${TABLE}.orders_completed ;;
  }

  dimension_group: first_purchased {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.first_purchased ;;
  }

  dimension: time_to_signup {
    type: number
    sql:  timestamp_diff(${signed_up_raw}, ${first_visited_raw}, day) ;;
  }

  dimension: time_to_purchased {
    type: number
    sql:  timestamp_diff(${first_purchased_raw}, ${first_visited_raw}, day) ;;
  }

  dimension: days_to_signup_to_purchased {
    type: number
    sql:  timestamp_diff(${first_purchased_raw}, ${signed_up_raw}, day) ;;
  }

  dimension: lifetime_order_value {
    type: number
    sql: ${TABLE}.lifetime_order_value ;;
  }

  dimension: is_purchased {
    type: yesno
    sql: IF(${orders_completed} > 0, true, false) ;;
  }

  dimension: first_source {
    type: string
    sql: ${TABLE}.first_source ;;
  }

  dimension: first_medium {
    type: string
    sql: ${TABLE}.first_medium ;;
  }

  dimension: first_campaign {
    type: string
    sql: ${TABLE}.first_campaign ;;
  }


  measure: total_users {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: average_time_to_signup {
    type: average
    sql: ${time_to_signup} ;;
    value_format_name: decimal_2
    drill_fields: [user_details*]
    filters: {
      field: time_to_signup
      value: ">=0"
    }
  }

  measure: average_time_to_purchase {
    type: average
    sql: ${time_to_purchased} ;;
    value_format_name: decimal_2
    drill_fields: [user_details*]
  }

  measure: average_days_signup_to_purchase {
    type: average
    sql: ${days_to_signup_to_purchased} ;;
    value_format_name: decimal_2
    drill_fields: [user_details*]
    filters: {
      field: time_to_signup
      value: ">=0"
    }
  }

  set: user_details {
    fields: [looker_visitor_id, name, number_of_sessions, time_to_signup, time_to_purchased]
  }
}

# view: _g_user_facts {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
