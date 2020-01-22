view: duplicate_events_historical {
  derived_table: {
    sql_trigger_value: SELECT FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') ;;
    sql:
        SELECT
         id
        FROM (
            (SELECT
              t.id
              , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.event, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
            from javascript.tracks_view as t
            inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
              on a2v.alias = coalesce(t.user_id, t.anonymous_id)
            WHERE t.event NOT IN ("product_list_viewed", "experiment_viewed", "search_suggestion_viewed","product_clicked"))
            and t.timestamp < CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS TIMESTAMP)

          UNION ALL

            (SELECT
              t.id
              , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.name, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
            from javascript.pages_view as t
            inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
              on a2v.alias = coalesce(t.user_id, t.anonymous_id)
            where t.timestamp < CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS TIMESTAMP)
            )
          )

        WHERE time_sec < 2000
        ;;
  }

}
