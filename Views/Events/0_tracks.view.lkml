view: tracks {
  sql_table_name: javascript.tracks_view ;;

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

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: event_text {
    type: string
    sql: ${TABLE}.event_text ;;
  }

  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_page_url {
    type: string
    sql: ${TABLE}.context_page_url ;;
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

  dimension_group: received {
    type: time
    hidden: yes
    timeframes: [raw, time, hour, date, week, month]
    sql: ${TABLE}.received_at ;;
  }

  dimension: user_id {
    type: string
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: timestamp {
    type: time
    hidden: yes
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

#  dimension: event_id {
#    type: string
#    sql: CONCAT(cast(${received_raw} AS string), ${anonymous_id}) ;;
#    hidden: yes
#  }

  measure: count_track {
    type: count
    drill_fields: [id, users.context_library_name, users.id]
  }
}

# ## Advanced Fields (require joins to other views)
#
#   - dimension_group: weeks_since_first_visit
#     type: number
#     sql: FLOOR(DATEDIFF(day,${user_session_facts.first_date}, ${received_date})/7)
#
#   - dimension: is_new_user
#     sql:  |
#         CASE
#         WHEN ${received_date} = ${user_session_facts.first_date} THEN 'New User'
#         ELSE 'Returning User' END
#
#   - measure: count_percent_of_total
#     type: percent_of_total
#     sql: ${count}
#     value_format_name: decimal_1
#
#
# ## Advanced -- Session Count Funnel Meausures
#
#   - filter: event1
#     suggestions: [added_item, app_became_active, app_entered_background,
#                   app_entered_foreground, app_launched, app_resigned_active,
#                   asked_for_sizes, completed_order, failed_auth_validation, logged_in,
#                   made_purchase, payment_available, payment_failed, payment_form_shown,
#                   payment_form_submitted, removed_item, saved_sizes, shipping_available,
#                   shipping_form_failed, shipping_form_shown, shipping_form_submitted,
#                   signed_up, submitted_order, switched_auth_forms, tapped_shipit,
#                   view_buy_page, viewed_auth_page]
#
#   - measure: event1_session_count
#     type: number
#     sql: |
#       COUNT(
#         DISTINCT(
#           CASE
#             WHEN
#             {% condition event1 %} ${event} {% endcondition %}
#               THEN ${track_facts.session_id}
#             ELSE NULL END
#         )
#       )
#
#   - filter: event2
#     suggestions: [added_item, app_became_active, app_entered_background,
#                   app_entered_foreground, app_launched, app_resigned_active,
#                   asked_for_sizes, completed_order, failed_auth_validation, logged_in,
#                   made_purchase, payment_available, payment_failed, payment_form_shown,
#                   payment_form_submitted, removed_item, saved_sizes, shipping_available,
#                   shipping_form_failed, shipping_form_shown, shipping_form_submitted,
#                   signed_up, submitted_order, switched_auth_forms, tapped_shipit,
#                   view_buy_page, viewed_auth_page]
#
#   - measure: event2_session_count
#     type: number
#     sql: |
#       COUNT(
#         DISTINCT(
#           CASE
#             WHEN
#             {% condition event2 %} ${event} {% endcondition %}
#               THEN ${track_facts.session_id}
#             ELSE NULL END
#         )
#       )
#
#   - filter: event3
#     suggestions: [added_item, app_became_active, app_entered_background,
#                   app_entered_foreground, app_launched, app_resigned_active,
#                   asked_for_sizes, completed_order, failed_auth_validation, logged_in,
#                   made_purchase, payment_available, payment_failed, payment_form_shown,
#                   payment_form_submitted, removed_item, saved_sizes, shipping_available,
#                   shipping_form_failed, shipping_form_shown, shipping_form_submitted,
#                   signed_up, submitted_order, switched_auth_forms, tapped_shipit,
#                   view_buy_page, viewed_auth_page]
#
#   - measure: event3_session_count
#     type: number
#     sql: |
#       COUNT(
#         DISTINCT(
#           CASE
#             WHEN
#             {% condition event3 %} ${event} {% endcondition %}
#               THEN ${track_facts.session_id}
#             ELSE NULL END
#         )
#       )
#
#   - filter: event4
#     suggestions: [added_item, app_became_active, app_entered_background,
#                   app_entered_foreground, app_launched, app_resigned_active,
#                   asked_for_sizes, completed_order, failed_auth_validation, logged_in,
#                   made_purchase, payment_available, payment_failed, payment_form_shown,
#                   payment_form_submitted, removed_item, saved_sizes, shipping_available,
#                   shipping_form_failed, shipping_form_shown, shipping_form_submitted,
#                   signed_up, submitted_order, switched_auth_forms, tapped_shipit,
#                   view_buy_page, viewed_auth_page]
#
#   - measure: event4_session_count
#     type: number
#     sql: |
#       COUNT(
#         DISTINCT(
#           CASE
#             WHEN
#             {% condition event4 %} ${event} {% endcondition %}
#               THEN ${track_facts.session_id}
#             ELSE NULL END
#         )
#       )
