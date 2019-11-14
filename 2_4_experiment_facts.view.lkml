view: experiment_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
      select
        e.experiment_id
        ,coalesce(t.experiment_label,e.experiment_name) as experiment_name
        ,count(distinct variant_id) as number_of_variant
        ,min(s.session_start_at) as experiment_start_at
        ,max(s.session_start_at) as experiment_end_at
        ,count(s.session_id) as number_of_sessions
      from ${experiment_sessions.SQL_TABLE_NAME} e
      join ${sessions.SQL_TABLE_NAME} s on s.session_id=e.session_id
      left join(
       select null as experiment_id, null as experiment_label
        union all select 'ahM-yfSbQgqwCC01Ogkf2g', '191011_NewAboutPage'
        union all select '7wAUOphhRq2C9mR-zoOFfQ','191009_CashbackFlow'
        union all select 'cDKNWZjsQaS3zjxNRPqbbg','191009_CashbackBanner'
      ) t on t.experiment_id=e.experiment_id
      where e.experiment_name not in ("191105_CategoryNav_ProductViewed", "Mobile Sidebar Gender")
      group by 1,2

      ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
    group_label: "Experiment"
    link: {
      label: "Go to dashboard"
      url: "https://smileventures.au.looker.com/dashboards/77?Experiment%20ID={{value | encode_url}}"
    }
    primary_key: yes
  }

  dimension: experiment_name {
    type: string
    sql: ${TABLE}.experiment_name ;;
    group_label: "Experiment"
    link: {
      label: "Go to {{value}} dashboard"
      url: "https://smileventures.au.looker.com/dashboards/77?Experiment%20Name={{value | encode_url}}"
    }
  }

  dimension:number_of_variant{
    type: number
    sql: ${TABLE}.number_of_variant ;;
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

  dimension:number_of_sessions{
    type: number
    sql: ${TABLE}.number_of_sessions ;;
    group_label: "Experiment"
  }

}
