view: duplicate_events_current {
  derived_table: {
    sql_trigger_value: select count(*) from ${page_aliases_mapping.SQL_TABLE_NAME} ;;
    sql:
SELECT id
FROM (
  (SELECT
    t.id
    , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.event, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
    , ROW_NUMBER() OVER (PARTITION BY id ORDER BY loaded_at DESC) AS __row_number

  from javascript.tracks as t
  inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v on a2v.alias = coalesce(t.user_id, t.anonymous_id)
  WHERE t.event NOT IN ("product_list_viewed", "experiment_viewed", "search_suggestion_viewed","product_clicked")
  and DATE(t._PARTITIONTIME) >= CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS DATE)
  )

  UNION ALL

  (SELECT
    t.id
    , timestamp_diff(timestamp, lag(timestamp) over (partition by t.context_page_path, t.name, t.anonymous_id order by t.timestamp), MILLISECOND) as time_sec
    , ROW_NUMBER() OVER (PARTITION BY id ORDER BY loaded_at DESC) AS __row_number
  from javascript.pages as t
  inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v on a2v.alias = coalesce(t.user_id, t.anonymous_id)
  where DATE(t._PARTITIONTIME) >= CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS DATE)
  )
)
WHERE (time_sec < 2000)
OR (__row_number > 1)
;;
  }

}
