view: tracks_sanitized {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from javascript.tracks_view ;;
    sql:  SELECT *
          FROM javascript.tracks_view
          WHERE id NOT IN

            (SELECT
              id
            FROM (
              SELECT
                t.id
                , row_number() over (partition by t.context_page_path order by t.timestamp) as first_url
                , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path order by t.timestamp), MILLISECOND) as time_sec
              from javascript.tracks_view as t
              inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
              on a2v.alias = coalesce(t.user_id, t.anonymous_id)
              WHERE t.event = "product_viewed")
            WHERE
              time_sec < 5000)
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: context_campaign_content {
    type: string
    sql: ${TABLE}.context_campaign_content ;;
  }

  dimension: context_campaign_medium {
    type: string
    sql: ${TABLE}.context_campaign_medium ;;
  }

  dimension: context_campaign_name {
    type: string
    sql: ${TABLE}.context_campaign_name ;;
  }

  dimension: context_campaign_source {
    type: string
    sql: ${TABLE}.context_campaign_source ;;
  }

  dimension: context_campaign_term {
    type: string
    sql: ${TABLE}.context_campaign_term ;;
  }

  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_library_name {
    type: string
    sql: ${TABLE}.context_library_name ;;
  }

  dimension: context_library_version {
    type: string
    sql: ${TABLE}.context_library_version ;;
  }

  dimension: context_page_path {
    type: string
    sql: ${TABLE}.context_page_path ;;
  }

  dimension: context_page_referrer {
    type: string
    sql: ${TABLE}.context_page_referrer ;;
  }

  dimension: context_page_search {
    type: string
    sql: ${TABLE}.context_page_search ;;
  }

  dimension: context_page_title {
    type: string
    sql: ${TABLE}.context_page_title ;;
  }

  dimension: context_page_url {
    type: string
    sql: ${TABLE}.context_page_url ;;
  }

  dimension: context_user_agent {
    type: string
    sql: ${TABLE}.context_user_agent ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: event_text {
    type: string
    sql: ${TABLE}.event_text ;;
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension_group: loaded_at {
    type: time
    sql: ${TABLE}.loaded_at ;;
  }

  dimension_group: original_timestamp {
    type: time
    sql: ${TABLE}.original_timestamp ;;
  }

  dimension_group: received_at {
    type: time
    sql: ${TABLE}.received_at ;;
  }

  dimension_group: sent_at {
    type: time
    sql: ${TABLE}.sent_at ;;
  }

  dimension_group: timestamp {
    type: time
    sql: ${TABLE}.timestamp ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: uuid_ts {
    type: time
    sql: ${TABLE}.uuid_ts ;;
  }

  dimension: context_google_analytics_client_id {
    type: string
    sql: ${TABLE}.context_google_analytics_client_id ;;
  }

  dimension: context_campaign_contents {
    type: string
    sql: ${TABLE}.context_campaign_contents ;;
  }

  set: detail {
    fields: [
      anonymous_id,
      context_campaign_content,
      context_campaign_medium,
      context_campaign_name,
      context_campaign_source,
      context_campaign_term,
      context_ip,
      context_library_name,
      context_library_version,
      context_page_path,
      context_page_referrer,
      context_page_search,
      context_page_title,
      context_page_url,
      context_user_agent,
      event,
      event_text,
      id,
      loaded_at_time,
      original_timestamp_time,
      received_at_time,
      sent_at_time,
      timestamp_time,
      user_id,
      uuid_ts_time,
      context_google_analytics_client_id,
      context_campaign_contents
    ]
  }
}
