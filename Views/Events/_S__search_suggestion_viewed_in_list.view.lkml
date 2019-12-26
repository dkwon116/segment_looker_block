
  view: search_suggestion_viewed_in_list {
    derived_table: {
      sql_trigger_value: select count(*) from javascript.search_suggestion_viewed_view ;;
      sql:
        with t1 as (
          select
            id
            ,anonymous_id
            ,user_id
            ,event
            ,gender
            ,query
            ,suggestions
            ,split( trim(suggestions,'[]'), '},' ) as suggestions_array
          from ${search_suggestion_viewed.SQL_TABLE_NAME}
        )
        select
          id
          ,anonymous_id
          ,user_id
          ,event
          ,gender
          ,query
          ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.position"), '"') as suggestion_position
          ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.type"), '"') as suggestion_type
          ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.id"), '"') as suggestion_id
          ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.name"), '"') as suggestion_name
        from t1
        cross join unnest(suggestions_array) as sug
          ;;
    }


    dimension: id {
      type: string
      sql: ${TABLE}.id ;;
      primary_key: yes
    }

    dimension: anonymous_id {
      type: string
      sql: ${TABLE}.anonymous_id ;;
    }

    dimension: user_id {
      type: string
      sql: ${TABLE}.user_id ;;
    }

    dimension: event {
      type: string
      hidden: yes
      sql: ${TABLE}.event ;;
    }

    dimension: gender {
      type: string
      sql: ${TABLE}.gender ;;
    }

    dimension: query {
      type: string
      sql: ${TABLE}.query ;;
    }

    dimension: suggestion_position {
      type: number
      sql: ${TABLE}.suggestion_position ;;
    }

    dimension: suggestion_type {
      type: string
      sql: ${TABLE}.suggestion_type ;;
    }
    dimension: suggestion_id {
      type: string
      sql: ${TABLE}.suggestion_id ;;
    }
    dimension: suggestion_name {
      type: string
      sql: ${TABLE}.suggestion_name ;;
    }

    measure: count {
      type: count
    }

    measure: count_visitors {
      type: count_distinct
      sql: ${event_facts.looker_visitor_id} ;;
    }


    }
