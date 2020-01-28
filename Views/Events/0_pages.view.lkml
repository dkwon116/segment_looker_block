
view: pages {
  sql_table_name: javascript.pages_view ;;

#
#   sql_trigger_value: SELECT count(*) from javascript.pages_view ;;
#   sql:
#   SELECT
#   * except(name)
#   ,case
#   when name is null then case
#   when context_page_path='/' then 'Daily'
#   when context_page_path='/brands' then 'Brand List'
#   when starts_with(context_page_path,'/brands/') then 'Brand'
#   when starts_with(context_page_path,'/category/') then 'Category'
#   when context_page_path='/hashtags' then 'Hashtag List'
#   when context_page_path in ('/my-page','/user/profile','/me') then 'Profile'
#   when context_page_path='/promotions' then 'Retailer Coupon'
#   when context_page_path='/sale' then 'Sale'
#   when context_page_path='/search' then 'Search'
#   when context_page_path='/signin' then 'Login'
#   when context_page_path in ('/signup','/user/register') then 'Signup'
#   when context_page_path='/user/login' then 'Login'
#   when starts_with(context_page_path,'/view/') then 'Product'
#   when context_page_path='/onboarding' then 'Onboarding'
#   when context_page_path='/purchase' then 'Cart'
#   when context_page_path='/rankings' then 'Magazine'
#   when context_page_path in ('/forgot-password','/user/forgot-password') then 'Forgot Password'
#   when context_page_path='/customer-center' then 'Customer Center'
#   when context_page_path='/user/account' then 'Account'
#   when context_page_path='/cashback/withdraw' then 'Available Cashback List'
#   when context_page_path in ('/cashback/history','/cashback/withdrawal-history') then 'Paid Cashback List'
#   when context_page_path in ('/purchase/checkout','/purchase/confirm') then 'Checkout'
#   when context_page_path='/cashback/pending' then 'Pending Cashback List'
#   when context_page_path='/promotions/coupons' then 'Retailer Coupon'
#   else 'other'
#   end
#   when name='affiliate' then case
#   when context_page_path='/' then 'Daily'
#   when context_page_path='/promotions/coupons' then 'Retailer Coupon'
#   when context_page_path='/promotions/cashbacks' then 'Cashback Retailer'
#   when starts_with(context_page_path,'/view/') then 'Product'
#   else name
#   end
#   when name in ('Faq','Faq/') then 'FAQ'
#   when name='Home' then 'Daily'
#   when name='MyPage' then 'Profile'
#   when name in ('Payable Cashback List','Cashback Payable List') then 'Available Cashback List'
#   when name='Product List' then case
#   when starts_with(context_page_path,'/brands/') then 'Brand'
#   when starts_with(context_page_path,'/category/') then 'Category'
#   when context_page_path='/new-arrivals' then 'New'
#   when context_page_path='/sale' then 'Sale'
#   else 'other'
#   end
#   when name='Profile' then case
#   when context_page_path='/me/cashback/history/pending' then 'Pending Cashback List'
#   when context_page_path='/me/cashback/history/available' then 'Available Cashback List'
#   when context_page_path='/me/linkout' then 'Linkout'
#   when context_page_path='/me/cashback/history/withdrawn' then 'Paid Cashback List'
#   else name
#   end
#   when name='Promotions' then case
#   when context_page_path in ('/promotions','/promotions/') then 'Retailer Coupon'
#   when context_page_path='/promotions/coupons' then 'Retailer Coupon'
#   when context_page_path='/promotions/cashbacks' then 'Cashback Retailer'
#   else 'other'
#   end
#   when name='product' then 'Product'
#   else name
#   end as name
#   FROM javascript.pages_view


  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
    hidden: yes
  }

  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_campaign_content {
    type: string
    sql: ${TABLE}.context_campaign_content ;;
    group_label: "Campaign"
  }

  dimension: context_campaign_medium {
    type: string
    sql: ${TABLE}.context_campaign_medium ;;
    group_label: "Campaign"
  }

  dimension: context_campaign_name {
    type: string
    sql: ${TABLE}.context_campaign_name ;;
    group_label: "Campaign"
  }

  dimension: context_campaign_source {
    type: string
    sql: ${TABLE}.context_campaign_source ;;
    group_label: "Campaign"
  }

  dimension: context_campaign_term {
    type: string
    sql: ${TABLE}.context_campaign_term ;;
    group_label: "Campaign"
  }

  dimension: context_library_name {
    type: string
    sql: ${TABLE}.context_library_name ;;
    hidden: yes
  }

  dimension: context_library_version {
    type: string
    sql: ${TABLE}.context_library_version ;;
    hidden: yes
  }

  dimension: context_user_agent {
    type: string
    sql: ${TABLE}.context_user_agent ;;
    hidden: yes
  }

  dimension: context_page_path {
    type: string
    sql: ${TABLE}.context_page_path ;;
  }

  dimension: page_name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}.path ;;
  }

  dimension_group: received {
    type: time
    hidden: yes
    timeframes: [raw, time, hour, date, week, month]
    sql: ${TABLE}.received_at ;;
  }

  dimension_group: timestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, hour, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

#   dimension: received {
#     type: date
#     #     timeframes: [raw, time, date, week, month]
#     sql: ${TABLE}.received_at ;;
#   }

  dimension: referrer {
    type: string
    sql: ${TABLE}.referrer ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
  }

  dimension: user_id {
    type: string
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, context_library_name, page_name, users.id]
  }

  measure: count_visitors {
    type: count_distinct
    sql: ${page_facts.looker_visitor_id} ;;
  }

  measure: count_pageviews {
    type: count
    drill_fields: [context_library_name]
  }

  measure: avg_page_view_duration_minutes {
    type: average
    value_format_name: decimal_1
    sql: ${page_facts.duration_page_view_seconds}/60.0 ;;
  }

  measure: count_distinct_pageviews {
    type: number
    sql: COUNT(DISTINCT CONCAT(${page_facts.looker_visitor_id}, ${url})) ;;
  }
}
