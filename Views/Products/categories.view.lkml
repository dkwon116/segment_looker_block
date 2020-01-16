view: categories {
#   sql_table_name: aurora_smile_ventures.categories ;;

  derived_table: {
    sql_trigger_value: select count(*) from aurora_smile_ventures.categories ;;
    sql:
      select
        c.*

        ,if(c.type='category',replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),null) as full_name
        ,if(c.type='category',split(replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),",")[safe_offset(0)],null) as category1_name
        ,if(c.type='category',split(replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),",")[safe_offset(1)],null) as category2_name
        ,if(c.type='category',split(replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),",")[safe_offset(2)],null) as category3_name
        ,if(c.type='category',split(replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),",")[safe_offset(3)],null) as category4_name
        ,if(c.type='category',split(replace(concat(ifnull(c5.name,"None"),",",ifnull(c4.name,"None"),",",ifnull(c3.name,"None"),",",ifnull(c2.name,"None"),",",ifnull(c.name,"None")),"None,",""),",")[safe_offset(4)],null) as category5_name

        ,if(c.type='category',split(replace(concat(ifnull(c5.id,"None"),",",ifnull(c4.id,"None"),",",ifnull(c3.id,"None"),",",ifnull(c2.id,"None"),",",ifnull(c.id,"None")),"None,",""),",")[safe_offset(0)],null) as category1_id
        ,if(c.type='category',split(replace(concat(ifnull(c5.id,"None"),",",ifnull(c4.id,"None"),",",ifnull(c3.id,"None"),",",ifnull(c2.id,"None"),",",ifnull(c.id,"None")),"None,",""),",")[safe_offset(1)],null) as category2_id
        ,if(c.type='category',split(replace(concat(ifnull(c5.id,"None"),",",ifnull(c4.id,"None"),",",ifnull(c3.id,"None"),",",ifnull(c2.id,"None"),",",ifnull(c.id,"None")),"None,",""),",")[safe_offset(2)],null) as category3_id
        ,if(c.type='category',split(replace(concat(ifnull(c5.id,"None"),",",ifnull(c4.id,"None"),",",ifnull(c3.id,"None"),",",ifnull(c2.id,"None"),",",ifnull(c.id,"None")),"None,",""),",")[safe_offset(3)],null) as category4_id
        ,if(c.type='category',split(replace(concat(ifnull(c5.id,"None"),",",ifnull(c4.id,"None"),",",ifnull(c3.id,"None"),",",ifnull(c2.id,"None"),",",ifnull(c.id,"None")),"None,",""),",")[safe_offset(4)],null) as category5_id
      from aurora_smile_ventures.categories c
      left join aurora_smile_ventures.categories c2 on c2.id=c.parent_id
      left join aurora_smile_ventures.categories c3 on c3.id=c2.parent_id
      left join aurora_smile_ventures.categories c4 on c4.id=c3.parent_id
      left join aurora_smile_ventures.categories c5 on c5.id=c4.parent_id
      ;;
  }

  dimension: id {
    primary_key: yes
    type: string
#     hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}._fivetran_deleted ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
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
    sql: ${TABLE}._fivetran_synced ;;
    hidden: yes
  }

  dimension: category_active {
    type: yesno
    sql: ${TABLE}.active ;;
    group_label: "Category"
  }

  dimension: animation_type {
    type: string
    sql: ${TABLE}.animation_type ;;
    hidden: yes
  }

  dimension: artwork_type {
    type: string
    sql: ${TABLE}.artwork_type ;;
    hidden: yes
  }

  dimension: base_default_amount {
    type: number
    sql: ${TABLE}.base_default_amount ;;
    hidden: yes
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

  dimension: custom_duties {
    type: number
    sql: ${TABLE}.custom_duties ;;
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
    hidden: yes
  }

  dimension: educational_tax {
    type: number
    sql: ${TABLE}.educational_tax ;;
    hidden: yes
  }

  dimension_group: end {
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
    sql: ${TABLE}.end_date ;;
    hidden: yes
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
    group_label: "Category"
  }

  dimension: hero_image {
    type: string
    sql: ${TABLE}.hero_image ;;
    hidden: yes
  }

  dimension: hierarchy_level {
    type: number
    sql: ${TABLE}.hierarchy_level ;;
    group_label: "Category"
  }

  dimension: hs_code {
    type: string
    sql: ${TABLE}.hs_code ;;
    hidden: yes
  }

  dimension: language_preference {
    type: string
    sql: ${TABLE}.language_preference ;;
    hidden: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    group_label: "Category"
  }

  dimension: name_en {
    type: string
    sql: ${TABLE}.name_en ;;
#     hidden: yes
  }

  dimension: name_kr {
    type: string
    sql: ${TABLE}.name_kr ;;
#     hidden: yes
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
    group_label: "Category"
  }

  dimension: category1_name {
    type: string
    sql: ${TABLE}.category1_name ;;
    group_label: "Category"
  }
  dimension: category2_name {
    type: string
    sql: ${TABLE}.category2_name ;;
    group_label: "Category"
  }
  dimension: category3_name {
    type: string
    sql: ${TABLE}.category3_name ;;
    group_label: "Category"
  }
  dimension: category4_name {
    type: string
    sql: ${TABLE}.category4_name ;;
    group_label: "Category"
  }
  dimension: category5_name {
    type: string
    sql: ${TABLE}.category5_name ;;
    group_label: "Category"
  }

  dimension: category1_id {
    type: string
    sql: ${TABLE}.category1_id ;;
    group_label: "Category"
  }
  dimension: category2_id {
    type: string
    sql: ${TABLE}.category2_id ;;
    group_label: "Category"
  }
  dimension: category3_id {
    type: string
    sql: ${TABLE}.category3_id ;;
    group_label: "Category"
  }
  dimension: category4_id {
    type: string
    sql: ${TABLE}.category4_id ;;
    group_label: "Category"
  }
  dimension: category5_id {
    type: string
    sql: ${TABLE}.category5_id ;;
    group_label: "Category"
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
    hidden: yes
  }

  dimension: parent_id {
    type: string
    sql: ${TABLE}.parent_id ;;
    hidden: yes
  }

  dimension: position {
    type: number
    sql: ${TABLE}.position ;;
    hidden: yes
  }

  dimension: price_trans {
    type: string
    sql: ${TABLE}.price_trans ;;
    hidden: yes
  }

  dimension: root_id {
    type: string
    sql: ${TABLE}.root_id ;;
    hidden: yes
  }

  dimension: size_chart_id {
    type: string
    sql: ${TABLE}.size_chart_id ;;
    hidden: yes
  }

  dimension: special_excise_tax {
    type: number
    sql: ${TABLE}.special_excise_tax ;;
    hidden: yes
  }

  dimension_group: start {
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
    sql: ${TABLE}.start_date ;;
    hidden: yes
  }

  dimension: subtitle {
    type: string
    sql: ${TABLE}.subtitle ;;
    hidden: yes
  }

  dimension: surtax {
    type: number
    sql: ${TABLE}.surtax ;;
    hidden: yes
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
    group_label: "Category"
  }

  dimension: type_key {
    type: string
    sql: ${TABLE}.type_key ;;
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

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
