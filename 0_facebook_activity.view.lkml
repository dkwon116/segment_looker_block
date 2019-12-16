view: facebook_activity {
  derived_table: {
    sql_trigger_value: select count(*) from fb_ads.insights_view ;;
    sql:
      select
        cast(ads.id as string) as ad_id
        ,ads.name as ad_name
        ,ad_sets.id as adset_id
--        ,ad_sets.name as adset_name
        ,campaigns.id as campaign_id
        ,campaigns.name as campaign_name
        ,campaigns.start_time as campaign_start_time
        ,insights.date_start as insight_date_start
        ,insights.date_stop as insight_date_stop
        ,insights.impressions
        ,insights.link_clicks
        ,insights.spend
      from(
        select
          ad_id
          ,sum(impressions) as impressions
          ,sum(link_clicks) as link_clicks
          ,sum(spend) as spend
          ,min(date_start) as date_start
          ,max(date_stop) as date_stop
        from ${fb_insights.SQL_TABLE_NAME}
        group by 1
      ) as insights
      left join ${fb_ads.SQL_TABLE_NAME} as ads on ads.id=insights.ad_id
      left join ${fb_ad_sets.SQL_TABLE_NAME} as ad_sets on ad_sets.id=ads.adset_id
      left join ${fb_campaigns.SQL_TABLE_NAME} as campaigns on campaigns.id=ads.campaign_id
      order by campaigns.start_time desc
 ;;
  }



}
