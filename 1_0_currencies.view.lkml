view: currencies {
  derived_table: {
    sql_trigger_value: SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'US/Pacific') ;;
    sql:
        WITH daily_exc as (
          SELECT
          d.date, unit
          FROM ${dates.SQL_TABLE_NAME} as d
          CROSS JOIN UNNEST(["AUD", "USD", "GBP"]) as unit
        )
        select
          d.date
          ,d.unit
          ,coalesce(c.tts, c2.tts, c3.tts, c4.tts, c5.tts) as rate

        FROM daily_exc as d
        LEFT JOIN mysql_smile_ventures.currencies as c
          ON d.date = DATE(c.date) AND d.unit = c.cur_unit
        LEFT JOIN mysql_smile_ventures.currencies as c2
          ON d.date = DATE_ADD(DATE(c2.date), INTERVAL 1 DAY) AND d.unit = c2.cur_unit
        LEFT JOIN mysql_smile_ventures.currencies as c3
          ON d.date = DATE_ADD(DATE(c3.date), INTERVAL 2 DAY) AND d.unit = c3.cur_unit
        LEFT JOIN mysql_smile_ventures.currencies as c4
          ON d.date = DATE_ADD(DATE(c4.date), INTERVAL 3 DAY) AND d.unit = c4.cur_unit
        LEFT JOIN mysql_smile_ventures.currencies as c5
          ON d.date = DATE_ADD(DATE(c5.date), INTERVAL 4 DAY) AND d.unit = c5.cur_unit
        WHERE coalesce(c.tts, c2.tts, c3.tts, c4.tts, c5.tts) IS NOT NULL
      ;;
  }


  dimension: date {
#     primary_key: yes
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: unit {
    type: string
    sql: ${TABLE}.unit ;;
  }

  dimension: rate {
    type: number
    sql: ${TABLE}.rate ;;
  }
}
