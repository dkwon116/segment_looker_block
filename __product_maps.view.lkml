view: product_maps {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${products.SQL_TABLE_NAME} ;;
    sql: SELECT
          p.id
          , pm.internal_vendor_product_id as vendor_product_id
          , CASE WHEN pm.vendor = "ssense" THEN sp.sku
              ELSE pm.internal_vendor_product_id END as affiliate_product_id
          , pm.vendor as vendor

          FROM mysql_smile_ventures.products as p
          LEFT JOIN mysql_smile_ventures.product_maps as pm
            ON p.id = pm.product_id
          LEFT JOIN mysql_ssense.products as sp
            ON pm.internal_vendor_product_id = sp.vendor_id_string
          WHERE p._fivetran_deleted = false
    ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.id ;;
    link: {
      label: "캐치에서 보기"
      url: "https://www.catchfashion.com/view/{{value | encode_url}}"
      icon_url: "https://www.catchfashion.com/favicon.ico"
    }
    link: {
      label: "캐치관리자에서 보기"
      url: "https://admin.catchfashion.com/products-view/{{value | encode_url}}"
      icon_url: "https://www.catchfashion.com/favicon.ico"
    }
    link: {
      label: "{{product_maps.vendor._value}}에서 보기"
      url: "{% if product_maps.vendor._value == 'farfetch' %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}.aspx
      {% elsif product_maps.vendor._value == 'mytheresa' %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}.html
      {% else %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}{% endif %}"
    }
  }

  dimension: vendor_product_id {
    type: string
    sql: ${TABLE}.vendor_product_id ;;
    hidden: yes
  }

  dimension: affiliate_product_id {
    type: string
    sql: ${TABLE}.affiliate_product_id ;;
    hidden: yes
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }


  dimension: vendor_url {
    type: string
    hidden: yes
    sql: CASE
            WHEN ${TABLE}.vendor = 'matchesfashion' THEN 'https://www.matchesfashion.com/en-kr/products/'
            WHEN ${TABLE}.vendor = 'farfetch' THEN 'https://www.farfetch.com/kr/shopping/--item-'
            WHEN ${TABLE}.vendor = 'ssense' THEN 'https://www.ssense.com/en-kr/men/product/*/*/'
            WHEN ${TABLE}.vendor = 'mytheresa' THEN 'https://www.mytheresa.com/en-kr/'
          END;;
  }
}
