# - explore: mapped_events
view: mapped_events {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from ${page_aliases_mapping.SQL_TABLE_NAME} ;;
    sql: select *
        ,timestamp_diff(timestamp, lag(timestamp) over(partition by looker_visitor_id order by timestamp), minute) as idle_time_minutes
      from (
        select CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-t') as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          ,t.event as event
          ,t.received_at as received
          ,NULL as referrer
          ,NULL as campaign_source
          ,NULL as campaign_medium
          ,NULL as campaign_name
          ,t.context_user_agent as user_agent
          ,'tracks' as event_source
        from javascript.tracks_view as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
        on a2v.alias = coalesce(t.user_id, t.anonymous_id)

        union all

        select CONCAT(cast(t.timestamp AS string), t.anonymous_id, '-p') as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          ,t.name as event
          ,t.received_at as received
          ,t.referrer as referrer
          ,t.context_campaign_source as campaign_source
          ,t.context_campaign_medium as campaign_medium
          ,t.context_campaign_name as campaign_name
          ,t.context_user_agent as user_agent
          ,'pages' as event_source
        from javascript.pages_view as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
          on a2v.alias = coalesce(t.user_id, t.anonymous_id)
      ) as e
       ;;
  }

  dimension: event_id {
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
