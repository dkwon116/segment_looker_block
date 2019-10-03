view: page_aliases_mapping {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.tracks_view ;;
    sql: with
      all_mappings as (
        select
          anonymous_id
          ,user_id
          ,timestamp as timestamp
        from javascript.tracks_view

        union distinct

        select
          anonymous_id
          ,user_id
          ,timestamp
        from javascript.pages_view

        union distinct

        select
          user_id
          ,user_id
          ,timestamp
        from javascript.pages_view

        union distinct

        select
          id as user_id
          ,id as user_id
          ,null as timestamp
        from mysql_smile_ventures.users
      )
        select
          distinct anonymous_id as alias
          ,coalesce(
            last_value(user_id ignore nulls) over(partition by anonymous_id order by timestamp rows between unbounded preceding and unbounded following)
            ,last_value(anonymous_id ignore nulls) over(partition by anonymous_id order by timestamp rows between unbounded preceding and unbounded following))
            as looker_visitor_id


        from all_mappings
        where anonymous_id IS NOT NULL
       ;;
  }
#
#           ,coalesce(first_value(user_id)
#               over(
#                 partition by anonymous_id
#                 order by timestamp desc
#                 rows between unbounded preceding and unbounded following), user_id, anonymous_id) as looker_visitor_id



  # Anonymous ID
  dimension: alias {
    primary_key: yes
    sql: ${TABLE}.alias ;;
  }

  # User ID
  dimension: looker_visitor_id {
    sql: ${TABLE}.looker_visitor_id ;;
  }

#   measure: count {
#     type: count
#   }

#   measure: count_visitor {
#     type: count_distinct
#     sql: ${looker_visitor_id} ;;
#   }
}
