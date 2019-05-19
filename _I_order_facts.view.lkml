view: order_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${orders.SQL_TABLE_NAME} ;;
    sql: SELECT
        o.order_id
        , o.user_id
        , ef.session_id
        , ef.event_id
        , o.transaction_at
        , o.order_sequence_number
        , o.total
        , c.rate as cashback_rate
        , LEAD(o.transaction_at) OVER(partition by o.user_id ORDER BY o.transaction_at) as next_ordered
        , DATE_DIFF(CAST(o.transaction_at as DATE), CAST(LAG(o.transaction_at) over(partition by o.user_id ORDER BY o.transaction_at) AS DATE), DAY) as repurchase_gap
        , DATE_DIFF(CAST(MIN(o.transaction_at) OVER(partition by o.user_id) as DATE), CURRENT_DATE(), DAY) as days_since_first_order
        , SUM(c.amount) as total_cashback
      from ${orders.SQL_TABLE_NAME} as o
      LEFT JOIN ${event_facts.SQL_TABLE_NAME} as ef
      ON CONCAT(cast(o.transaction_at as string), o.user_id, '-r') = ef.event_id
      LEFT JOIN ${cashbacks.SQL_TABLE_NAME} as c
        ON o.order_id = c.order_id
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
    ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension_group: transaction_at {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.transaction_at ;;
  }

  dimension: cashback_rate {
    type: number
    sql: ${TABLE}.cashback_rate / 100 ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}.total ;;
  }

  dimension: total_cashback {
    type: number
    sql: ${TABLE}.total_cashback ;;
  }

  dimension: cashback_error_rate {
    type: number
    sql: ${total_cashback} / NULLIF((${total} * (${cashback_rate}) - 0.5), 0) - 1;;
  }

  dimension: is_cashback_correct {
    type: yesno
    sql: IF(${cashback_error_rate}  < 0.1 AND ${cashback_error_rate} > -0.1, true, false)  ;;
    }

  dimension_group: next_ordered {
    hidden: yes
    type: time
    sql: ${TABLE}.next_ordered ;;
  }

  dimension: is_sameday_repurcahse {
    type: yesno
    sql: IF(${repurchase_gap} < 1, true, false) ;;
  }

  dimension: repurchase_gap {
    type: number
    sql: ${TABLE}.repurchase_gap ;;
  }

  dimension: repurchase_tier {
    type: tier
    tiers: [30,60,90,120,150,180]
    style: integer
    sql: ${repurchase_gap} ;;
  }

  dimension:  is_repurchase{
    type: yesno
    hidden: yes
    sql: ${repurchase_gap} IS NOT NULL ;;
  }

  measure: count_repurchases {
    description: "Count of unique users who have made more than 1 purchase"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: is_repurchase
      value: "yes"
    }
  }

  ### Using an Average Distinct measure will get the average time it takes for a user to make a 2nd purchase
  ### and disregard duplicate users and subsequent orders
  measure: average_repurchase_gap {
    description: "The average time in days it takes for users to make a subsequent purchase"
    type: average_distinct
    sql: ${repurchase_gap} ;;
    sql_distinct_key: ${order_id} ;;
    filters: {
      field: order_sequence_number
      value: ">=2"
    }

  }

  ### These dimensions will check if a user's 2nd purchase was within certain time intervals
  dimension: repurchase_30  {type:yesno sql:${repurchase_gap} <=30 AND  ${order_sequence_number}=2;; hidden:yes}
  dimension: repurchase_60  {type:yesno sql:${repurchase_gap} <=60 AND  ${order_sequence_number}=2;; hidden:yes}
  dimension: repurchase_90  {type:yesno sql:${repurchase_gap} <=90 AND  ${order_sequence_number}=2;; hidden:yes}
  dimension: repurchase_120 {type:yesno sql:${repurchase_gap} <=120 AND ${order_sequence_number}=2;; hidden:yes}
  dimension: repurchase_150 {type:yesno sql:${repurchase_gap} <=150 AND ${order_sequence_number}=2;; hidden:yes}
  dimension: repurchase_180 {type:yesno sql:${repurchase_gap} <=180 AND ${order_sequence_number}=2;; hidden:yes}

  ### Count of repurchases by users in N days since first purchase
  measure: count_repurchases_first_30_days {
    label: "1m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_30
      value: "yes"
    }
  }
  measure: count_repurchases_first_60_days {
    label: "2m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_60
      value: "yes"
    }
  }
  measure: count_repurchases_first_90_days {
    label: "3m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_90
      value: "yes"
    }
  }
  measure: count_repurchases_first_120_days {
    label: "4m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_120
      value: "yes"
    }
  }
  measure: count_repurchases_first_150_days {
    label: "5m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_150
      value: "yes"
    }
  }
  measure: count_repurchases_first_180_days {
    label: "6m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: repurchase_180
      value: "yes"
    }
  }
  #### Repurchase rates

  measure: repurchase_rate {
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_30 {
    label: "1m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_30_days}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_60 {
    label: "2m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_60_days}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_90 {
    label: "3m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_90_days}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_120 {
    label: "4m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_120_days}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_150 {
    label: "5m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_150_days}/nullif(${count_customers},0) ;;
  }
  measure: repurchase_rate_180 {
    label: "6m"
    group_label: "Repurchase Rates"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_repurchases_first_180_days}/nullif(${count_customers},0) ;;
  }

  measure: count_customers {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: count_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

## Used for Cohort Analysis

  dimension_group: since_first_visit {
#     hidden: yes
    type: duration
    intervals: [day, week, month]
    sql_start: ${user_facts.first_visited_raw} ;;
    sql_end: ${transaction_at_raw} ;;
  }

#   dimension: days_since_signup {
#     hidden: yes
#     type: number
#     sql: DATEDIFF(${transaction_at_raw}, ${user_facts.signed_up});;
#   }
#
#   dimension: days_since_first_purchase {
#     hidden: yes
#     type: number
#     sql: DATEDIFF(${transaction_at_raw}, ${user_facts.first_purchased});;
#   }

  # dimension: weeks_since_first_visit {
  #   type: number
  #   sql: FLOOR(${days_since_first_visit}/(7)) ;;
  # }

  # dimension: months_since_first_visit {
  #   type: number
  #   sql: FLOOR(${days_since_first_visit}/(30)) ;;
  # }

  # dimension: months_since_first_visit_tier {
  #   type: tier
  #   tiers: [1,3,6,12,24]
  #   style: integer
  #   sql: ${months_since_first_visit} ;;
  # }
}
