view: dynamic_cohort_users {
  derived_table: {
    sql: SELECT
          DISTINCT uf.looker_visitor_id  AS user_id
          , true AS is_cohort

          FROM ${event_facts.SQL_TABLE_NAME} as ef
          LEFT JOIN ${user_facts.SQL_TABLE_NAME} as uf on ef.looker_visitor_id = uf.looker_visitor_id
          LEFT JOIN ${product_events.SQL_TABLE_NAME} as pe on ef.event_id = pe.event_id
          LEFT JOIN ${product_facts.SQL_TABLE_NAME} as pf on pe.product_id = pf.id
          LEFT JOIN ${orders.SQL_TABLE_NAME} as o on ef.looker_visitor_id = o.user_id and ef.event_id=o.order_id
          LEFT JOIN ${email_activity.SQL_TABLE_NAME} as ea on uf.email = ea.email

          WHERE ({% condition cohort_filter_event %} ef.event {% endcondition %})
            AND ({% condition cohort_filter_event_time %} ef.timestamp {% endcondition %} )

            -- session filters
            AND ({% condition cohort_filter_source %} ef.first_source {% endcondition %} )
            AND ({% condition cohort_filter_campaign %} ef.first_campaign {% endcondition %} )
            AND ({% condition cohort_filter_medium %} ef.first_medium {% endcondition %} )
            AND ({% condition cohort_filter_content %} ef.first_content {% endcondition %} )

            -- email filters
            AND ({% condition cohort_filter_email_campaign %} ea.marketing_campaign_name {% endcondition %} )
            AND ({% condition cohort_filter_email_event %} ea.event {% endcondition %})

            -- user filters
            AND ({% condition cohort_user_gender %} uf.gender {% endcondition %})
            AND ({% condition cohort_filter_signed_up_at %} uf.signed_up_date {% endcondition %} )
            AND ({% condition cohort_filter_users_first_source %} uf.first_source {% endcondition %} )
            AND ({% condition cohort_filter_users_type %} uf.user_type {% endcondition %} )

            -- order filters
            AND ({% condition cohort_filter_transaction_at %} o.transaction_at {% endcondition %})
          GROUP BY 1;;
  }

  dimension: user_id {
    hidden: yes
    description: "Unique ID for each user that has ordered"
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: is_cohort {
    type: yesno
    sql: ${TABLE}.is_cohort ;;
  }

  filter: cohort_filter_event {
    description: "Event to filter cohort"
    type: string
    suggest_explore: event_list
    suggest_dimension: event_list.event_types
  }

  filter: cohort_filter_event_time {
    description: "Time to filter cohort"
    type: date_time
  }

  filter: cohort_filter_source {
    description: "Source to filter cohort"
    type: string
    group_label: "Acquisition Filters"
    suggest_explore: event_facts
    suggest_dimension: session_facts.first_source
  }

  filter: cohort_filter_campaign {
    description: "Campaign to filter cohort"
    type: string
    group_label: "Acquisition Filters"
    suggest_explore: event_facts
    suggest_dimension: session_facts.first_campaign
  }

  filter: cohort_filter_medium {
    description: "Medium to filter cohort"
    type: string
    group_label: "Acquisition Filters"
    suggest_explore: event_facts
    suggest_dimension: session_facts.first_medium
  }

  filter: cohort_filter_content {
    description: "Medium to filter cohort"
    type: string
    group_label: "Acquisition Filters"
    suggest_explore: event_facts
    suggest_dimension: session_facts.first_content
  }

  filter: cohort_filter_email_campaign {
    description: "Email to filter cohort"
    type: string
    group_label: "Email Filters"
    suggest_explore: event_facts
    suggest_dimension: email_activity.marketing_campaign_name
  }

  filter: cohort_filter_email_event {
    description: "Email to filter cohort"
    type: string
    group_label: "Email Filters"
    suggest_explore: event_facts
    suggest_dimension: email_activity.event
  }

  filter: cohort_filter_signed_up_at {
    description: "Only users signed up at"
    type: date_time
    suggest_explore: event_facts
    suggest_dimension: user_facts.signed_up_date
  }

  filter: cohort_is_user {
    description: "Signed up only to filter cohort"
    type: yesno
  }

  filter: cohort_user_gender {
    description: "Gender to filter cohort"
    group_label: "User Filters"
    type: string
    suggest_explore: event_facts
    suggest_dimension: user_facts.gender
  }

  filter: cohort_user_first_purchased {
    description: "First purchased date to filter cohort"
    group_label: "User Filters"
    type: date_time
  }

  filter: cohort_user_joined {
    description: "Sign up date to filter cohort"
    group_label: "User Filters"
    type: date_time
  }

  filter: cohort_filter_users_first_source {
    description: "Signed up only to filter cohort"
    type: string
    suggest_explore: event_facts
    suggest_dimension: user_facts.first_source
  }

  filter: cohort_filter_users_type {
    description: "User Type to filter cohort"
    type: string
    suggest_explore: event_facts
    suggest_dimension: user_facts.user_type
  }



  filter: cohort_filter_product_id {
    description: "Product ID to filter cohort"
    type: string
    group_label: "Product Filters"
    suggest_explore: products
    suggest_dimension: products.sku
  }

  filter: cohort_filter_product_name {
    description: "Product Name to filter cohort"
    type: string
    group_label: "Product Filters"
    suggest_explore: products
    suggest_dimension: products.item_name
  }

  filter: cohort_filter_brand_name {
    description: "Brand Name to filter cohort"
    type: string
    group_label: "Product Filters"
    suggest_explore: products
    suggest_dimension: products.brand_name
  }


  filter: cohort_filter_transaction_at {
    description: "Made Purchase At"
    type: date
#     group_label: "Order Filters"
  }
}
