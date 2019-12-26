view: product_maps {
  derived_table: {
    # Rebuilds after sessions rebuilds
    sql_trigger_value: select count(*) from ${products.SQL_TABLE_NAME} ;;
    sql: SELECT
          p.id
          , p.name
          , pm.internal_vendor_product_id as vendor_product_id
          , CASE
              WHEN pm.vendor = "24sevres" THEN substr(pm.internal_vendor_product_id, strpos(pm.internal_vendor_product_id, "_") + 1, 5)
              ELSE pm.internal_vendor_product_id END as affiliate_product_id
          , pm.vendor as vendor

          FROM aurora_smile_ventures.products as p
          LEFT JOIN aurora_smile_ventures.product_maps as pm
            ON p.id = pm.product_id
          WHERE p._fivetran_deleted = false
    ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    link: {
      label: "캐치에서 보기"
      url: "https://www.catchfashion.com/view/{{product_maps.product_id._value | encode_url}}"
      icon_url: "https://www.catchfashion.com/favicon.png"
    }
    link: {
      label: "캐치관리자에서 보기"
      url: "https://admin.catchfashion.com/products-view/{{product_maps.product_id._value | encode_url}}"
      icon_url: "https://www.catchfashion.com/favicon.png"
    }
    link: {
      label: "{{product_maps.vendor._value}}에서 보기"
      url: "{% if product_maps.vendor._value == 'farfetch' %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}.aspx
      {% elsif product_maps.vendor._value == 'mytheresa' %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}.html
      {% else %}{{ product_maps.vendor_url._value}}{{ product_maps.vendor_product_id._value | encode_uri }}{% endif %}"
      icon_url: "{{product_maps.favicon_url._value}}"
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
#     hidden: yes
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

  dimension: favicon_url {
    type: string
    hidden: yes
    sql: CASE
            WHEN ${TABLE}.vendor = 'matchesfashion' THEN 'https://www.matchesfashion.com//_ui/rwd/common/images/favicon.ico'
            WHEN ${TABLE}.vendor = 'farfetch' THEN 'https://cdn-static.farfetch-contents.com/static/images/favicon/Generated/apple-touch-icon-152x152.png'
            WHEN ${TABLE}.vendor = 'ssense' THEN 'https://res.cloudinary.com/ssenseweb/image/upload/v1472005257/web/favicon.ico'
            WHEN ${TABLE}.vendor = 'mytheresa' THEN 'https://www.mytheresa.com/skin/frontend/mytheresa/default/favicon.ico'
          END;;
  }
}
