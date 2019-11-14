view: experiment_variant_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
    select
      e.*
      ,u.sessions_variance as session_per_user_variance
    from(
      SELECT
        experiment_facts.experiment_id  AS experiment_id,
        experiment_facts.experiment_name  AS experiment_name,
        experiment_sessions.variant_id  AS experiment_variant_id,
        COUNT(DISTINCT session_facts.session_id ) AS session_count,
        COUNT(DISTINCT session_facts.looker_visitor_id ) AS unique_visitor_count,
        COUNT(DISTINCT session_facts.session_id ) / NULLIF(COUNT(DISTINCT session_facts.looker_visitor_id ),0) AS session_per_user,
        COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE((timestamp_diff(TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_end_at , 'Asia/Seoul'))))), TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_start_at , 'Asia/Seoul'))))), minute)) ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) AS total_session_duration,
        COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE((timestamp_diff(TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_end_at , 'Asia/Seoul'))))), TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_start_at , 'Asia/Seoul'))))), minute)) ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) / NULLIF(COUNT(DISTINCT session_facts.session_id ),0) AS session_duration_minutes_per_session,
        COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE((timestamp_diff(TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_end_at , 'Asia/Seoul'))))), TIMESTAMP((FORMAT_TIMESTAMP('%F %T', TIMESTAMP(FORMAT_TIMESTAMP('%F %T', session_facts.session_start_at , 'Asia/Seoul'))))), minute)) ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(session_facts.session_id  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) / NULLIF(COUNT(DISTINCT session_facts.looker_visitor_id ),0) AS session_duration_minutes_per_user,
        COUNT(DISTINCT CASE WHEN session_facts.is_guest_at_session  THEN session_facts.looker_visitor_id  ELSE NULL END) AS unique_guest_count,
        COUNT(DISTINCT CASE WHEN (session_facts.number_of_signed_up_events  > 0) THEN session_facts.looker_visitor_id  ELSE NULL END) AS unique_signed_up_visitor,
        (COUNT(DISTINCT CASE WHEN (session_facts.number_of_signed_up_events  > 0) THEN session_facts.looker_visitor_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN session_facts.is_guest_at_session  THEN session_facts.looker_visitor_id  ELSE NULL END)),0) AS signedup_conversion,

        COUNT(DISTINCT CASE WHEN (session_facts.count_product_viewed  > 0) THEN session_facts.session_id  ELSE NULL END) AS total_product_viewed_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_product_viewed  > 0) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT session_facts.session_id )),0)  AS product_viewed_conversion_rate_by_session,
        sum(COALESCE(session_facts.count_product_viewed ,0)) as products_viewed_total,

        sum(COALESCE(session_facts.count_product_viewed ,0)) / NULLIF(COUNT(DISTINCT CASE WHEN (session_facts.count_product_viewed  > 0) THEN session_facts.session_id  ELSE NULL END),0) AS product_viewed_per_converted_session,
        var_samp(session_facts.count_product_viewed) as product_viewed_variance,

        COUNT(DISTINCT CASE WHEN (session_facts.count_added_to_wishlist  > 0) THEN session_facts.session_id  ELSE NULL END) AS total_added_to_wishlist_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_added_to_wishlist  > 0) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT session_facts.session_id )),0)  AS added_to_wishlist_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN (session_facts.count_concierge_clicked  > 0) THEN session_facts.session_id  ELSE NULL END) AS total_concierge_clicked_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_concierge_clicked  > 0) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT session_facts.session_id )),0)  AS concierge_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) THEN session_facts.session_id  ELSE NULL END) AS total_outlinked_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT session_facts.session_id )), 0)  AS outlinked_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN session_facts.is_pre_outlinked_at_session  THEN session_facts.session_id  ELSE NULL END) AS pre_outlinked_session_count,
        COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) AND session_facts.is_pre_outlinked_at_session THEN session_facts.session_id  ELSE NULL END) AS total_first_outlinked_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) AND session_facts.is_pre_outlinked_at_session THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN session_facts.is_pre_outlinked_at_session  THEN session_facts.session_id  ELSE NULL END)), 0)  AS first_outlinked_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN NOT COALESCE(session_facts.is_pre_outlinked_at_session , FALSE) THEN session_facts.session_id  ELSE NULL END) AS post_outlinked_session_count,
        COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) AND (NOT COALESCE(session_facts.is_pre_outlinked_at_session , FALSE)) THEN session_facts.session_id  ELSE NULL END) AS total_repeat_outlinked_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_outlinked  > 0) AND (NOT COALESCE(session_facts.is_pre_outlinked_at_session , FALSE)) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN NOT COALESCE(session_facts.is_pre_outlinked_at_session , FALSE) THEN session_facts.session_id  ELSE NULL END)), 0)  AS repeat_outlinked_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) THEN session_facts.session_id  ELSE NULL END) AS total_order_completed_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT session_facts.session_id )),0)  AS order_completed_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN session_facts.is_pre_purchase_at_session  THEN session_facts.session_id  ELSE NULL END) AS pre_purchase_session_count,
        COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) AND session_facts.is_pre_purchase_at_session THEN session_facts.session_id  ELSE NULL END) AS total_first_order_completed_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) AND session_facts.is_pre_purchase_at_session THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN session_facts.is_pre_purchase_at_session  THEN session_facts.session_id  ELSE NULL END)),0)  AS first_order_completed_conversion_rate_by_session,
        COUNT(DISTINCT CASE WHEN NOT COALESCE(session_facts.is_pre_purchase_at_session , FALSE) THEN session_facts.session_id  ELSE NULL END) AS post_purchase_session_count,
        COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) AND (NOT COALESCE(session_facts.is_pre_purchase_at_session , FALSE)) THEN session_facts.session_id  ELSE NULL END) AS total_repeat_order_completed_sessions,
        (COUNT(DISTINCT CASE WHEN (session_facts.count_order_completed  > 0) AND (NOT COALESCE(session_facts.is_pre_purchase_at_session , FALSE)) THEN session_facts.session_id  ELSE NULL END)) / NULLIF((COUNT(DISTINCT CASE WHEN NOT COALESCE(session_facts.is_pre_purchase_at_session , FALSE) THEN session_facts.session_id  ELSE NULL END)),0)  AS repeat_order_completed_conversion_rate_by_session
      FROM ${session_facts.SQL_TABLE_NAME} AS session_facts
      JOIN ${experiment_sessions.SQL_TABLE_NAME} AS experiment_sessions ON session_facts.session_id = experiment_sessions.session_id
      JOIN ${experiment_facts.SQL_TABLE_NAME} AS experiment_facts ON experiment_sessions.experiment_id =  experiment_facts.experiment_id
      WHERE (session_facts.session_start_at BETWEEN experiment_facts.experiment_start_at AND experiment_facts.experiment_end_at)
      GROUP BY 1,2,3
    ) e
    join ${experiment_user_session_facts.SQL_TABLE_NAME} u on u.experiment_id=e.experiment_id and u.variant_id=e.experiment_variant_id
      ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
    link: {
      label: "Go to dashboard"
      url: "https://smileventures.au.looker.com/dashboards/68?Experiment%20ID={{value | encode_url}}"
    }
  }
  dimension: experiment_name {
    type: string
    sql: ${TABLE}.experiment_name ;;
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/68?Experiment%20Name={{value | encode_url}}"
    }
  }
  dimension: experiment_variant_id {
    type: string
    sql: ${TABLE}.experiment_variant_id ;;
  }
  measure:session_count{
    type: sum
    sql: ${TABLE}.session_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:unique_visitor_count{
    type: sum
    sql: ${TABLE}.unique_visitor_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:session_per_user{
    type: sum
    sql: ${TABLE}.session_per_user ;;
    group_label: "Experiment Variant Facts"
  }
  measure:session_per_user_variance{
    type: sum
    sql: ${TABLE}.session_per_user_variance ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_session_duration{
    type: sum
    sql: ${TABLE}.total_session_duration ;;
    group_label: "Experiment Variant Facts"
  }
  measure:session_duration_minutes_per_session{
    type: sum
    sql: ${TABLE}.session_duration_minutes_per_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:session_duration_minutes_per_user{
    type: sum
    sql: ${TABLE}.session_duration_minutes_per_user ;;
    group_label: "Experiment Variant Facts"
  }
  measure:unique_guest_count{
    type: sum
    sql: ${TABLE}.unique_guest_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:unique_signed_up_visitor{
    type: sum
    sql: ${TABLE}.unique_signed_up_visitor ;;
    group_label: "Experiment Variant Facts"
  }
  measure:signedup_conversion{
    type: sum
    sql: ${TABLE}.signedup_conversion ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_product_viewed_sessions{
    type: sum
    sql: ${TABLE}.total_product_viewed_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:product_viewed_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.product_viewed_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:products_viewed_total{
    type: sum
    sql: ${TABLE}.products_viewed_total ;;
    group_label: "Experiment Variant Facts"
  }
  measure:product_viewed_per_converted_session{
    type: sum
    sql: ${TABLE}.product_viewed_per_converted_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:product_viewed_variance{
    type: sum
    sql: ${TABLE}.product_viewed_variance ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_added_to_wishlist_sessions{
    type: sum
    sql: ${TABLE}.total_added_to_wishlist_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:added_to_wishlist_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.added_to_wishlist_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_concierge_clicked_sessions{
    type: sum
    sql: ${TABLE}.total_concierge_clicked_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:concierge_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.concierge_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_outlinked_sessions{
    type: sum
    sql: ${TABLE}.total_outlinked_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:outlinked_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.outlinked_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:pre_outlinked_session_count{
    type: sum
    sql: ${TABLE}.pre_outlinked_session_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_first_outlinked_sessions{
    type: sum
    sql: ${TABLE}.total_first_outlinked_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:first_outlinked_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.first_outlinked_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:post_outlinked_session_count{
    type: sum
    sql: ${TABLE}.post_outlinked_session_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_repeat_outlinked_sessions{
    type: sum
    sql: ${TABLE}.total_repeat_outlinked_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:repeat_outlinked_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.repeat_outlinked_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_order_completed_sessions{
    type: sum
    sql: ${TABLE}.total_order_completed_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:order_completed_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.order_completed_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:pre_purchase_session_count{
    type: sum
    sql: ${TABLE}.pre_purchase_session_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_first_order_completed_sessions{
    type: sum
    sql: ${TABLE}.total_first_order_completed_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:first_order_completed_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.first_order_completed_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }
  measure:post_purchase_session_count{
    type: sum
    sql: ${TABLE}.post_purchase_session_count ;;
    group_label: "Experiment Variant Facts"
  }
  measure:total_repeat_order_completed_sessions{
    type: sum
    sql: ${TABLE}.total_repeat_order_completed_sessions ;;
    group_label: "Experiment Variant Facts"
  }
  measure:repeat_order_completed_conversion_rate_by_session{
    type: sum
    sql: ${TABLE}.repeat_order_completed_conversion_rate_by_session ;;
    group_label: "Experiment Variant Facts"
  }


}
