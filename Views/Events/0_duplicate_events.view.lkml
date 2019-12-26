view: duplicate_events {
  derived_table: {
    # combine track and pages event into single table
    sql_trigger_value: select count(*) from javascript.tracks_view ;;
    sql:  SELECT
             id
            FROM (
                (SELECT
                  t.id
                  , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.event, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
                from javascript.tracks_view as t
                inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
                  on a2v.alias = coalesce(t.user_id, t.anonymous_id)
                WHERE t.event NOT IN ("product_list_viewed", "experiment_viewed", "search_suggestion_viewed","product_clicked"))

              UNION ALL

                (SELECT
                  t.id
                  , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.name, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
                from javascript.pages_view as t
                inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
                  on a2v.alias = coalesce(t.user_id, t.anonymous_id)
                )
              )

            WHERE time_sec < 2000
    ;;
  }
}
