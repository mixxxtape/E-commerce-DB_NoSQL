-- перевірочні запити після генерації даних

SELECT * FROM "Catalog"."Stores";

SELECT count(*) FROM "Catalog"."Products";                          -- 100000
SELECT "Category", count(*) FROM "Catalog"."Products" GROUP BY 1;
SELECT count(*) FROM "Catalog"."ProductAttributes";                 -- ~400000

-- аналог find({category:"smartphone","attributes.ram_gb":8}).limit(3)
SELECT p."Sku", p."Name"
FROM "Catalog"."Products" p
JOIN "Catalog"."ProductAttributes" a
  ON a."ProductId" = p."Id" AND a."Name" = 'ram_gb' AND a."ValueNumber" = 6
WHERE p."Category" = 'smartphone'
LIMIT 3;

-- аналог findOne(): уся картка товару, зібрана в один JSON
SELECT jsonb_pretty(jsonb_build_object(
  'sku', p."Sku", 'name', p."Name", 'brand', p."Brand", 'category', p."Category",
  'attributes', (SELECT jsonb_object_agg(a."Name",
                   COALESCE(to_jsonb(a."ValueText"), to_jsonb(a."ValueNumber")))
                 FROM "Catalog"."ProductAttributes" a WHERE a."ProductId" = p."Id"),
  'tags',   (SELECT jsonb_agg(t."Tag") FROM "Catalog"."ProductTags" t WHERE t."ProductId" = p."Id"),
  'images', (SELECT jsonb_agg(i."Url" ORDER BY i."SortOrder")
             FROM "Catalog"."ProductImages" i WHERE i."ProductId" = p."Id"),
  'stores', (SELECT jsonb_agg(jsonb_build_object('storeId', s."StoreId",
                                'price', s."Price", 'stock', s."Stock"))
             FROM "Catalog"."ProductStores" s WHERE s."ProductId" = p."Id"),
  'rating', jsonb_build_object('avg', p."RatingAvg", 'count', p."RatingCount")
))
FROM "Catalog"."Products" p
WHERE p."Sku" = (SELECT "Sku" FROM "Catalog"."Products"
                 WHERE "Category" = 'smartphone' ORDER BY "Id" LIMIT 1);
