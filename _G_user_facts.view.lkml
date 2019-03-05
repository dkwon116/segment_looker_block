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
        , us.first_source as first_source
        , us.first_medium as first_medium
        , us.first_campaign as first_campaign
        , cu.id as is_user
        , MIN(s.session_start_at) as first_date
        , MAX(s.session_start_at) as last_date
--        , MIN(o.transaction_at) as first_purchased
--        , SUM(o.total ) as total_purchased
        , COUNT(*) as number_of_sessions
        , SUM(sf.count_product_viewed) as products_viewed
        , SUM(sf.count_order_completed) as orders_completed

      FROM ${sessions.SQL_TABLE_NAME} as s
      LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
        ON s.session_id = sf.session_id
      LEFT JOIN user_sources as us
        ON s.looker_visitor_id = us.looker_visitor_id
      LEFT JOIN mysql_smile_ventures.users as cu
        ON s.looker_visitor_id = cu.id
--      LEFT JOIN ${orders.SQL_TABLE_NAME} as o
--        ON s.looker_visitor_id = o.user_id
      GROUP BY 1,2,3,4,5
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

  dimension: is_user {
    type: yesno
    sql: ${TABLE}.is_user IS NOT NULL ;;
  }

  dimension: is_user_id {
    type: string
    sql: ${TABLE}.is_user ;;
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
    timeframes: [date, week, month]
    sql: ${TABLE}.first_date ;;
  }

  dimension_group: last_visited {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.last_date ;;
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
    timeframes: [time, date, week, month]
    sql: ${TABLE}.first_purchased ;;
  }

  dimension: time_to_purchased {
#     type:
  }

  dimension: total_purchased {
    type: number
    sql: ${TABLE}.total_purchased ;;
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
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
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
