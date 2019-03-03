view: product_facts {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${products.SQL_TABLE_NAME} ;;
    sql: SELECT
      p.id
      , p.active as active
      , p.channel as channel
      , p.created_at as created_at
      , p.gender as gender
      , p.name as name
      , p.normalized_at as normalized_at
      , p.origin as origin
      , p.supplier as supplier
      , p.updated_at as updated_at
      , b.active as brand_active
      , b.name as brand_name
      , c.gender as category_gender
      , c.hierarchy_level as category_hierarchy
      , c.name as category_name
      , c.parent_id as category_parent
      , c.type as category_type

      FROM mysql_smile_ventures.products as p
      LEFT JOIN mysql_smile_ventures.brands as b
        ON p.brand_id = b.id
      LEFT JOIN mysql_smile_ventures.products_categories as pc
        ON p.id = pc.product_id
      LEFT JOIN mysql_smile_ventures.categories as c
        ON pc.category_id = c.id
    ;;
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active ;;
  }

  dimension: channel {
    type: string
    sql: ${TABLE}.channel ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
    timeframes: [time, date, week, month]
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension_group: normalized_at {
    type: time
    sql: ${TABLE}.normalized_at ;;
    timeframes: [time, date, week, month]
  }

  dimension: origin {
    type: string
    sql: ${TABLE}.origin ;;
  }

  dimension: supplier {
    type: string
    sql: ${TABLE}.supplier ;;
  }

  dimension_group: updated_at {
    type: time
    sql: ${TABLE}.updated_at ;;
    timeframes: [time, date, week, month]
  }

  dimension: brand_active {
    type: yesno
    sql: ${TABLE}.brand_active ;;
  }

  dimension: brand_name {
    type: string
    sql: ${TABLE}.brand_name ;;
  }

#   dimension: category_gender {
#     type: string
#     sql: ${TABLE}.category_gender ;;
#   }
#
#   dimension: category_hierarchy {
#     type: number
#     sql: ${TABLE}.category_hierarchy ;;
#   }
#
#   dimension: category_name {
#     type: string
#     sql: ${TABLE}.category_name ;;
#   }
#
#   dimension: category_parent_id {
#     type: string
#     sql: ${TABLE}.category_parent_id ;;
#   }
#
#   dimension: category_type {
#     type: string
#     sql: ${TABLE}.category_type ;;
#   }
}
