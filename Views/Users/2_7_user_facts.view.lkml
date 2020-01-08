view: user_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      WITH
      all_users as (
        SELECT s.looker_visitor_id as user_id FROM ${sessions.SQL_TABLE_NAME} as s
        UNION DISTINCT
        SELECT cu.id as user_id FROM aurora_smile_ventures.users as cu
      )
      ,user_attribution_first as (
        SELECT
          s.looker_visitor_id
          ,s.first_referrer
          ,s.first_source
          ,s.first_medium
          ,s.first_campaign
          ,s.first_content
          ,s.first_term
        FROM ${sessions.SQL_TABLE_NAME} as s
        WHERE s.session_sequence_number=1
      )
      ,user_attribution_signup as (
        SELECT
          s.looker_visitor_id
          ,s.first_referrer as signup_referrer
          ,s.first_source as signup_source
          ,s.first_medium as signup_medium
          ,s.first_campaign as signup_campaign
          ,s.first_content as signup_content
          ,s.first_term as signup_term
        FROM ${sessions.SQL_TABLE_NAME} as s
        JOIN(
          SELECT
            s.looker_visitor_id
            , MIN(s.session_sequence_number) AS session_sequence_number
          FROM ${sessions.SQL_TABLE_NAME} as s
          LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf ON s.session_id = sf.session_id
          WHERE sf.number_of_signed_up_events>0
          GROUP BY 1
        ) u on u.looker_visitor_id=s.looker_visitor_id and u.session_sequence_number=s.session_sequence_number
      )

      SELECT
        au.user_id as looker_visitor_id
        , cu.first_name as name
        , cu.email as email
        , if(
          starts_with(regexp_replace(cu.phone, '[^0-9]',''),'8210'),
          concat('010',substr(regexp_replace(cu.phone, '[^0-9]',''),5)),
          regexp_replace(cu.phone, '[^0-9]','')
          ) as phone
        , cu.terms_accepted as terms_accepted
        , uf.first_source as first_source
        , uf.first_medium as first_medium
        , uf.first_campaign as first_campaign
        , uf.first_content as first_content
        , uf.first_term as first_term
        , uf.first_referrer as first_referrer
        , us.signup_source as signup_source
        , us.signup_medium as signup_medium
        , us.signup_campaign as signup_campaign
        , us.signup_content as signup_content
        , us.signup_term as signup_term
        , us.signup_referrer as signup_referrer
        , cu.id as is_user
        , cu.gender as gender
        , cu.created_at as signed_up_date
        , IF(DATE(cu.created_at) < DATE(2018,11,20), "Giveaway", "Beta") as joined_at
        , ui.random_idx
        , IF(au.user_id IN (SELECT oi.user_id FROM ${order_items.SQL_TABLE_NAME} as oi  WHERE oi.quantity >= 3), "VIP", "Customer") as user_type
        , COALESCE(ui.first_date, cu.created_at) as first_date
        , ui.last_date
        , ui.number_of_sessions
        , ui.first_purchased
        , ui.last_purchased
        , ui.products_viewed
        , ui.number_of_outlinks
        , ui.orders_completed
        , ui.lifetime_order_value
        , ui.purchased_vendors
        , ub.brand_name as favorite_brand
        , ub.count_orders as favorite_brand_order_products

        ,case
          when cu.created_at is null then 'S2CON'
          when ifnull(ui.orders_completed,0)=0 and ifnull(ui.number_of_outlinks,0)=0 and cu.created_at is not null then 'S3ACT'
          when ifnull(ui.orders_completed,0)=0 and ifnull(ui.number_of_outlinks,0)>0 and cu.created_at is not null then 'S4ABD'
          when ifnull(ui.orders_completed,0)=1 then 'S5RET'
          when ifnull(ui.orders_completed,0)>1 then 'S6RCM'
          else null
        end as segment_stage
