view: user_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      WITH user_attribution as (
        SELECT * FROM
          (SELECT
            s.looker_visitor_id
            , first_value(sf.first_source IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_source
            , first_value(sf.first_medium IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_medium
            , first_value(sf.first_campaign IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_campaign
            , first_value(sf.first_referrer IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_referrer
            , first_value(sf.first_content IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_content
            , first_value(sf.first_term IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as first_term
            , last_value(sf.first_source IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_source
            , last_value(sf.first_medium IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_medium
            , last_value(sf.first_campaign IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_campaign
            , last_value(sf.first_content IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_content
            , last_value(sf.first_term IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.session_id rows between unbounded preceding and unbounded following) as last_term
            , first_value(sf.first_source IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.number_of_signed_up_events desc rows between unbounded preceding and unbounded following) as signup_source
            , first_value(sf.first_medium IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.number_of_signed_up_events desc rows between unbounded preceding and unbounded following) as signup_medium
            , first_value(sf.first_campaign IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.number_of_signed_up_events desc rows between unbounded preceding and unbounded following) as signup_campaign
            , first_value(sf.first_content IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.number_of_signed_up_events desc rows between unbounded preceding and unbounded following) as signup_content
            , first_value(sf.first_term IGNORE NULLS) over(partition by s.looker_visitor_id order by sf.number_of_signed_up_events desc rows between unbounded preceding and unbounded following) as signup_term
          FROM ${sessions.SQL_TABLE_NAME} as s
          LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
          ON s.session_id = sf.session_id) as source
        group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
      ), all_users as (
        SELECT
          s.looker_visitor_id as user_id
        FROM ${sessions.SQL_TABLE_NAME} as s

        UNION DISTINCT

        SELECT
          cu.id as user_id
        FROM mysql_smile_ventures.users as cu
      )
      SELECT
        au.user_id as looker_visitor_id
        , cu.first_name as name
        , cu.email as email
        , us.first_source as first_source
        , us.first_medium as first_medium
        , us.first_campaign as first_campaign
        , us.first_content as first_content
        , us.first_term as first_term
        , us.first_referrer as first_referrer
        , us.signup_source as signup_source
        , us.signup_medium as signup_medium
        , us.signup_campaign as signup_campaign
        , us.signup_content as signup_content
        , us.signup_term as signup_term
        , cu.id as is_user
        , cu.gender as gender
        , cu.created_at as signed_up_date
        , sr.custom_fields_random_index as random_idx
        , IF(au.user_id IN (SELECT oi.user_id FROM ${order_items.SQL_TABLE_NAME} as oi  WHERE oi.quantity >= 3), "VIP", "Customer") as user_type
        , IF(DATE(cu.created_at) < DATE(2018,11,20), "Giveaway", "Beta") as joined_at
        , COALESCE(MIN(s.session_start_at), cu.created_at) as first_date
        , ARRAY_TO_STRING(ARRAY_AGG(distinct o2.vendor ignore nulls), "-") as purchased_vendors
        , MAX(s.session_start_at) as last_date
        , COUNT(s.session_id) as number_of_sessions
        , MIN(o.transaction_at) as first_purchased
        , MAX(o.transaction_at) as last_purchased
        , SUM(sf.count_product_viewed) as products_viewed
        , SUM(sf.count_outlinked) as number_of_outlinks
        , COUNT(o.order_id) as orders_completed
        , SUM(o.total) as lifetime_order_value

      FROM all_users as au
      LEFT JOIN mysql_smile_ventures.users as cu
        ON au.user_id = cu.id
      LEFT JOIN user_attribution as us
        ON au.user_id = us.looker_visitor_id
      LEFT JOIN ${sessions.SQL_TABLE_NAME} as s
        ON au.user_id = s.looker_visitor_id
      LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
        ON s.session_id = sf.session_id
      LEFT JOIN ${order_facts.SQL_TABLE_NAME} as o
        ON s.session_id = o.session_id
      LEFT JOIN ${orders.SQL_TABLE_NAME} as o2
        ON o.order_id = o2.order_id
      LEFT JOIN google_sheets.user_type as ut
        ON cu.id = ut.user_id
      LEFT JOIN sendgrid.recipients_view as sr
        ON cu.email = sr.email
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

       ;;
  }

  #     Define your dimensions and measures here, like this:
  dimension: looker_visitor_id {
#     hidden: yes
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
    hidden: yes
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: is_user {
    type: yesno
    sql: ${TABLE}.is_user IS NOT NULL ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: is_user_id {
    type: string
    sql: ${TABLE}.is_user ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
    group_label: "Info"
  }

  dimension: number_of_sessions {
    type: number
    sql: ${TABLE}.number_of_sessions ;;
    group_label: "Total Events"
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
    group_label: "Total Events"
  }

  dimension: joined_at {
    type: string
    sql: ${TABLE}.joined_at ;;
  }

  dimension: purchased_vendor {
    type: string
    sql: ${TABLE}.purchased_vendors ;;
  }

  dimension_group: first_visited {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.first_date ;;
  }

  dimension_group: last_visited {
    type: time
    timeframes: [time, date, week, month, year]
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
    group_label: "Total Events"
  }

  dimension: orders_completed {
    type: number
    sql: ${TABLE}.orders_completed ;;
    group_label: "Total Events"
  }

  dimension: number_of_outlinks {
    type: number
    sql: ${TABLE}.number_of_outlinks ;;
    group_label: "Total Events"
  }

  dimension_group: first_purchased {
    type: time
    timeframes: [time, date, week, day_of_week, month, day_of_month, raw]
    sql: ${TABLE}.first_purchased ;;
  }

  dimension_group: last_purchased {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.last_purchased ;;
  }

  dimension: time_to_signup {
    type: number
    sql:  timestamp_diff(${signed_up_raw}, ${first_visited_raw}, day) ;;
    group_label: "Time to"
  }

  dimension_group: since_signup_to_purchased {
#     hidden: yes
    type: duration
    intervals: [day, week, month]
    sql_start:  ${signed_up_raw};;
    sql_end: ${first_purchased_raw} ;;
  }

  dimension: days_to_purchased {
    alias: [time_to_purchased]
    type: number
    sql:  timestamp_diff(${first_purchased_raw}, ${first_visited_raw}, day) ;;
    group_label: "Time to"
  }

  dimension: days_to_signup_to_purchased {
    type: number
    sql:  timestamp_diff(${first_purchased_raw}, ${signed_up_raw}, day) ;;
    group_label: "Time to"
  }

  dimension: lifetime_order_value {
    type: number
    sql: ${TABLE}.lifetime_order_value ;;
    value_format_name: decimal_0
  }

  dimension: is_purchased {
    type: yesno
    sql: IF(${orders_completed} > 0, true, false) ;;
  }

  dimension: first_source {
    type: string
    sql: ${TABLE}.first_source ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_source
  }

  dimension: first_source_sanitized {
    type: string
    sql: CASE
      WHEN ${first_source} IS NULL OR ${first_source} IN ("transactional", "email", "sms", "newsletter", "sendgrid", "sweet", "kakao") THEN
        (CASE
          WHEN ${first_referrer} LIKE "%google%" THEN "Google - Direct"
          WHEN ${first_referrer} LIKE "%naver%" THEN "Naver - Direct"
          WHEN ${first_referrer} LIKE "%facebook%" THEN "Facebook - Direct"
          WHEN ${first_referrer} LIKE "%instagram%" THEN "Instagram - Direct"
          ELSE "Other - Direct" END)
      WHEN ${first_source} in ("facebook", "Facebook", "facebook-network") THEN "facebook"
      ELSE ${first_source} END
      ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_source
  }

  dimension: first_medium {
    type: string
    sql: ${TABLE}.first_medium ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_medium
  }

  dimension: first_campaign {
    type: string
    sql: ${TABLE}.first_campaign ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_name
  }

  dimension: first_content {
    type: string
    sql: ${TABLE}.first_content ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_content
  }

  dimension: first_term {
    type: string
    sql: ${TABLE}.first_term ;;
    group_label: "Acquisition"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_term
  }

  dimension: signup_source {
    type: string
    sql: ${TABLE}.signup_source ;;
    group_label: "Signup"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_source
  }

  dimension: signup_medium {
    type: string
    sql: ${TABLE}.signup_medium ;;
    group_label: "Signup"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_medium
  }

  dimension: signup_campaign {
    type: string
    sql: ${TABLE}.signup_campaign ;;
    group_label: "Signup"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_name
  }

  dimension: signup_content {
    type: string
    sql: ${TABLE}.signup_content ;;
    group_label: "Signup"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_content
  }

  dimension: signup_term {
    type: string
    sql: ${TABLE}.signup_term ;;
    group_label: "Signup"
    suggest_explore: utm_values
    suggest_dimension: utm_values.campaign_term
  }

  dimension: first_referrer {
    type: string
    sql: ${TABLE}.first_referrer ;;
    group_label: "Acquisition"
  }

  dimension: first_referrer_domain {
    type: string
    sql: NET.REG_DOMAIN(${first_referrer}) ;;
    group_label: "Acquisition"
  }

  measure: total_visitors {
    description: "total unique visitors"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
  }

  measure: total_users {
    description: "total unique visitors who signed up"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: is_user
      value: "Yes"
    }
  }

  measure: total_outlinked_users {
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: is_user
      value: "Yes"
    }
    filters: {
      field: number_of_outlinks
      value: ">0"
    }
  }

  measure: total_customer {
    description: "total unique users who made purchase"
    type: count_distinct
    sql: ${looker_visitor_id} ;;
    filters: {
      field: is_purchased
      value: "Yes"
    }
  }

  measure: activation_rate {
    description: "% of users who made purchase"
    type: number
    sql: ${total_customer} / NULLIF(${total_users}, 0) ;;
    value_format_name: percent_0
  }


#   visitors (not signed up)
#   users (signed up)
#   users (signed up, outlinked)
#   customers (purchased)


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
    sql: ${days_to_purchased} ;;
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

  measure: average_orders {
    type: average
    sql: ${orders_completed} ;;
    filters: {
      field: orders_completed
      value: ">0"
    }
  }

  parameter: cohort_type {
    type: string
    allowed_value: {
      label: "First Visited"
      value: "first_visited"
    }
    allowed_value: {
      label: "Signed Up"
      value: "signed_up"
    }
    allowed_value: {
      label: "First Purchased"
      value: "first_purchased"
    }
  }

  dimension: cohort_by {
    label_from_parameter: cohort_type
#     type: date_month_num
    sql:
      CASE
        WHEN {% parameter cohort_type %} = 'first_visited' THEN
          ${first_visited_month}
        WHEN {% parameter cohort_type %} = 'signed_up' THEN
          ${signed_up_month}
        WHEN {% parameter cohort_type %} = 'first_purchased' THEN
          ${first_purchased_month}
        ELSE
          NULL
      END ;;
  }

  set: user_details {
    fields: [looker_visitor_id, name, number_of_sessions, time_to_signup, days_to_purchased]
  }


  dimension: 201908_email_target {
    sql: CASE
          WHEN ${TABLE}.random_idx < 0.7 THEN "Target"
          WHEN ${TABLE}.random_idx < 1 THEN "Control"
          ELSE "None" END;;
    type: string
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
