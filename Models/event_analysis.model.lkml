connection: "datawarehouse_db"

include: "/Views/**/*.view.lkml"                       # include all views in this project
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



#fade-out
explore: experiment_facts {
  join: experiment_variant_facts {
    sql_on: ${experiment_facts.experiment_id}=${experiment_variant_facts.experiment_id} ;;
    type: inner
    relationship: one_to_one
  }
}

explore: experiment_session_facts {
  join: experiment_facts {
    sql_on: ${experiment_facts.experiment_id}=${experiment_session_facts.experiment_id} ;;
    type: inner
    relationship: many_to_one
  }
  join: experiment_session_journey_facts {
    sql_on: ${experiment_session_journey_facts.experiment_id}=${experiment_session_facts.experiment_id}
      and ${experiment_session_journey_facts.session_id}=${experiment_session_facts.session_id}
      and ${experiment_session_journey_facts.variant_id}=${experiment_session_facts.variant_id};;
    type: inner
    relationship: one_to_many
  }
  join: experiment_session_journey_group_facts {
    sql_on: ${experiment_session_journey_group_facts.experiment_id}=${experiment_session_facts.experiment_id}
      and ${experiment_session_journey_group_facts.session_id}=${experiment_session_facts.session_id}
      and ${experiment_session_journey_group_facts.variant_id}=${experiment_session_facts.variant_id};;
    type: inner
    relationship: one_to_many
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

}

explore: campaign_session_facts {

  join: campaigns {
    type: inner
    sql_on: upper(${campaigns.utm})=upper(${campaign_session_facts.utm}) ;;
    relationship: one_to_one
  }

  join: mapped_campaigns {
    type: inner
    sql_on: upper(${mapped_campaigns.mapped_utm})=upper(${campaigns.mapped_utm}) ;;
    relationship: one_to_one
  }

  join: email_campaigns {
    type: left_outer
    sql_on: upper(${email_campaigns.utm})=upper(${campaign_session_facts.utm});;
    relationship: one_to_one
  }

  join: sessions {
    view_label: "Session"
    type: left_outer
    sql_on: ${sessions.session_id} = ${campaign_session_facts.session_id} ;;
    relationship: one_to_one
  }

  join: session_facts {
    view_label: "Session"
    type: left_outer
    sql_on: ${session_facts.session_id} = ${campaign_session_facts.session_id} ;;
    relationship: one_to_one
  }

  join: journeys {
    view_label: "Journey"
    type: left_outer
    sql_on: ${journeys.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    type: left_outer
    sql_on: ${user_facts.looker_visitor_id} = ${sessions.looker_visitor_id} ;;
    relationship: one_to_one
  }
}



explore: event_list {hidden:yes}

explore: rakuten_events {hidden:yes}

explore: currencies {hidden:yes}
