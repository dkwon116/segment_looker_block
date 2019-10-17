view: experiment_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
      select
        e.experiment_id
        ,t.experiment_label
        ,count(distinct variant_id) as number_of_variant
        ,min(s.session_start_at) as experiment_start_at
        ,max(s.session_start_at) as experiment_end_at
      from ${experiment_sessions.SQL_TABLE_NAME} e
      join ${sessions.SQL_TABLE_NAME} s on s.session_id=e.session_id
      left join(
       select null as experiment_id, null as experiment_label
        union all select 'ahM-yfSbQgqwCC01Ogkf2g', '20191011_NewAboutPage'
        union all select '7wAUOphhRq2C9mR-zoOFfQ','20191009_CashbackFlow'
        union all select 'cDKNWZjsQaS3zjxNRPqbbg','20191009_CashbackBanner'
      ) t on t.experiment_id=e.experiment_id
      group by 1,2
      ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
    group_label: "Experiment"
    hidden: yes
  }

  dimension: experiment_label {
    type: string
    sql: ${TABLE}.experiment_label ;;
    group_label: "Experiment"
  }

  dimension_group: start {
    type: time
    timeframes: [date,month]
    sql: ${TABLE}.experiment_start_at ;;
    group_label: "Experiment"
  }

  dimension_group: end {
    type: time
    timeframes: [date,month]
    sql: ${TABLE}.experiment_end_at ;;
    group_label: "Experiment"
  }

  dimension:number_of_variant{
    type: number
    sql: ${TABLE}.number_of_variant ;;
    group_label: "Experiment"
  }

}
