view: campaign_session_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
       (
        select
          sessions.last_utm
          ,s.session_id
          ,s.looker_visitor_id

          ,null as marketing_campaign_id
          ,'session' as event

          ,s.session_start_at as timestamp
          ,s.session_duration_minutes

          ,s.is_guest_at_session
          ,s.is_pre_outlinked_at_session
          ,s.is_pre_purchase_at_session

          ,s.count_engaged
          ,s.count_discovery_engaged
          ,s.count_cashback_engaged

          ,s.count_product_list_viewed
          ,s.count_product_viewed
          ,s.number_of_signed_up_events
          ,s.count_outlinked
          ,s.count_concierge_clicked
          ,s.count_added_to_wishlist

          ,s.count_order_completed
          ,s.order_value

        from ${sessions.SQL_TABLE_NAME} AS sessions
        join ${session_facts.SQL_TABLE_NAME} AS s ON s.session_id = sessions.session_id
        where sessions.last_utm is not null
      )
      union all
      (
        select
          c.utm as last_utm
          ,null as session_id
          ,e.looker_visitor_id

          ,e.marketing_campaign_id
          ,e.event

          ,TIMESTAMP_SECONDS(e.timestamp) as timestamp
          ,null as session_duration_minutes

          ,null as is_guest_at_session
          ,null as is_pre_outlinked_at_session
          ,null as is_pre_purchase_at_session

          ,null as count_engaged
          ,null as count_discovery_engaged
          ,null as count_cashback_engaged

          ,null as count_product_list_viewed
          ,null as count_product_viewed
          ,null as number_of_signed_up_events
          ,null as count_outlinked
          ,null as count_concierge_clicked
          ,null as count_added_to_wishlist

          ,null as count_order_completed
          ,null as order_value

        from ${email_activity.SQL_TABLE_NAME} e
        join ${email_campaigns.SQL_TABLE_NAME} c on c.marketing_campaign_id=e.marketing_campaign_id
        where e.event<>'deferred'
      )
    ;;

  }



  dimension: utm {
    type: string
    sql: ${TABLE}.last_utm ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: looker_visitor_id {
    type: string
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: marketing_campaign_id {
    type: string
    sql: ${TABLE}.marketing_campaign_id ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension_group: start {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.timestamp ;;
  }
  dimension: session_duration_minutes {
    type: number
    sql: ${TABLE}.session_duration_minutes ;;
  }

  dimension: is_guest_at_session {
    group_label: "Session Flags"
    type: yesno
    sql: ${TABLE}.is_guest_at_session ;;
  }
  dimension: is_pre_purchase_at_session {
    type: yesno
    sql: ${TABLE}.is_pre_purchase_at_session ;;
    group_label: "Session Flags"
  }
  dimension: is_pre_outlinked_at_session {
    type: yesno
    sql: ${TABLE}.is_pre_outlinked_at_session ;;
    group_label: "Session Flags"
  }



  dimension: engaged {
    type: number
    sql: ${TABLE}.count_engaged ;;
    group_label: "Event Counts"
  }
  dimension: product_discovery {
    type: number
    sql: ${TABLE}.count_discovery_engaged ;;
    group_label: "Event Counts"
    description: "Viewed Search, Category, Brand, Hashtag, New, Sale Product List"
  }
  dimension: cashback_engaged {
    type: number
    sql: ${TABLE}.count_cashback_engaged ;;
    group_label: "Event Counts"
    description: "Viewed Cashback related pages"
  }

  dimension: product_lists_viewed {
    type: number
    sql: ${TABLE}.count_product_list_viewed ;;
    group_label: "Event Counts"
  }
  dimension: products_viewed {
    type: number
    sql: ${TABLE}.count_product_viewed ;;
    group_label: "Event Counts"
  }
  dimension: number_of_signed_up_events {
    type:  number
    sql: ${TABLE}.number_of_signed_up_events ;;
    group_label: "Event Counts"
  }
  dimension: outlinked {
    type: number
    sql: ${TABLE}.count_outlinked ;;
    group_label: "Event Counts"
  }
  dimension: concierge_clicked {
    type: number
    sql: ${TABLE}.count_concierge_clicked ;;
    group_label: "Event Counts"
  }
  dimension: added_to_wishlist {
    type: number
    sql: ${TABLE}.count_added_to_wishlist ;;
    group_label: "Event Counts"
  }

  dimension: order_completed {
    type: number
    sql: ${TABLE}.count_order_completed ;;
    group_label: "Event Counts"
  }
  dimension: order_value {
    type: number
    sql: ${TABLE}.order_value ;;
    value_format_name: decimal_0
    group_label: "Event Counts"
  }


#Campaign Facts
  measure: count_delivered {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "delivered"
    }
  }
  measure: count_open {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "open"
    }
  }
  measure: conversion_open {
    type: number
    sql:  ${count_open}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }
  measure: count_click {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "click"
    }
  }
  measure: conversion_click {
    type: number
    sql:  ${count_click}/nullif(${count_open},0);;
    value_format_name: percent_1
  }


  measure: count_bounce {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "bounce"
    }
  }
  measure: conversion_bounce {
    type: number
    sql:  ${count_bounce}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }
  measure: count_dropped {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "dropped"
    }
  }
  measure: conversion_dropped {
    type: number
    sql:  ${count_dropped}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }
  measure: count_unsubscribe {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "unsubscribe"
    }
  }
  measure: conversion_unsubscribe {
    type: number
    sql:  ${count_unsubscribe}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }
  measure: count_spamreport {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "spamreport"
    }
  }
  measure: conversion_spamreport {
    type: number
    sql:  ${count_unsubscribe}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }

