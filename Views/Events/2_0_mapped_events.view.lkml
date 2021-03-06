# - explore: mapped_events
view: mapped_events {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from ${mapped_events_current.SQL_TABLE_NAME} ;;
    sql:

      select
        *
        , timestamp_diff(timestamp, lag(timestamp) over(partition by looker_visitor_id order by timestamp), minute) as idle_time_minutes
      from(
        (select * from ${mapped_events_current.SQL_TABLE_NAME})
        union all
        (select * from ${mapped_events_historical.SQL_TABLE_NAME})
      )

      -- select *
      --   ,timestamp_diff(timestamp, lag(timestamp) over(partition by looker_visitor_id order by timestamp), minute) as idle_time_minutes
      -- from (
      --   select
      --     t.id as event_id
      --     ,t.anonymous_id
      --     ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
      --     ,t.timestamp
      --     ,t.event as event
      --     ,t.received_at as received
      --     ,t.context_page_referrer as referrer
      --     ,t.context_campaign_source as campaign_source
      --     ,t.context_campaign_medium as campaign_medium
      --     ,t.context_campaign_name as campaign_name
      --     ,t.context_campaign_content as campaign_content
      --     ,t.context_campaign_term as campaign_term
      --     ,t.context_user_agent as user_agent
      --     ,t.context_page_url as page_url
      --     ,t.context_ip as ip
      --     ,'tracks' as event_source
      --     ,t.context_page_path AS page_path
      --   from javascript.tracks_view as t
      --   inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
      --   on a2v.alias = t.anonymous_id

      --   union all

      --   select
      --     t.id as event_id
      --     ,t.anonymous_id
      --     ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
      --     ,t.timestamp
      --     ,t.name as event
      --     ,t.received_at as received
      --     ,t.referrer as referrer
      --     ,t.context_campaign_source as campaign_source
      --     ,t.context_campaign_medium as campaign_medium
      --     ,t.context_campaign_name as campaign_name
      --     ,t.context_campaign_content as campaign_content
      --     ,t.context_campaign_term as campaign_term
      --     ,t.context_user_agent as user_agent
      --     ,t.context_page_url as page_url
      --     ,t.context_ip as ip
      --     ,'pages' as event_source
      --     ,t.context_page_path AS page_path
      --   from javascript.pages_view as t
      --   inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
      --     on a2v.alias = t.anonymous_id

      --   union all

      --   select
      --     t.order_id as event_id
      --     ,t.user_id as anonymous_id
      --     ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
      --     ,t.transaction_at as timestamp
      --     ,'order_completed' as event
      --     ,t.created_at as received
      --     ,null as referrer
      --     ,null as campaign_source
      --     ,null as campaign_medium
      --     ,null as campaign_name
      --     ,null as campaign_content
      --     ,null as campaign_term
      --     ,'' as user_agent
      --     ,'http://www.catchfashion.com' as page_url
      --     ,'' as ip
      --     ,'affiliate' as event_source
      --     ,'' AS page_path
      --   from ${orders.SQL_TABLE_NAME} as t
      --   inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
      --     on a2v.alias = t.user_id
      -- ) as e
      -- WHERE (e.ip NOT IN ('210.123.124.177', '222.106.98.162', '121.134.191.141', '63.118.26.234', '14.39.183.130', '125.140.120.54', '98.113.6.12', '221.149.2.114')
      -- AND e.page_url LIKE '%catchfashion%'
      -- AND e.page_url NOT LIKE '%staging%'
      -- AND e.user_agent NOT LIKE '%Bot%'
      -- AND e.event_id NOT IN (SELECT id FROM ${duplicate_events.SQL_TABLE_NAME})
      -- AND e.looker_visitor_id NOT IN (SELECT user_id FROM google_sheets.filter_user))
      -- AND e.looker_visitor_id NOT IN (
      --       select
      --         distinct id
      --       from javascript.users
      --       where context_ip IN ('210.123.124.177', '222.106.98.162', '121.134.191.141', '63.118.26.234', '14.39.183.130', '125.140.120.54', '98.113.6.12', '221.149.2.114', '59.10.186.201'))
       ;;
  }

  dimension: event_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: looker_visitor_id {
    sql: ${TABLE}.looker_visitor_id ;;
  }

  dimension: anonymous_id {
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension_group: received {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.received ;;
    hidden: yes
  }

  dimension: event {
    sql: ${TABLE}.event ;;
  }

  dimension: referrer {
    sql: ${TABLE}.referrer ;;
  }

  dimension: event_source {
    sql: ${TABLE}.event_source ;;
  }

  dimension: user_agent {
    sql: ${TABLE}.user_agent ;;
  }

  dimension: ip {
    sql: ${TABLE}.ip ;;
  }

  dimension: url {
    sql: ${TABLE}.page_url ;;
  }

  dimension: idle_time_minutes {
    type: number
    sql: ${TABLE}.idle_time_minutes ;;
  }

  set: detail {
    fields: [
      event_id,
      looker_visitor_id,
      referrer,
      event_source,
      idle_time_minutes
    ]
  }
}
