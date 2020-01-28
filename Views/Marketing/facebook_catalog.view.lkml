view: facebook_catalog {

  derived_table: {
    sql_trigger_value: SELECT FORMAT_TIMESTAMP('%F', CURRENT_TIMESTAMP(), 'Asia/Seoul') ;;
    sql:
    CREATE TEMP FUNCTION encodeurl(a STRING)
    RETURNS STRING
    LANGUAGE js AS
      """
      try {
        return encodeURIComponent(a);
        }
      catch {
        return "";
        }""";


    select
      t.* except(row_num)
    from(
      SELECT
        product_facts.id AS id
        ,product_facts.name AS title
        ,product_facts.brand_name AS brand
        ,case
          when upper(products.gender)="F" then "Female"
          when upper(products.gender)="M" then "Male"
          when upper(products.gender)="U" then "Unisex"
          else null
        end AS gender
        ,replace(replace(replace(categories.full_name,"남성 ,",""),"여성,",""),","," > ") AS product_type
        ,replace(replace(products.description,"상품 설명",""),"상세 정보","")  AS description
        ,'in stock' AS availability
        ,'new' as condition
        ,concat(cast(product_variations.lowest_price as string)," KRW")  AS price
        ,concat(cast(product_variations.lowest_sale_price as string)," KRW") AS sale_price
        ,concat("https://www.catchfashion.com/view/",product_facts.id) as link
        -- product_facts.product_image AS image_link,
        ,concat('https://media.catchfashion.com/images/h_l?url=',encodeurl(concat('https://',if(starts_with(product_facts.product_image,'//'),replace(product_facts.product_image,'//',''),product_facts.product_image))),'&t=fb_ctg') as image_link
        ,row_number() over (partition by product_facts.id order by categories.hierarchy_level desc, c.engaged_users desc) as row_num

      FROM ${product_facts.SQL_TABLE_NAME} AS product_facts
      JOIN ${products.SQL_TABLE_NAME}  AS products ON product_facts.id=products.id
      JOIN ${product_variations.SQL_TABLE_NAME} AS product_variations ON product_facts.id=product_variations.product_id
      JOIN ${products_categories.SQL_TABLE_NAME}  AS products_categories ON product_facts.id = products_categories.product_id and products_categories._fivetran_deleted = false
      JOIN ${categories.SQL_TABLE_NAME} AS categories ON products_categories.category_id = categories.id and categories.type = 'category'
      JOIN(
        select type_id, count(1) as engaged_users
        from ${user_product_facts.SQL_TABLE_NAME}
        where type='category'
        group by 1
        order by 2 desc
      ) c on c.type_id=categories.id

      WHERE products.active
      AND product_variations.active
      AND ((products.gender IS NOT NULL))
      AND ((products.status IN ('InStock', 'inStock', 'LowStock', 'lowStock')))
      AND categories.full_name IS NOT NULL
    ) t
    where t.row_num=1
    ;;
  }


}