#Campaign Session Facts
  measure: count_campaign_session {
    type: count
    filters: {
      field: event
      value: "session"
    }
  }
  measure: count_campaign_visitor {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
  }

  measure: count_campaign_outlink_user {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: outlinked
      value: ">0"
    }
  }
  measure: conversion_campaign_outlink {
    type: number
    sql:  ${count_campaign_outlink_user}/nullif(${count_campaign_visitor},0);;
    value_format_name: percent_1
  }

  measure: count_campaign_order_user {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: order_completed
      value: ">0"
    }
  }
  measure: conversion_campaign_order {
    type: number
    sql:  ${count_campaign_order_user}/nullif(${count_campaign_visitor},0);;
    value_format_name: percent_1
  }
  measure: conversion_campaign_order_per_outlink {
    type: number
    sql:  ${count_campaign_order_user}/nullif(${count_campaign_outlink_user},0);;
    value_format_name: percent_1
  }
  measure: conversion_campaign_order_per_deliver {
    type: number
    sql:  ${count_campaign_order_user}/nullif(${count_delivered},0);;
    value_format_name: percent_1
  }

  measure: count_campaign_pre_purchase_visitor {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: is_pre_purchase_at_session
      value: "yes"
    }
  }
  measure: count_campaign_first_order_user {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: is_pre_purchase_at_session
      value: "yes"
    }
    filters: {
      field: order_completed
      value: ">0"
    }
  }
  measure: conversion_campaign_first_order {
    type: number
    sql:  ${count_campaign_first_order_user}/nullif(${count_campaign_pre_purchase_visitor},0);;
    value_format_name: percent_1
  }
  measure: ratio_first_order_user {
    type:  number
    sql:  ${count_campaign_first_order_user}/nullif(${count_campaign_order_user},0);;
    value_format_name: percent_1
  }

  measure: count_campaign_post_purchase_visitor {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: is_pre_purchase_at_session
      value: "no"
    }
  }
  measure: count_campaign_repeat_order_user {
    type: count_distinct
    sql:  concat(${utm},${looker_visitor_id});;
    filters: {
      field: event
      value: "session"
    }
    filters: {
      field: is_pre_purchase_at_session
      value: "no"
    }
    filters: {
      field: order_completed
      value: ">0"
    }
  }
  measure: conversion_campaign_repeat_order {
    type: number
    sql:  ${count_campaign_repeat_order_user}/nullif(${count_campaign_post_purchase_visitor},0);;
    value_format_name: percent_1
  }
  measure: ratio_repeat_order_user {
    type:  number
    sql:  ${count_campaign_repeat_order_user}/nullif(${count_campaign_order_user},0);;
    value_format_name: percent_1
  }

  measure: sum_order_value {
    type: sum
    sql:  ${order_value};;
    value_format_name: decimal_0
  }

  measure: sales_per_email {
    type:  number
    sql: ${sum_order_value}/nullif(${count_delivered},0) ;;
    value_format_name: decimal_3
  }
}