--        ,if(cu.created_at is null,null,if(date_diff(current_date, date(ui.last_date), day)<=30,'active','churn')) as segment_active
        ,if(date_diff(current_date, date(ui.last_date), day)<=30,'active','churn') as segment_active
        ,if(cu.created_at is null,null,if(date_diff(current_date, date(cu.created_at), day)<=30,'new','existing')) as segment_new

      FROM all_users as au
      LEFT JOIN aurora_smile_ventures.users as cu ON au.user_id = cu.id
      LEFT JOIN user_attribution_first as uf ON au.user_id = uf.looker_visitor_id
      LEFT JOIN user_attribution_signup as us ON au.user_id = us.looker_visitor_id
      LEFT JOIN(
        SELECT
          au.user_id as looker_visitor_id
          , sr.custom_fields_random_index as random_idx
          , ARRAY_TO_STRING(ARRAY_AGG(distinct o2.vendor ignore nulls), "-") as purchased_vendors
          , MIN(s.session_start_at) as first_date
          , MAX(s.session_start_at) as last_date
          , COUNT(s.session_id) as number_of_sessions
          , MIN(o.transaction_at) as first_purchased
          , MAX(o.transaction_at) as last_purchased
          , SUM(sf.count_product_viewed) as products_viewed
          , SUM(sf.count_outlinked) as number_of_outlinks
          , COUNT(o.order_id) as orders_completed
          , SUM(o.total) as lifetime_order_value
        FROM all_users as au
        LEFT JOIN aurora_smile_ventures.users as cu ON au.user_id = cu.id
        LEFT JOIN ${sessions.SQL_TABLE_NAME} as s ON au.user_id = s.looker_visitor_id
        LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf ON s.session_id = sf.session_id
        LEFT JOIN ${order_facts.SQL_TABLE_NAME} as o ON s.session_id = o.session_id
        LEFT JOIN ${orders.SQL_TABLE_NAME} as o2 ON o.order_id = o2.order_id
        LEFT JOIN google_sheets.user_type as ut ON cu.id = ut.user_id
        LEFT JOIN sendgrid.recipients_view as sr ON cu.email = sr.email
      GROUP BY 1,2
      ) ui on ui.looker_visitor_id=au.user_id
      LEFT JOIN(
        select
          distinct
          t.user_id
          ,first_value(t.brand_name) over (w) as brand_name
          ,first_value(t.unique_products) over (w) as count_orders
        from(
          select
            o.user_id
            ,pf.brand_name
            ,count(distinct pf.id) as unique_products
          from ${order_items.SQL_TABLE_NAME} o
          join ${product_maps.SQL_TABLE_NAME} pm on o.vendor_product_id =pm.affiliate_product_id and o.vendor_slug = pm.vendor
          join ${product_facts.SQL_TABLE_NAME} pf on pf.id=pm.id
          group by 1,2
        ) t
        window w as (partition by t.user_id order by t.unique_products desc rows between unbounded preceding and unbounded following)
      ) ub on ub.user_id=au.user_id
    ;;
  }
#
#       ,user_attribution as (
#         SELECT
#         distinct
#           s.looker_visitor_id
#           , first_value(s.first_referrer IGNORE NULLS) over(w) as first_referrer
#           , first_value(s.first_source IGNORE NULLS) over(w) as first_source
#           , first_value(s.first_medium IGNORE NULLS) over(w) as first_medium
#           , first_value(s.first_campaign IGNORE NULLS) over(w) as first_campaign
#           , first_value(s.first_content IGNORE NULLS) over(w) as first_content
#           , first_value(s.first_term IGNORE NULLS) over(w) as first_term
#           , last_value(s.last_referrer IGNORE NULLS) over(w) as last_referrer
#           , last_value(s.last_source IGNORE NULLS) over(w) as last_source
#           , last_value(s.last_medium IGNORE NULLS) over(w) as last_medium
#           , last_value(s.last_campaign IGNORE NULLS) over(w) as last_campaign
#           , last_value(s.last_content IGNORE NULLS) over(w) as last_content
#           , last_value(s.last_term IGNORE NULLS) over(w) as last_term
#           , first_value(if(sf.number_of_signed_up_events>0,s.first_source,null) IGNORE NULLS) over(w) as signup_source
#           , first_value(if(sf.number_of_signed_up_events>0,s.first_medium,null) IGNORE NULLS) over(w) as signup_medium
#           , first_value(if(sf.number_of_signed_up_events>0,s.first_campaign,null) IGNORE NULLS) over(w) as signup_campaign
#           , first_value(if(sf.number_of_signed_up_events>0,s.first_content,null) IGNORE NULLS) over(w) as signup_content
#           , first_value(if(sf.number_of_signed_up_events>0,s.first_term,null) IGNORE NULLS) over(w) as signup_term
#         FROM ${sessions.SQL_TABLE_NAME} as s
#         LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
#         ON s.session_id = sf.session_id
#         window w as (partition by s.looker_visitor_id order by s.session_start_at rows between unbounded preceding and unbounded following)
#       )





