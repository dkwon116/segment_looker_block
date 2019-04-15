connection: "datawarehouse_db"

# include all views in this project
# - include: "*.dashboard.lookml"  # include all dashboards in this project
include: "*.view"
# - explore: pages


explore: event_facts {
  view_label: "0_Events"
  label: "Events"

  join: pages {
    view_label: "1_Page Events"
    type: left_outer
    sql_on: event_facts.timestamp = pages.timestamp
      and event_facts.anonymous_id = pages.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: tracks {
    view_label: "1_Track Events"
    type: left_outer
    sql_on: event_facts.timestamp = tracks.timestamp
      and event_facts.anonymous_id = tracks.anonymous_id
       ;;
    relationship: one_to_one
#     fields: []
  }

  join: page_facts {
    view_label: "0_Events"
    type: left_outer
    sql_on: event_facts.event_id = page_facts.event_id and
      event_facts.timestamp = page_facts.timestamp and
      event_facts.looker_visitor_id = page_facts.looker_visitor_id
       ;;
    relationship: one_to_one
  }

  join: sessions {
    view_label: "0_Sessions"
    type: left_outer
    sql_on: ${event_facts.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: session_facts {
    view_label: "0_Sessions"
    type: left_outer
    sql_on: ${event_facts.session_id} = ${session_facts.session_id} ;;
    relationship: many_to_one
  }

  join: page_aliases_mapping {
    view_label: "3_Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${page_aliases_mapping.looker_visitor_id} ;;
    relationship: many_to_one
  }

  join: catch_users {
    view_label: "3_Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${catch_users.id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    view_label: "3_Users"
    type: left_outer
    sql_on: ${event_facts.looker_visitor_id}=${user_facts.looker_visitor_id} ;;
    relationship: many_to_one
  }

  join: concierge_clicked_view {
    view_label: "T_Concierge Clicked"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${concierge_clicked_view.timestamp_raw} AS string), ${concierge_clicked_view.anonymous_id}, '-t')
      and event_facts.timestamp = concierge_clicked_view.timestamp
      and event_facts.anonymous_id = concierge_clicked_view.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: outlink_sent {
    view_label: "T_Outlinked"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${outlink_sent.timestamp_raw} AS string), ${outlink_sent.anonymous_id}, '-t')
      and event_facts.timestamp = outlink_sent.timestamp
      and event_facts.anonymous_id = outlink_sent.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: product_list_viewed {
    view_label: "T_Product List Viewed"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${product_list_viewed.timestamp_raw} AS string), ${product_list_viewed.anonymous_id}, '-t')
      and event_facts.timestamp = product_list_viewed.timestamp
      and event_facts.anonymous_id = product_list_viewed.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: products_viewed_in_list {
    view_label: "T_Product List Viewed"
    type: left_outer
    sql_on: ${product_list_viewed.id} = ${products_viewed_in_list.list_viewed_id} ;;
    relationship: one_to_many
  }

  join: product_viewed {
    view_label: "T_Product Viewed"
    type: left_outer
    sql_on: event_facts.event_id = concat(cast(${product_viewed.timestamp_raw} AS string), ${product_viewed.anonymous_id}, '-t')
      and event_facts.timestamp = product_viewed.timestamp
      and event_facts.anonymous_id = product_viewed.anonymous_id
       ;;
    relationship: one_to_one
  }

  join: orders {
    view_label: "Orders"
    type: left_outer
    sql_on: ${event_facts.event_id} = concat(cast(${orders.transaction_at_raw} AS string), ${orders.user_id}, '-r')
    and ${event_facts.timestamp_time} = ${orders.transaction_at_time}
    and ${event_facts.looker_visitor_id} = ${orders.user_id};;
    relationship: one_to_one
  }

  join: order_items {
    view_label: "Order_Products"
    type: left_outer
    sql_on: ${orders.order_id} = ${order_items.order_id};;
    relationship: one_to_many
    }

#   join: tracks_products {
#     type: left_outer
#     sql_on: ${event_facts.event_id} = ${tracks_products.event_id} ;;
#     relationship: one_to_many
#   }
#
#   join: product_facts {
#     type: left_outer
#     sql_on: ${tracks_products.product_id} = ${product_facts.id} ;;
#     relationship: many_to_one
#   }

  # join: products {
  #   view_label: "Product"
  #   type: left_outer
  #   sql_on: ${tracks_products.product_id} = ${products.id} ;;
  #   relationship: many_to_one
  # }

  # join: brands {
  #   view_label: "Product"
  #   type: left_outer
  #   sql_on: ${products.brand_id} = ${brands.id} ;;
  #   relationship: one_to_one
  # }

  # join: products_categories {
  #   view_label: "Product"
  #   type: left_outer
  #   sql_on: ${products.id} = ${products_categories.product_id} ;;
  #   relationship: one_to_many
  #   fields: []
  # }

  join: list_facts {
    from: categories
    type: left_outer
    sql_on: ${product_viewed.prev_path_id} = ${list_facts.id} ;;
    relationship: many_to_one
    fields: []
  }
}

explore: order_items {
  label: "Orders"
  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.order_id} ;;
    relationship: many_to_one
  }

  join: event_facts {
    sql_on: ${orders.user_id} = ${event_facts.looker_visitor_id}
    and CONCAT(${orders.transaction_at_raw}, ${orders.user_id}, "-r") = ${event_facts.event_id};;
    type: left_outer
    relationship: one_to_one
  }

  join: catch_users {
    sql_on: ${order_items.user_id} = ${catch_users.id} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: cashbacks {
    sql_on: ${order_items.order_id} = ${cashbacks.order_id} and ${order_items.sku_id} = ${cashbacks.product_id} ;;
    type: left_outer
    relationship: one_to_many
  }

  join: order_facts {
    sql_on: ${orders.order_id} = ${order_facts.order_id} ;;
    type: left_outer
    relationship: one_to_one
  }
}

explore: product_list_viewed {
  view_label: "Products Viewed in List"
  label: "Product List"
  join: products_viewed_in_list {
    view_label: "Products Viewed in List"
    sql_on: ${product_list_viewed.id} = ${products_viewed_in_list.list_viewed_id} ;;
    relationship: one_to_many
  }
}

explore: event_list {
  hidden: yes
}

explore: product_events {
  join: product_viewed {
    sql_on: ${product_events.event_id} = concat(cast(${product_viewed.timestamp_raw} AS string), ${product_viewed.anonymous_id}, '-t') ;;
    relationship: one_to_one
  }

  join: products_viewed_in_list {
    sql_on: ${product_events.event_id} = concat(cast(${products_viewed_in_list.timestamp_raw} AS string), ${products_viewed_in_list.anonymous_id}, '-t') ;;
    relationship: one_to_one
  }

  join: event_facts {
    sql_on: ${product_events.event_id} = ${event_facts.event_id} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: session_facts {
    type: left_outer
    sql_on: ${event_facts.session_id} = ${session_facts.session_id} ;;
    relationship: many_to_one
  }

  join: sessions {
    type: left_outer
    sql_on: ${event_facts.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: product_facts {
    type: left_outer
    sql_on: ${product_events.product_id} = ${product_facts.id} ;;
    relationship: many_to_one
  }

  join: list_facts {
    from: categories
    type: left_outer
    sql_on: ${product_viewed.prev_path_id} = ${list_facts.id} ;;
    relationship: many_to_one
    fields: []
  }
}
#
# explore: cashbacks {}
#
# explore: orders {}
