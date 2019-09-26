view: 2_journey_facts {
  derived_table: {
    sql_trigger_value: select count(*) from ${event_facts.SQL_TABLE_NAME} ;;
    sql:
    select
      t.anonymous_id
      ,t.session_id
      ,concat(t.session_id, ' - ', cast(row_number() over(partition by t.session_id order by t.first_timestamp) AS string)) AS journey_id
      ,row_number() over (partition by t.session_id order by t.first_timestamp) AS journey_sequence
      ,case
        when t.journey_type='Product Search' then 1
        when t.journey_type IN ('Brand','Category')
          and lag(t.journey_type) over (partition by t.session_id order by t.first_timestamp)='Search'
          and (lag(t.journey_prop,2) over (partition by t.session_id order by t.first_timestamp)<>t.journey_prop or lag(t.journey_prop,2) over (partition by t.session_id order by t.first_timestamp) is null) then 1
        else null
      end as journey_issearch
      ,t.journey_type
      ,t.journey_prop
      ,if(lead(t.first_timestamp) over (partition by t.session_id order by t.first_timestamp) IS NULL
        ,timestamp_diff(t.last_timestamp, t.first_timestamp,second)
        ,timestamp_diff(lead(t.first_timestamp) over (partition by t.session_id order by t.first_timestamp), t.first_timestamp,second))
        as journey_time_second
      ,t.first_timestamp AS timestamp
      ,t.first_track_sequence_number AS track_sequence_number
      --,t.first_timestamp
      --,t.last_timestamp
      --,t.first_track_sequence_number
      --,t.last_track_sequence_number
      ,t.product_viewed
      ,t.product_list_viewed
      ,t.outlink_clicked
      ,t.outlink_sent
      ,t.product_added_to_wishlist
    from(
      select
      DISTINCT
        t.anonymous_id
        ,t.session_id
        ,t.journey_type
        ,first_value(t.journey_prop) over (partition by t.session_id,t.chunk_set order by t.timestamp rows between unbounded preceding and unbounded following) AS journey_prop
        ,first_value(t.timestamp) over (partition by t.session_id,t.chunk_set order by t.timestamp rows between unbounded preceding and unbounded following) AS first_timestamp
        ,last_value(t.timestamp) over (partition by t.session_id,t.chunk_set order by t.timestamp rows between unbounded preceding and unbounded following) AS last_timestamp
        ,first_value(t.track_sequence_number) over (partition by t.session_id,t.chunk_set order by t.timestamp rows between unbounded preceding and unbounded following) AS first_track_sequence_number
        --,last_value(t.track_sequence_number) over (partition by t.session_id,t.chunk_set order by t.timestamp rows between unbounded preceding and unbounded following) AS last_track_sequence_number
        ,sum(case when t.event='product_viewed' THEN 1 ELSE 0 END) over (partition by t.session_id,t.chunk_set rows between unbounded preceding and unbounded following) AS product_viewed
        ,sum(case when t.event='product_list_viewed' THEN 1 ELSE 0 END) over (partition by t.session_id,t.chunk_set rows between unbounded preceding and unbounded following) AS product_list_viewed
        ,sum(case when t.event='outlink_clicked' THEN 1 ELSE 0 END) over (partition by t.session_id,t.chunk_set rows between unbounded preceding and unbounded following) AS outlink_clicked
        ,sum(case when t.event='outlink_sent' THEN 1 ELSE 0 END) over (partition by t.session_id,t.chunk_set rows between unbounded preceding and unbounded following) AS outlink_sent
        ,sum(case when t.event='product_added_to_wishlist' THEN 1 ELSE 0 END) over (partition by t.session_id,t.chunk_set rows between unbounded preceding and unbounded following) AS product_added_to_wishlist
      from(
        select
          *
          ,last_value(t.chunk_start ignore nulls) over (partition by t.session_id order by t.timestamp rows between unbounded preceding and current row) as chunk_set
        from(
          select
            e.anonymous_id
            ,e.session_id
            ,e.timestamp
            ,e.track_sequence_number
            ,e.journey_type
            ,e.journey_prop
            ,e.event
            ,case
              when lag(e.journey_type) over (partition by e.session_id order by e.timestamp) is null then e.track_sequence_number
              when lag(e.journey_type) over (partition by e.session_id order by e.timestamp)<>e.journey_type then e.track_sequence_number
              when lag(e.journey_type) over (partition by e.session_id order by e.timestamp)=e.journey_type
                and last_value(IF(e.event IN ('Brand','Category','Product Search'),e.journey_prop,NULL) ignore nulls) over (partition by e.session_id order by e.timestamp rows between unbounded preceding and 1 preceding)<>e.journey_prop
                and e.event IN ('Brand','Category','Product Search') then e.track_sequence_number
              else null
            end as chunk_start
          from ${event_facts.SQL_TABLE_NAME} e

        )t
      )t
    )t
;;
  }

  # ----- Dimensions -----
  dimension: journey_id  {
    primary_key: yes
    sql: ${TABLE}.journey_id;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: journey_sequence {
    type: number
    sql: ${TABLE}.journey_sequence ;;
  }

  dimension: journey_issearch {
    type: yesno
    sql: ${TABLE}.journey_issearch ;;
  }

  dimension: journey_type {
    type: string
    sql: ${TABLE}.journey_type ;;
  }

  dimension: journey_time_second {
    type: number
    sql: ${TABLE}.journey_time_second ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [time, hour, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: track_sequence_number {
    type: number
    sql: ${TABLE}.track_sequence_number ;;
  }

  dimension: product_viewed {
    type: number
    sql: ${TABLE}.product_viewed ;;
  }
  dimension: product_list_viewed {
    type: number
    sql: ${TABLE}.product_list_viewed ;;
  }
  dimension: outlink_clicked {
    type: number
    sql: ${TABLE}.outlink_clicked ;;
  }
  dimension: outlink_sent {
    type: number
    sql: ${TABLE}.outlink_sent ;;
  }
  dimension: product_added_to_wishlist {
    type: number
    sql: ${TABLE}.product_added_to_wishlist ;;
  }




}
