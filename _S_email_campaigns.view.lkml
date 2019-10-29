view: email_campaigns {
  derived_table: {
    sql_trigger_value: select count(*) from ${email_activity.SQL_TABLE_NAME} ;;
    sql:
      select
        concat(e.source,e.medium,e.campaign,e.content,e.term) as utm
        ,e.source
        ,e.medium
        ,e.campaign
        ,e.content
        ,e.term
        ,t.*
      from(
        select
        distinct
          e.marketing_campaign_id
          ,first_value(e.source) over (w) as source
          ,first_value(e.medium) over (w) as medium
          ,first_value(e.campaign) over (w) as campaign
          ,first_value(e.content) over (w) as content
          ,first_value(e.term) over (w) as term
        from(
          select
            e.marketing_campaign_id
            ,split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)] as source
            ,split(split(e.url,'utm_medium=')[safe_offset(1)],'&')[safe_offset(0)] as medium
            ,split(split(e.url,'utm_campaign=')[safe_offset(1)],'&')[safe_offset(0)] as campaign
            ,split(split(e.url,'utm_content=')[safe_offset(1)],'&')[safe_offset(0)] as content
            ,split(split(e.url,'utm_term=')[safe_offset(1)],'&')[safe_offset(0)] as term
            ,count(1) as click_cnt
          from ${email_activity.SQL_TABLE_NAME} e
          where e.event='click'
          and split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)]='sendgrid'
          and split(split(e.url,'utm_source=')[safe_offset(1)],'&')[safe_offset(0)] is not null
          and split(split(e.url,'utm_medium=')[safe_offset(1)],'&')[safe_offset(0)] is not null
          and split(split(e.url,'utm_campaign=')[safe_offset(1)],'&')[safe_offset(0)] is not null
          and split(split(e.url,'utm_content=')[safe_offset(1)],'&')[safe_offset(0)] is not null
          and split(split(e.url,'utm_term=')[safe_offset(1)],'&')[safe_offset(0)] is not null
          group by 1,2,3,4,5,6
        )e
        window w as (partition by e.marketing_campaign_id order by e.click_cnt desc rows between unbounded preceding and unbounded following)
      ) e
      left join(
        select
          e.marketing_campaign_id
          ,e.marketing_campaign_name
          ,sum(case when e.event='delivered' then 1 else 0 end) as delivered
          ,count(distinct case when e.event='delivered' then e.email else null end) as delivered_users
          ,sum(case when e.event='deferred' then 1 else 0 end) as deferred
          ,count(distinct case when e.event='deferred' then e.email else null end) as deferred_users
          ,sum(case when e.event='open' then 1 else 0 end) as open
          ,count(distinct case when e.event='open' then e.email else null end) as open_users
          ,sum(case when e.event='click' then 1 else 0 end) as click
          ,count(distinct case when e.event='click' then e.email else null end) as click_users
          ,sum(case when e.event='dropped' then 1 else 0 end) as dropped
          ,count(distinct case when e.event='dropped' then e.email else null end) as dropped_users
          ,sum(case when e.event='bounce' then 1 else 0 end) as bounce
          ,count(distinct case when e.event='bounce' then e.email else null end) as bounce_users
        from ${email_activity.SQL_TABLE_NAME} e
        where e.marketing_campaign_id is not null
        group by 1,2
      ) t on t.marketing_campaign_id=e.marketing_campaign_id
 ;;
  }

 }
