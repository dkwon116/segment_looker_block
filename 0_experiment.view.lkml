view: experiment {
  sql_table_name: javascript.experiment_viewed_view;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: anonymous_id {
    type: string
    sql: ${TABLE}.anonymous_id ;;
  }

  dimension: experiment_id {
    type: string
    sql: ${TABLE}.experiment_id ;;
  }

  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
  }

  dimension: experiment_name {
    type: string
    sql: ${TABLE}.experiment_name ;;
  }

  dimension: variation_id {
    type: string
    sql: ${TABLE}.variation_id ;;
  }

  dimension: variation_name {
    type: string
    sql: ${TABLE}.variation_name ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: event_text {
    type: string
    sql: ${TABLE}.event_text ;;
  }


  dimension: context_ip {
    type: string
    sql: ${TABLE}.context_ip ;;
  }

  dimension: context_page_url {
    type: string
    sql: ${TABLE}.context_page_url ;;
  }

  dimension: context_user_agent {
    type: string
    sql: ${TABLE}.context_user_agent ;;
    hidden: yes
  }

  dimension: context_page_path {
    type: string
    sql: ${TABLE}.context_page_path ;;
  }


  dimension: context_campaign_content {
    type: string
    sql: ${TABLE}.context_campaign_content ;;
  }

  dimension: context_campaign_medium {
    type: string
    sql: ${TABLE}.context_campaign_medium ;;
  }

  dimension: context_campaign_name {
    type: string
    sql: ${TABLE}.context_campaign_name ;;
  }

  dimension: context_campaign_source {
    type: string
    sql: ${TABLE}.context_campaign_source ;;
  }

  dimension: context_campaign_term {
    type: string
    sql: ${TABLE}.context_campaign_term ;;
  }


    dimension: context_library_name {
      type: string
      sql: ${TABLE}.context_library_name ;;
    }

    dimension: context_library_version {
      type: string
      sql: ${TABLE}.context_library_version ;;
    }

    dimension: context_page_referrer {
      type: string
      sql: ${TABLE}.context_page_referrer ;;
    }

    dimension: context_page_search {
      type: string
      sql: ${TABLE}.context_page_search ;;
    }

    dimension: context_page_title {
      type: string
      sql: ${TABLE}.context_page_title ;;
    }


    dimension_group: loaded_at {
      type: time
      sql: ${TABLE}.loaded_at ;;
    }

    dimension_group: original_timestamp {
      type: time
      sql: ${TABLE}.original_timestamp ;;
    }

    dimension_group: received_at {
      type: time
      sql: ${TABLE}.received_at ;;
    }

    dimension_group: sent_at {
      type: time
      sql: ${TABLE}.sent_at ;;
    }

    dimension_group: timestamp {
      type: time
      sql: ${TABLE}.timestamp ;;
    }

    dimension: user_id {
      type: string
      sql: ${TABLE}.user_id ;;
    }

    dimension_group: uuid_ts {
      type: time
      sql: ${TABLE}.uuid_ts ;;
    }

 }