# WITH user_attribution as (
#   SELECT
#   distinct
#     s.looker_visitor_id
#     , first_value(s.first_referrer IGNORE NULLS) over(w) as first_referrer
#     , first_value(s.first_source IGNORE NULLS) over(w) as first_source
#     , first_value(s.first_medium IGNORE NULLS) over(w) as first_medium
#     , first_value(s.first_campaign IGNORE NULLS) over(w) as first_campaign
#     , first_value(s.first_content IGNORE NULLS) over(w) as first_content
#     , first_value(s.first_term IGNORE NULLS) over(w) as first_term
#     , last_value(s.last_referrer IGNORE NULLS) over(w) as last_referrer
#     , last_value(s.last_source IGNORE NULLS) over(w) as last_source
#     , last_value(s.last_medium IGNORE NULLS) over(w) as last_medium
#     , last_value(s.last_campaign IGNORE NULLS) over(w) as last_campaign
#     , last_value(s.last_content IGNORE NULLS) over(w) as last_content
#     , last_value(s.last_term IGNORE NULLS) over(w) as last_term
#     , first_value(if(sf.number_of_signed_up_events>0,s.first_source,null) IGNORE NULLS) over(w) as signup_source
#     , first_value(if(sf.number_of_signed_up_events>0,s.first_medium,null) IGNORE NULLS) over(w) as signup_medium
#     , first_value(if(sf.number_of_signed_up_events>0,s.first_campaign,null) IGNORE NULLS) over(w) as signup_campaign
#     , first_value(if(sf.number_of_signed_up_events>0,s.first_content,null) IGNORE NULLS) over(w) as signup_content
#     , first_value(if(sf.number_of_signed_up_events>0,s.first_term,null) IGNORE NULLS) over(w) as signup_term
#   FROM ${sessions.SQL_TABLE_NAME} as s
#   LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
#   ON s.session_id = sf.session_id
#   window w as (partition by s.looker_visitor_id order by s.session_start_at rows between unbounded preceding and unbounded following)
# )
# , all_users as (
#   SELECT
#   s.looker_visitor_id as user_id
#   FROM ${sessions.SQL_TABLE_NAME} as s
#
#   UNION DISTINCT
#
#   SELECT
#   cu.id as user_id
#   FROM aurora_smile_ventures.users as cu
# )
# SELECT
#   au.user_id as looker_visitor_id
#   , cu.first_name as name
#   , cu.email as email
#   , us.first_source as first_source
#   , us.first_medium as first_medium
#   , us.first_campaign as first_campaign
#   , us.first_content as first_content
#   , us.first_term as first_term
#   , us.first_referrer as first_referrer
#   , us.signup_source as signup_source
#   , us.signup_medium as signup_medium
#   , us.signup_campaign as signup_campaign
#   , us.signup_content as signup_content
#   , us.signup_term as signup_term
#   , cu.id as is_user
#   , cu.gender as gender
#   , cu.created_at as signed_up_date
#   , sr.custom_fields_random_index as random_idx
#   , IF(au.user_id IN (SELECT oi.user_id FROM ${order_items.SQL_TABLE_NAME} as oi  WHERE oi.quantity >= 3), "VIP", "Customer") as user_type
#   , IF(DATE(cu.created_at) < DATE(2018,11,20), "Giveaway", "Beta") as joined_at
#   , COALESCE(MIN(s.session_start_at), cu.created_at) as first_date
#   , ARRAY_TO_STRING(ARRAY_AGG(distinct o2.vendor ignore nulls), "-") as purchased_vendors
#   , MAX(s.session_start_at) as last_date
#   , COUNT(s.session_id) as number_of_sessions
#   , MIN(o.transaction_at) as first_purchased
#   , MAX(o.transaction_at) as last_purchased
#   , SUM(sf.count_product_viewed) as products_viewed
#   , SUM(sf.count_outlinked) as number_of_outlinks
#   , COUNT(o.order_id) as orders_completed
#   , SUM(o.total) as lifetime_order_value
# FROM all_users as au
# LEFT JOIN aurora_smile_ventures.users as cu
#   ON au.user_id = cu.id
# LEFT JOIN user_attribution as us
#   ON au.user_id = us.looker_visitor_id
# LEFT JOIN ${sessions.SQL_TABLE_NAME} as s
#   ON au.user_id = s.looker_visitor_id
# LEFT JOIN ${session_facts.SQL_TABLE_NAME} as sf
#   ON s.session_id = sf.session_id
# LEFT JOIN ${order_facts.SQL_TABLE_NAME} as o
#   ON s.session_id = o.session_id
# LEFT JOIN ${orders.SQL_TABLE_NAME} as o2
#   ON o.order_id = o2.order_id
# LEFT JOIN google_sheets.user_type as ut
#   ON cu.id = ut.user_id
# LEFT JOIN sendgrid.recipients_view as sr
#   ON cu.email = sr.email
# GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20



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

  dimension: phone {
    group_label: "Info"
    type: string
    sql: ${TABLE}.phone;;
  }

  dimension: terms_accepted {
    type: yesno
    sql: ${TABLE}.terms_accepted ;;
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
    timeframes: [time, date, week, month, quarter, raw]
    sql: ${TABLE}.first_date ;;
  }

  dimension_group: last_visited {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.last_date ;;
  }

  dimension_group: signed_up {
    type: time
    timeframes: [time, date, week, month, quarter, raw]
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
    timeframes: [time, date, week, day_of_week, month, quarter, day_of_month, raw]
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

  dimension: favorite_brand {
    type: string
    sql: ${TABLE}.favorite_brand ;;
  }

  dimension: favorite_brand_order_products {
    type: number
    sql: ${TABLE}.favorite_brand_order_products ;;
  }


  dimension: first_type {
    type: string
    sql:
        case
          when
            (${first_source} IN ('sendgrid','sweet','transactional'))
            or (${first_source} is null)
            or (${first_medium} IN ('message','email','lms'))
          then 'direct'
          else 'campaign'
        end
    ;;
    group_label: "Acquisition"
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

  dimension: first_keyword {
    type: string
    sql: if(${TABLE}.first_medium = "blog-seo", split(${first_term}, "-")[OFFSET(1)], "-") ;;
    group_label: "Acquisition"
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

  dimension: segment_stage {
    type: string
    sql: ${TABLE}.segment_stage ;;
    group_label: "UserSegment"
  }

  dimension: segment_active {
    type: string
    sql: ${TABLE}.segment_active ;;
    group_label: "UserSegment"
  }

  dimension: segment_new {
    type: string
    sql: ${TABLE}.segment_new ;;
    group_label: "UserSegment"
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

  measure: total_order_value {
    type: sum
    sql: ${lifetime_order_value} ;;
    value_format_name: decimal_0
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
    default_value: "first_purchased"

  }

  parameter: cohort_time {
    type: string
    allowed_value: {
      label: "Month"
      value: "month"
    }
    allowed_value: {
      label: "Quarter"
      value: "quarter"
    }
    default_value: "quarter"
  }

  dimension: cohort_by {
    label_from_parameter: cohort_type
#     type: date_month_num
    sql:
      CASE
        WHEN {% parameter cohort_type %} = 'first_visited' THEN
          if({% parameter cohort_time %} = 'month', ${first_visited_month}, ${first_visited_quarter})
        WHEN {% parameter cohort_type %} = 'signed_up' THEN
          if({% parameter cohort_time %} = 'month', ${signed_up_month}, ${signed_up_quarter})
        WHEN {% parameter cohort_type %} = 'first_purchased' THEN
          if({% parameter cohort_time %} = 'month', ${first_purchased_month}, ${first_purchased_quarter})
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
