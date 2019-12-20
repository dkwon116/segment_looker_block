view: general_utm_list {
  derived_table: {
    sql_trigger_value: select count(*) from google_sheets.general_utm_list ;;
    sql:
      SELECT
        _row
        ,title
        ,ad_id
        ,spend
        ,landing_url
        ,replace(source," ","") as source
        ,replace(medium," ","") as medium
        ,replace(campaign," ","") as campaign
        ,replace(content," ","") as content
        ,replace(term," ","") as term
        ,length
        ,short_url
        ,replace(utm," ","") as utm
        ,replace(mapped_utm," ","") as mapped_utm
      from google_sheets.general_utm_list
      where utm is not null
        ;;
  }


  dimension: ad_id {
    type: string
    sql: ${TABLE}.ad_id ;;
  }
  dimension: spend {
    type: number
    sql: ${TABLE}.spend ;;
  }
  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }
  dimension: medium {
    type: string
    sql: ${TABLE}.medium ;;
  }
  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }
  dimension: content {
    type: string
    sql: ${TABLE}.content ;;
  }
  dimension: term {
    type: string
    sql: ${TABLE}.term ;;
  }
  dimension: utm {
    type: string
    sql: ${TABLE}.utm ;;
  }
  dimension: mapped_utm {
    type: string
    sql: ${TABLE}.mapped_utm ;;
  }
}

view: general_utm_list_mapped_spend {
  derived_table: {
    sql_trigger_value: select count(*) from google_sheets.general_utm_list ;;
    sql:
  select upper(coalesce(u.mapped_utm, u.utm)) as mapped_utm, sum(coalesce(u.spend, f.spend)) as mapped_spend
  from ${general_utm_list.SQL_TABLE_NAME} u
  left join ${facebook_activity.SQL_TABLE_NAME} f on f.ad_id=cast(u.ad_id as string)
  where u.utm is not null
  and coalesce(u.spend, f.spend) is not null
  group by 1
      ;;
  }

  dimension: mapped_utm {
    type: string
    sql: ${TABLE}.mapped_utm ;;
  }
  dimension: mapped_spend {
    type: number
    sql: ${TABLE}.mapped_spend ;;
  }
}


  view: general_utm_list_mapped_utm {
    derived_table: {
      sql_trigger_value: select count(*) from google_sheets.general_utm_list ;;
      sql:
        select
          distinct
          upper(u.utm) as utm,
          upper(u.mapped_utm) as mapped_utm,
          upper(m.source) as mapped_source,
          upper(m.medium) as mapped_medium,
          upper(m.campaign) as mapped_campaign,
          upper(m.content) as mapped_content,
          upper(m.term) as mapped_term
        from ${general_utm_list.SQL_TABLE_NAME} u
        left join ${general_utm_list.SQL_TABLE_NAME} m on m.utm=u.mapped_utm
        where u.mapped_utm is not null
      ;;
    }

    dimension: utm {
      type: string
      sql: ${TABLE}.utm ;;
      primary_key: yes
    }
    dimension: mapped_utm {
      type: string
      sql: ${TABLE}.mapped_utm ;;
    }
    dimension: mapped_source {
      type: string
      sql: ${TABLE}.mapped_source ;;
    }
    dimension: mapped_medium {
      type: string
      sql: ${TABLE}.mapped_medium ;;
    }
    dimension: mapped_campaign {
      type: string
      sql: ${TABLE}.mapped_campaign ;;
    }
    dimension: mapped_content {
      type: string
      sql: ${TABLE}.mapped_content ;;
    }
    dimension: mapped_term {
      type: string
      sql: ${TABLE}.mapped_term ;;
    }
}
