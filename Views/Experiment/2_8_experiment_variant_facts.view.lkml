view: experiment_variant_facts {
  derived_table: {
#     sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql_trigger_value: SELECT FLOOR((TIMESTAMP_DIFF(CURRENT_TIMESTAMP(),'1970-01-01 00:00:00',SECOND)) / (3*60*60)) ;;
    sql:
    select
      e.*
      ,u.sessions_variance as session_per_user_variance
      ,u.discovery_journey_visitor
      ,u.discovery_journey_duration_seconds_variance
      ,u.discovery_journey_duration_seconds_per_discovery_journey_visitor
    from(
      select
        experiment_facts.experiment_id  as experiment_id,
        experiment_facts.experiment_name  as experiment_name,
        experiment_sessions.variant_id  as experiment_variant_id,

         count(distinct session_facts.session_id )
           as session_count,
         count(distinct session_facts.looker_visitor_id )
           as unique_visitor_count,
         count(distinct session_facts.session_id ) / nullif(count(distinct session_facts.looker_visitor_id ),0)
           as session_per_user,

         coalesce(round(coalesce(cast( ( sum(distinct (cast(round(coalesce(session_facts.session_duration_minutes ,0)*(1/1000*1.0), 9) as numeric) + (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - sum(distinct (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) as float64), 0), 6), 0) / nullif(count(distinct session_facts.session_id ),0)
           as session_duration_minutes_per_session,
         var_samp(session_facts.session_duration_minutes)
           as session_duration_minutes_per_session_variance,

         count(distinct case when (session_facts.count_product_viewed  > 0) then session_facts.session_id  else null end)
           as total_product_viewed_sessions,

         sum(coalesce(session_facts.count_product_viewed ,0)) / nullif(count(distinct case when (session_facts.count_product_viewed  > 0) then session_facts.session_id  else null end),0)
           as product_viewed_per_converted_session,
         var_samp(session_facts.count_product_viewed)
           as product_viewed_variance,

      from ${session_facts.SQL_TABLE_NAME} as session_facts
      join ${experiment_sessions.SQL_TABLE_NAME} as experiment_sessions on session_facts.session_id = experiment_sessions.session_id
      join ${experiment_facts.SQL_TABLE_NAME} as experiment_facts on experiment_sessions.experiment_id =  experiment_facts.experiment_id
      where (session_facts.session_start_at between experiment_facts.experiment_start_at and experiment_facts.experiment_end_at)
      and session_facts.session_start_at >= '2019-10-09'
      group by 1,2,3
    ) e
    join(
      select
        e.experiment_id
        ,e.variant_id
        ,var_samp(e.number_of_sessions) as sessions_variance
        ,count(distinct case when (e.discovery_journey_duration_seconds>0) then e.looker_visitor_id else null end)
          as discovery_journey_visitor
        ,var_samp(e.discovery_journey_duration_seconds) as discovery_journey_duration_seconds_variance
        ,sum(e.discovery_journey_duration_seconds)/count(distinct case when (e.discovery_journey_duration_seconds>0) then e.looker_visitor_id else null end)
          as discovery_journey_duration_seconds_per_discovery_journey_visitor
      from(
        select
          e.experiment_id
          ,e.variant_id
          ,e.looker_visitor_id
          ,count(distinct e.session_id) as number_of_sessions
          ,sum(case when j.is_discovery=true then jf.journey_duration_seconds else 0 end) as discovery_journey_duration_seconds
        from ${experiment_sessions.SQL_TABLE_NAME} e
        left join ${journeys.SQL_TABLE_NAME} as j on j.session_id=e.session_id
        left join ${journey_facts.SQL_TABLE_NAME} as jf on jf.journey_id=j.journey_id
        group by 1,2,3
      ) e
      group by 1,2
    ) u on u.experiment_id=e.experiment_id and u.variant_id=e.experiment_variant_id
      ;;
  }

#
#     select
#       e.*
#       ,u.sessions_variance as session_per_user_variance
#       ,u.discovery_journey_visitor
#       ,u.discovery_journey_duration_seconds_variance
#       ,u.discovery_journey_duration_seconds_per_discovery_journey_visitor
#     from(
#       select
#         experiment_facts.experiment_id  as experiment_id,
#         experiment_facts.experiment_name  as experiment_name,
#         experiment_sessions.variant_id  as experiment_variant_id,
#
#         count(distinct session_facts.session_id )
#           as session_count,
#         count(distinct session_facts.looker_visitor_id )
#           as unique_visitor_count,
#         count(distinct session_facts.session_id ) / nullif(count(distinct session_facts.looker_visitor_id ),0)
#           as session_per_user,
#         coalesce(round(coalesce(cast( ( sum(distinct (cast(round(coalesce(session_facts.session_duration_minutes ,0)*(1/1000*1.0), 9) as numeric) + (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - sum(distinct (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) as float64), 0), 6), 0)
#           as total_session_duration,
#         coalesce(round(coalesce(cast( ( sum(distinct (cast(round(coalesce(session_facts.session_duration_minutes ,0)*(1/1000*1.0), 9) as numeric) + (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - sum(distinct (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) as float64), 0), 6), 0) / nullif(count(distinct session_facts.session_id ),0)
#           as session_duration_minutes_per_session,
#         var_samp(session_facts.session_duration_minutes)
#           as session_duration_minutes_per_session_variance,
#         coalesce(round(coalesce(cast( ( sum(distinct (cast(round(coalesce(session_facts.session_duration_minutes ,0)*(1/1000*1.0), 9) as numeric) + (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - sum(distinct (cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(cast(session_facts.session_id  as string))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) as float64), 0), 6), 0) / nullif(count(distinct session_facts.looker_visitor_id ),0)
#           as session_duration_minutes_per_user,
#
#         count(distinct case when session_facts.is_guest_at_session  then session_facts.looker_visitor_id  else null end)
#           as unique_guest_count,
#         count(distinct case when (session_facts.number_of_signed_up_events  > 0) then session_facts.looker_visitor_id  else null end)
#           as unique_signed_up_visitor,
#         (count(distinct case when (session_facts.number_of_signed_up_events  > 0) then session_facts.looker_visitor_id  else null end)) / nullif((count(distinct case when session_facts.is_guest_at_session  then session_facts.looker_visitor_id  else null end)),0)
#           as signedup_conversion,
#
#         count(distinct case when (session_facts.count_product_viewed  > 0) then session_facts.session_id  else null end)
#           as total_product_viewed_sessions,
#         (count(distinct case when (session_facts.count_product_viewed  > 0) then session_facts.session_id  else null end)) / nullif((count(distinct session_facts.session_id )),0)
#           as product_viewed_conversion_rate_by_session,
#         sum(coalesce(session_facts.count_product_viewed ,0))
#           as products_viewed_total,
#
#         sum(coalesce(session_facts.count_product_viewed ,0)) / nullif(count(distinct case when (session_facts.count_product_viewed  > 0) then session_facts.session_id  else null end),0)
#           as product_viewed_per_converted_session,
#         var_samp(session_facts.count_product_viewed)
#           as product_viewed_variance,
#
#         count(distinct case when (session_facts.count_added_to_wishlist  > 0) then session_facts.session_id  else null end)
#           as total_added_to_wishlist_sessions,
#         (count(distinct case when (session_facts.count_added_to_wishlist  > 0) then session_facts.session_id  else null end)) / nullif((count(distinct session_facts.session_id )),0)
#           as added_to_wishlist_conversion_rate_by_session,
#         count(distinct case when (session_facts.count_concierge_clicked  > 0) then session_facts.session_id  else null end)
#           as total_concierge_clicked_sessions,
#         (count(distinct case when (session_facts.count_concierge_clicked  > 0) then session_facts.session_id  else null end)) / nullif((count(distinct session_facts.session_id )),0)
#           as concierge_conversion_rate_by_session,
#
#         count(distinct case when (session_facts.count_outlinked  > 0) then session_facts.session_id  else null end)
#           as total_outlinked_sessions,
#         (count(distinct case when (session_facts.count_outlinked  > 0) then session_facts.session_id  else null end)) / nullif((count(distinct session_facts.session_id )), 0)
#           as outlinked_conversion_rate_by_session,
#         count(distinct case when session_facts.is_pre_outlinked_at_session  then session_facts.session_id  else null end)
#           as pre_outlinked_session_count,
#         count(distinct case when (session_facts.count_outlinked  > 0) and session_facts.is_pre_outlinked_at_session then session_facts.session_id  else null end)
#           as total_first_outlinked_sessions,
#         (count(distinct case when (session_facts.count_outlinked  > 0) and session_facts.is_pre_outlinked_at_session then session_facts.session_id  else null end)) / nullif((count(distinct case when session_facts.is_pre_outlinked_at_session  then session_facts.session_id  else null end)), 0)
#           as first_outlinked_conversion_rate_by_session,
#         count(distinct case when not coalesce(session_facts.is_pre_outlinked_at_session , false) then session_facts.session_id  else null end)
#           as post_outlinked_session_count,
#         count(distinct case when (session_facts.count_outlinked  > 0) and (not coalesce(session_facts.is_pre_outlinked_at_session , false)) then session_facts.session_id  else null end)
#           as total_repeat_outlinked_sessions,
#         (count(distinct case when (session_facts.count_outlinked  > 0) and (not coalesce(session_facts.is_pre_outlinked_at_session , false)) then session_facts.session_id  else null end)) / nullif((count(distinct case when not coalesce(session_facts.is_pre_outlinked_at_session , false) then session_facts.session_id  else null end)), 0)
#           as repeat_outlinked_conversion_rate_by_session,
#
#         count(distinct case when (session_facts.count_order_completed  > 0) then session_facts.session_id  else null end)
#           as total_order_completed_sessions,
#         (count(distinct case when (session_facts.count_order_completed  > 0) then session_facts.session_id  else null end)) / nullif((count(distinct session_facts.session_id )),0)
#           as order_completed_conversion_rate_by_session,
#         count(distinct case when session_facts.is_pre_purchase_at_session  then session_facts.session_id  else null end)
#           as pre_purchase_session_count,
#         count(distinct case when (session_facts.count_order_completed  > 0) and session_facts.is_pre_purchase_at_session then session_facts.session_id  else null end)
#           as total_first_order_completed_sessions,
#         (count(distinct case when (session_facts.count_order_completed  > 0) and session_facts.is_pre_purchase_at_session then session_facts.session_id  else null end)) / nullif((count(distinct case when session_facts.is_pre_purchase_at_session  then session_facts.session_id  else null end)),0)
#           as first_order_completed_conversion_rate_by_session,
#         count(distinct case when not coalesce(session_facts.is_pre_purchase_at_session , false) then session_facts.session_id  else null end)
#           as post_purchase_session_count,
#         count(distinct case when (session_facts.count_order_completed  > 0) and (not coalesce(session_facts.is_pre_purchase_at_session , false)) then session_facts.session_id  else null end)
#           as total_repeat_order_completed_sessions,
#         (count(distinct case when (session_facts.count_order_completed  > 0) and (not coalesce(session_facts.is_pre_purchase_at_session , false)) then session_facts.session_id  else null end)) / nullif((count(distinct case when not coalesce(session_facts.is_pre_purchase_at_session , false) then session_facts.session_id  else null end)),0)
#           as repeat_order_completed_conversion_rate_by_session
#
#       from ${session_facts.SQL_TABLE_NAME} as session_facts
#       join ${experiment_sessions.SQL_TABLE_NAME} as experiment_sessions on session_facts.session_id = experiment_sessions.session_id
#       join ${experiment_facts.SQL_TABLE_NAME} as experiment_facts on experiment_sessions.experiment_id =  experiment_facts.experiment_id
#       where (session_facts.session_start_at between experiment_facts.experiment_start_at and experiment_facts.experiment_end_at)
#       group by 1,2,3
#     ) e
#     join(
#       select
#         e.experiment_id
#         ,e.variant_id
#         ,var_samp(e.number_of_sessions) as sessions_variance
#         ,count(distinct case when (e.discovery_journey_duration_seconds>0) then e.looker_visitor_id else null end)
#           as discovery_journey_visitor
#         ,var_samp(e.discovery_journey_duration_seconds) as discovery_journey_duration_seconds_variance
#         ,sum(e.discovery_journey_duration_seconds)/count(distinct case when (e.discovery_journey_duration_seconds>0) then e.looker_visitor_id else null end)
#           as discovery_journey_duration_seconds_per_discovery_journey_visitor
#       from(
#         select
#           e.experiment_id
#           ,e.variant_id
#           ,e.looker_visitor_id
#           ,count(distinct e.session_id) as number_of_sessions
#           ,sum(case when j.is_discovery=true then jf.journey_duration_seconds else 0 end) as discovery_journey_duration_seconds
#         from ${experiment_sessions.SQL_TABLE_NAME} e
#         left join ${journeys.SQL_TABLE_NAME} as j on j.session_id=e.session_id
#         left join ${journey_facts.SQL_TABLE_NAME} as jf on jf.journey_id=j.journey_id
#         group by 1,2,3
#       ) e
#       group by 1,2
#     ) u on u.experiment_id=e.experiment_id and u.variant_id=e.experiment_variant_id



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
  measure:session_duration_minutes_per_session_variance{
    type: sum
    sql: ${TABLE}.session_duration_minutes_per_session_variance ;;
    group_label: "Experiment Variant Facts"
  }
  measure:session_duration_minutes_per_user{
    type: sum
    sql: ${TABLE}.session_duration_minutes_per_user ;;
    group_label: "Experiment Variant Facts"
  }

  measure:discovery_journey_visitor{
    type: sum
    sql: ${TABLE}.discovery_journey_visitor ;;
    group_label: "Experiment Variant Facts"
  }
  measure:discovery_journey_duration_seconds_variance{
    type: sum
    sql: ${TABLE}.discovery_journey_duration_seconds_variance ;;
    group_label: "Experiment Variant Facts"
  }
  measure:discovery_journey_duration_seconds_per_discovery_journey_visitor{
    type: sum
    sql: ${TABLE}.discovery_journey_duration_seconds_per_discovery_journey_visitor ;;
    value_format_name: decimal_0
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
