view: product_facts {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${products.SQL_TABLE_NAME} ;;
    sql: SELECT
          p.id
          , p.active as active
          , p.created_at as created_at
          , p.gender as gender
          , p.name as name
          , p.normalized_at as normalized_at
          , p.origin as origin
          , p.updated_at as updated_at
          , b.active as brand_active
          , b.name as brand_name

          FROM mysql_smile_ventures.products as p
          LEFT JOIN mysql_smile_ventures.brands as b
            ON p.brand_id = b.id
          WHERE p._fivetran_deleted = false
    ;;
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
    link: {
      label: "캐치에서 보기"
      url: "https://www.catchfashion.com/view/{{value | encode_url}}"
      icon_url: "https://www.catchfashion.com/favicon.ico"
    }
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active ;;
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
}
