connection: "segment_bigquery_db"

# include all views in this project
# - include: "*.dashboard.lookml"  # include all dashboards in this project
include: "*.view"

# - explore: pages


explore: event_facts {
  view_label: "Events"
  label: "Events"

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
    sql_on: event_facts.event_id = concat(tracks.event_id, '-t')
      and event_facts.timestamp = tracks.timestamp
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
