view: product_list_filtered_in_list {
derived_table: {
  sql_trigger_value: select count(*) from javascript.search_suggestion_viewed_view ;;
  sql:
(with t1 as (
  select
    id
    ,event
    ,gender
    ,split( trim(filters,'[]'), '},' ) as filters_array
    ,timestamp
  from ${product_list_filtered.SQL_TABLE_NAME}
)
select
  id
  ,event
  ,gender
  ,'filter' as event_type
  ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.type"), '"') as filter_type
  ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.value"), '"') as filter_value
  ,timestamp
from t1
cross join unnest(filters_array) as sug)

union all

(with t1 as (
  select
    id
    ,event
    ,gender
    ,split( trim(sorts,'[]'), '},' ) as sorts_array
    ,timestamp
  from ${product_list_filtered.SQL_TABLE_NAME}
)
select
  id
  ,event
  ,gender
  ,'sort' as event_type
  ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.type"), '"') as filter_type
  ,trim(JSON_EXTRACT(CONCAT(sug, '}'), "$.value"), '"') as filter_value
  ,timestamp
from t1
cross join unnest(sorts_array) as sug)
          ;;
}


dimension: id {
  type: string
  sql: ${TABLE}.id ;;
  hidden: yes
  primary_key: yes
}

dimension: anonymous_id {
  type: string
  sql: ${TABLE}.anonymous_id ;;
  hidden: yes
}

dimension: user_id {
  type: string
  sql: ${TABLE}.user_id ;;
  hidden: yes
}

dimension: event {
  type: string
  hidden: yes
  sql: ${TABLE}.event ;;
}

dimension: gender {
  type: string
  sql: ${TABLE}.gender ;;
  hidden: yes
}

dimension: event_type {
  type: string
  sql: ${TABLE}.event_type ;;
}

dimension: filter_type {
  type: string
  sql: ${TABLE}.filter_type ;;
}

dimension: filter_value {
  type: string
  sql: ${TABLE}.filter_value ;;
}

  dimension: filter_value_normalized {
    type: string
    sql:
      case
        when ${TABLE}.event_type='sort' then ${TABLE}.filter_value
        when ${TABLE}.event_type='filter' and ${TABLE}.filter_type in ('retailers','categories') then cast(array_length(split(trim(${TABLE}.filter_value,"[]"),",")) as string)
        when ${TABLE}.event_type='filter' and ${TABLE}.filter_type='toggle' then ${TABLE}.filter_value
        else ${TABLE}.filter_type
      end
        ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.timestamp ;;
  }

measure: count {
  type: count
}

measure: count_visitors {
  type: count_distinct
  sql: ${event_facts.looker_visitor_id} ;;
}


}
