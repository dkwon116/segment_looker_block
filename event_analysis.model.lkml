connection: "datawarehouse_db"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

datagroup: orders_datagroup {
  sql_trigger: SELECT count(*) FROM data_data_api_db.affiliate_order_item ;;
  max_cache_age: "5 minutes"
}

explore: funnel_explorer {
  join: users {
    relationship: many_to_one
    sql_on: coalesce(users.mapped_user_id, users.user_id) = ${funnel_explorer.user_id} ;;
  }

  join: user_facts {
    view_label: "Users"
    foreign_key: funnel_explorer.user_id
  }
}



explore: weekly_activities {
  join: users {
    sql_on: ${weekly_activities.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    sql_on: ${weekly_activities.user_id} = ${user_facts.looker_visitor_id} ;;
    relationship: many_to_one
  }
}



explore: active_users {
  join: users {
    sql_on: ${active_users.user_id}=${users.id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    sql_on: ${active_users.user_id} = ${user_facts.looker_visitor_id} ;;
    relationship: many_to_one
  }
}



explore: email_activity {
#   sql_always_where: ${event} = "delivered" ;;

  join: user_facts {
    sql_on: ${email_activity.email} = ${user_facts.email} ;;
    relationship: many_to_one
  }

  join: orders {
    sql_on: ${user_facts.looker_visitor_id}=${orders.user_id} and ${orders.transaction_at_raw} > ${email_activity.received_raw} ;;
    relationship: many_to_many
  }

  join: email_campaigns{
    sql_on: ${email_activity.marketing_campaign_id}=${email_campaigns.marketing_campaign_id} ;;
    relationship: many_to_one
  }
}


explore: event_list {hidden:yes}

explore: rakuten_events {hidden:yes}

explore: currencies {hidden:yes}
