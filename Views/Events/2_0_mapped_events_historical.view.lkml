view: mapped_events_historical {
  derived_table: {
    sql_trigger_value: SELECT FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') ;;
    sql:

      select *
      from (
        select
          t.id as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          ,t.event as event
          ,t.received_at as received
          ,t.context_page_referrer as referrer
          ,t.context_campaign_source as campaign_source
          ,t.context_campaign_medium as campaign_medium
          ,t.context_campaign_name as campaign_name
          ,t.context_campaign_content as campaign_content
          ,t.context_campaign_term as campaign_term
          ,t.context_user_agent as user_agent
          ,t.context_page_url as page_url
          ,t.context_ip as ip
          ,'tracks' as event_source
          ,t.context_page_path AS page_path
        from javascript.tracks as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
        on a2v.alias = t.anonymous_id
        where DATE(t._PARTITIONTIME) < CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS DATE)

        union all

        select
          t.id as event_id
          ,t.anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.timestamp
          --,t.name as event
          ,case
            when name is null then case
              when context_page_path='/' then 'Daily'
              when context_page_path='/brands' then 'Brand List'
              when starts_with(context_page_path,'/brands/') then 'Brand'
              when starts_with(context_page_path,'/category/') then 'Category'
              when context_page_path='/hashtags' then 'Hashtag List'
              when context_page_path in ('/my-page','/user/profile','/me') then 'Profile'
              when context_page_path='/promotions' then 'Retailer Coupon'
              when context_page_path='/sale' then 'Sale'
              when context_page_path='/search' then 'Search'
              when context_page_path='/signin' then 'Login'
              when context_page_path in ('/signup','/user/register') then 'Signup'
              when context_page_path='/user/login' then 'Login'
              when starts_with(context_page_path,'/view/') then 'Product'
              when context_page_path='/onboarding' then 'Onboarding'
              when context_page_path='/purchase' then 'Cart'
              when context_page_path='/rankings' then 'Magazine'
              when context_page_path in ('/forgot-password','/user/forgot-password') then 'Forgot Password'
              when context_page_path='/customer-center' then 'Customer Center'
              when context_page_path='/user/account' then 'Account'
              when context_page_path='/cashback/withdraw' then 'Available Cashback List'
              when context_page_path in ('/cashback/history','/cashback/withdrawal-history') then 'Paid Cashback List'
              when context_page_path in ('/purchase/checkout','/purchase/confirm') then 'Checkout'
              when context_page_path='/cashback/pending' then 'Pending Cashback List'
              when context_page_path='/promotions/coupons' then 'Retailer Coupon'
              else 'other'
              end
            when name='affiliate' then case
              when context_page_path='/' then 'Daily'
              when context_page_path='/promotions/coupons' then 'Retailer Coupon'
              when context_page_path='/promotions/cashbacks' then 'Cashback Retailer'
              when starts_with(context_page_path,'/view/') then 'Product'
              else name
              end
            when name in ('Faq','Faq/') then 'FAQ'
            when name='Home' then 'Daily'
            when name='MyPage' then 'Profile'
            when name in ('Payable Cashback List','Cashback Payable List') then 'Available Cashback List'
            when name='Product List' then case
              when starts_with(context_page_path,'/brands/') then 'Brand'
              when starts_with(context_page_path,'/category/') then 'Category'
              when context_page_path='/new-arrivals' then 'New'
              when context_page_path='/sale' then 'Sale'
              else 'other'
              end
            when name='Profile' then case
              when context_page_path='/me/cashback/history/pending' then 'Pending Cashback List'
              when context_page_path='/me/cashback/history/available' then 'Available Cashback List'
              when context_page_path='/me/linkout' then 'Linkout'
              when context_page_path='/me/cashback/history/withdrawn' then 'Paid Cashback List'
              else name
              end
            when name='Promotions' then case
              when context_page_path in ('/promotions','/promotions/') then 'Retailer Coupon'
              when context_page_path='/promotions/coupons' then 'Retailer Coupon'
              when context_page_path='/promotions/cashbacks' then 'Cashback Retailer'
              else 'other'
              end
            when name='product' then 'Product'
            else name
          end as event
          ,t.received_at as received
          ,t.referrer as referrer
          ,t.context_campaign_source as campaign_source
          ,t.context_campaign_medium as campaign_medium
          ,t.context_campaign_name as campaign_name
          ,t.context_campaign_content as campaign_content
          ,t.context_campaign_term as campaign_term
          ,t.context_user_agent as user_agent
          ,t.context_page_url as page_url
          ,t.context_ip as ip
          ,'pages' as event_source
          ,t.context_page_path AS page_path
        from javascript.pages as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
          on a2v.alias = t.anonymous_id
        where DATE(t._PARTITIONTIME) < CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS DATE)

        union all

        select
          t.order_id as event_id
          ,t.user_id as anonymous_id
          ,coalesce(a2v.looker_visitor_id,a2v.alias) as looker_visitor_id
          ,t.transaction_at as timestamp
          ,'order_completed' as event
          ,t.created_at as received
          ,null as referrer
          ,null as campaign_source
          ,null as campaign_medium
          ,null as campaign_name
          ,null as campaign_content
          ,null as campaign_term
          ,'' as user_agent
          ,'http://www.catchfashion.com' as page_url
          ,'' as ip
          ,'affiliate' as event_source
          ,'' AS page_path
        from ${orders.SQL_TABLE_NAME} as t
        inner join ${page_aliases_mapping.SQL_TABLE_NAME} as a2v
          on a2v.alias = t.user_id
        where t.transaction_at < CAST(FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') AS TIMESTAMP)
      ) as e
      WHERE (e.ip NOT IN ('210.123.124.177', '222.106.98.162', '121.134.191.141', '63.118.26.234', '14.39.183.130', '125.140.120.54', '98.113.6.12', '221.149.2.114')
      AND e.page_url LIKE '%catchfashion%'
      AND e.page_url NOT LIKE '%staging%'
      AND e.user_agent NOT LIKE '%Bot%'
      AND e.event_id NOT IN (SELECT id FROM ${duplicate_events.SQL_TABLE_NAME})
      AND e.looker_visitor_id NOT IN (SELECT user_id FROM google_sheets.filter_user))
      AND e.looker_visitor_id NOT IN (
            select
              distinct id
            from javascript.users
            where context_ip IN ('210.123.124.177', '222.106.98.162', '121.134.191.141', '63.118.26.234', '14.39.183.130', '125.140.120.54', '98.113.6.12', '221.149.2.114', '59.10.186.201'))
       ;;
  }

}
