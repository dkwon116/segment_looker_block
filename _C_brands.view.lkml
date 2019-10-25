view: brands {
  sql_table_name: aurora_smile_ventures.brands ;;

  dimension: id {
    primary_key: yes
    type: string
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    hidden: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._fivetran_synced ;;
  }

  dimension: brand_active {
    type: yesno
    sql: ${TABLE}.active ;;
    group_label: "Brand"
  }

  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
    hidden: yes
  }

  dimension: image {
    type: string
    sql: ${TABLE}.image ;;
    group_label: "Brand"
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    group_label: "Brand"
  }

  dimension: name_en {
    type: string
    sql: ${TABLE}.name_en ;;
    group_label: "Brand"
#     hidden: yes
  }

  dimension: name_kr {
    type: string
    sql: ${TABLE}.name_kr ;;
    group_label: "Brand"
#     hidden: yes
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
    hidden: yes
  }

  dimension: notice {
    type: string
    sql: ${TABLE}.notice ;;
    hidden: yes
  }

  dimension: order {
    type: number
    sql: ${TABLE}.``order`` ;;
    hidden: yes
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.parent_id ;;
    hidden: yes
  }

  dimension: tier {
    type: number
    sql: ${TABLE}.tier ;;
    hidden: yes
  }

  dimension_group: updated {
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
    sql: ${TABLE}.updated_at ;;
    hidden: yes
  }

  measure: brand_count {
    type: count
    drill_fields: [id, name, products.count]
  }
}