view: users_deleted {
  sql_table_name: aurora_smile_ventures.users_deleted ;;

  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.user_id ;;
  }

  }
