view: experiment_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${experiment.SQL_TABLE_NAME} ;;
    sql:
      select
        e.*
      from(
        with e as(
          select
            e.experiment_id
            ,coalesce(tmp.experiment_label,e.experiment_name) as experiment_name
            ,t.experiment_start_at
            ,t.experiment_end_at
            ,count(distinct variant_id) as number_of_variant
            ,count(distinct s.session_id) as number_of_sessions
          from ${experiment_sessions.SQL_TABLE_NAME} e
          join ${sessions.SQL_TABLE_NAME} s on s.session_id=e.session_id
          join(
            select
              e.experiment_id
              ,min(e.session_start_at) as experiment_start_at
              ,max(e.session_start_at) as experiment_end_at
            from(
              select
                e.experiment_id
                ,parse_timestamp('%F %H',format_timestamp('%F %H',s.session_start_at)) as session_start_at
                ,count(1) as sessions
              from ${experiment_sessions.SQL_TABLE_NAME} e
              join ${sessions.SQL_TABLE_NAME} s on s.session_id=e.session_id
              group by 1,2
            ) e
            where e.sessions>=30
            group by 1
          ) t on t.experiment_id=e.experiment_id and s.session_start_at between t.experiment_start_at and t.experiment_end_at
          left join(
           select null as experiment_id, null as experiment_label
            union all select 'ahM-yfSbQgqwCC01Ogkf2g', '191011_NewAboutPage'
            union all select '7wAUOphhRq2C9mR-zoOFfQ','191009_CashbackFlow'
            union all select 'cDKNWZjsQaS3zjxNRPqbbg','191009_CashbackBanner'
          ) tmp on tmp.experiment_id=e.experiment_id
          group by 1,2,3,4
        )
        select
          e.experiment_id
          ,e.experiment_name
          ,e.number_of_variant
          ,e.experiment_start_at
          ,e.experiment_end_at
          ,e.number_of_sessions
          ,s.all_sessions-e.number_of_sessions as number_of_excluded_sessions
          ,s.all_sessions
        from e
        join(
          select e.experiment_id, count(distinct s.session_id) as all_sessions
          from e
          join ${sessions.SQL_TABLE_NAME} s on s.session_start_at between e.experiment_start_at and e.experiment_end_at
          group by 1
        ) s on s.experiment_id=e.experiment_id
      ) e
      where e.experiment_name not in ("191105_CategoryNav_ProductViewed", "Mobile Sidebar Gender")
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

  dimension:number_of_excluded_sessions{
    type: number
    sql: ${TABLE}.number_of_excluded_sessions ;;
    group_label: "Experiment"
  }

  dimension:all_sessions{
    type: number
    sql: ${TABLE}.all_sessions ;;
    group_label: "Experiment"
  }

  dimension:ratio_of_sessions{
    type: number
    sql: ${number_of_sessions}/nullif(${all_sessions},0) ;;
    value_format_name: percent_2
    group_label: "Experiment"
  }
}
