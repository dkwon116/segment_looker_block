connection: "segment_bigquery_db"

# include all views in this project
# - include: "*.dashboard.lookml"  # include all dashboards in this project
include: "*.view"
include: "orders.base.lkml"
# - explore: pages


explore: event_facts {
  view_label: "Events"
  label: "Events"
  extends: [affiliate_orders]

  join: pages {
    view_label: "Page Events"
    type: left_outer
    sql_on: event_facts.timestamp = pages.timestamp
      and event_facts.anonymous_id = pages.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: tracks {
    view_label: "Track Events"
    type: left_outer
    sql_on: event_facts.timestamp = tracks.timestamp
      and event_facts.anonymous_id = tracks.anonymous_id
       ;;
    relationship: one_to_one
#     fields: []
  }

  join: page_facts {
    view_label: "Events"
    type: left_outer
    sql_on: event_facts.event_id = page_facts.event_id and
      event_facts.timestamp = page_facts.timestamp and
      event_facts.looker_visitor_id = page_facts.looker_visitor_id
       ;;
    relationship: one_to_one
  }

  join: sessions {
    view_label: "Sessions"
    type: left_outer
    sql_on: ${event_facts.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: session_facts {
    view_label: "Sessions"
    type: left_outer
    sql_on: ${event_facts.session_id} = ${session_facts.session_id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    view_label: "Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${user_facts.looker_visitor_id} ;;
    relationship: many_to_one
  }

  join: page_aliases_mapping {
    view_label: "Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${page_aliases_mapping.looker_visitor_id} ;;
    relationship: one_to_many
  }

  join: users {
    view_label: "Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${users.id} ;;
    relationship: many_to_one
  }

  join: concierge_clicked_view {
    view_label: "Concierge Clicked"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${concierge_clicked_view.timestamp_raw} AS string), ${concierge_clicked_view.anonymous_id}, '-t')
      and event_facts.timestamp = concierge_clicked_view.timestamp
      and event_facts.anonymous_id = concierge_clicked_view.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: outlink_sent {
    view_label: "Outlinked"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${outlink_sent.timestamp_raw} AS string), ${outlink_sent.anonymous_id}, '-t')
      and event_facts.timestamp = outlink_sent.timestamp
      and event_facts.anonymous_id = outlink_sent.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: affiliate_orders {
    # view_label: "Orders"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${affiliate_orders.user_id} ;;
    relationship: many_to_one
  }
}

explore: funnel_explorer {
  join: sessions {
    view_label: "Sessions"
    foreign_key: session_id
  }

  join: session_facts {
    view_label: "Sessions"
    relationship: one_to_one
    foreign_key: session_id
  }

  join: users {
    relationship: many_to_one
    sql_on: coalesce(users.mapped_user_id, users.user_id) = sessions.user_id ;;
  }

  join: user_facts {
    view_label: "Users"
    foreign_key: sessions.looker_visitor_id
  }
}

explore: event_list {}

explore: concierge_clicked_view {}

explore: active_users {
  join: users {
    sql_on: ${active_users.user_id}=${users.id} ;;
    relationship: many_to_one
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
