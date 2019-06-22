connection: "datawarehouse_db"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: funnel_explorer {
#   join: sessions {
#     view_label: "Sessions"
#     foreign_key: session_id
#   }
#
#   join: session_facts {
#     view_label: "Sessions"
#     relationship: one_to_one
#     foreign_key: session_id
#   }

  join: users {
    relationship: many_to_one
    sql_on: coalesce(users.mapped_user_id, users.user_id) = ${funnel_explorer.user_id} ;;
  }

  join: user_facts {
    view_label: "Users"
    foreign_key: funnel_explorer.user_id
  }
}

explore: event_list {}

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
