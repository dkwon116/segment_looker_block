view: category_normalized {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${categories.SQL_TABLE_NAME} ;;
    sql: select
          coalesce(c4.id, c3.id) as id
          , c.gender
          , c.name as root_category
          , c2.name as main_category
          , c3.name as sub_category
          , c4.name as category
          from aurora_smile_ventures.categories as c
          left join aurora_smile_ventures.categories as c2
            ON c.id = c2.parent_id
          left join aurora_smile_ventures.categories as c3
            ON c2.id = c3.parent_id
          left join aurora_smile_ventures.categories as c4
            ON c3.id = c4.parent_id
          where c.type = "category" and c.hierarchy_level = 1
    ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: gender {
    type: string
    sql: UPPER(${TABLE}.gender) ;;
  }

  dimension: root_category {
    type: string
    sql: ${TABLE}.root_category ;;
  }

  dimension: main_category {
    type: string
    sql: ${TABLE}.main_category ;;
  }

  dimension: sub_category {
    type: string
    sql: ${TABLE}.sub_category ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

}