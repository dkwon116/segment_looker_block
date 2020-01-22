view: products_viewed_in_list_test {
  derived_table: {
    sql_trigger_value: select count(*) from javascript.product_list_viewed ;;
    sql:
      select *
      from(
        (select * from ${products_viewed_in_list_current.SQL_TABLE_NAME})
        union all
        (select * from ${products_viewed_in_list_historical.SQL_TABLE_NAME})
      )


         ;;
  }

  }
