view: event_facts_current {
  derived_table: {
    sql_trigger_value: select count(*) from ${sessions.SQL_TABLE_NAME} ;;
    sql:
      select
        t.event_id
        , es.session_id
        , j.journey_id
        , jg.journey_group_id
        , p.page_path_id
        , t.anonymous_id
        , t.looker_visitor_id
        , t.timestamp
        , t.event
        , t.event_source
        , t.referrer as referrer
        , t.campaign_source as campaign_source
        , t.campaign_medium as campaign_medium
        , t.campaign_name as campaign_name
        , t.campaign_content as campaign_content
        , t.campaign_term as campaign_term
        , t.ip as ip
        , t.page_url as url
        , t.page_path
        , coalesce(o.vendor, os.retailer) as vendor
        , o.total as order_value
        , es.event_sequence as event_sequence
        , es.source_sequence as source_sequence
        , s.first_referrer
        , s.first_source
        , s.first_medium
        , s.first_campaign
        , s.first_content
        , s.first_term
        , s.user_agent as user_agent
        , CASE
            WHEN s.user_agent LIKE '%Mobile%' THEN "Mobile"
            ELSE "Desktop" END as platform
        , CASE
            -- Discovery engaged for anyone started Discovery journey
            WHEN t.event in ("Search","Product Search", "Hashtag", "Category", "New", "Sale", "Brand") THEN "Discovery"
            -- Cashback engaged for anyone started Cashback related journey
            WHEN t.event in ("retailer_clicked", "About Cashback", "How to Cashback", "Cashback Retailer", "Retailer Coupon", "Promotions") THEN "Cashback"
            ELSE "Other"
          END as event_type
      from ${mapped_events.SQL_TABLE_NAME} as t
      left join ${event_sessions.SQL_TABLE_NAME} as es
        on t.event_id = es.event_id
        and t.looker_visitor_id = es.looker_visitor_id
      left join ${sessions.SQL_TABLE_NAME} as s
        on s.session_id = es.session_id
      left join ${journeys.SQL_TABLE_NAME} as j
        on j.session_id=es.session_id
        and es.event_sequence between j.first_journey_event_sequence and j.last_journey_event_sequence
      left join ${journey_groups.SQL_TABLE_NAME} as jg
        on jg.session_id=es.session_id
        and es.event_sequence between jg.first_journey_group_event_sequence and jg.last_journey_group_event_sequence
      left join ${page_path.SQL_TABLE_NAME} as p
        on p.session_id=es.session_id
        and es.event_sequence between p.first_page_path_event_sequence and p.last_page_path_event_sequence
      left join ${orders.SQL_TABLE_NAME} as o
        on t.looker_visitor_id = o.user_id
        and t.event_id=o.order_id
      left join javascript.outlink_sent_view as os
        on t.looker_visitor_id = os.user_id
        and t.event_id=os.id
      where t.timestamp >= CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS TIMESTAMP)
      ;;
  }
}
