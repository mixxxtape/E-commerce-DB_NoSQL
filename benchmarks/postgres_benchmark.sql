-- Т1–Т6.
-- брати медіану Execution Time з EXPLAIN (ANALYZE, BUFFERS).

--  Т1. Картка за артикулом 
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM "Catalog"."Products" WHERE "Sku" = 'SMA-000123';

--  Т2. Категорія + 1 характеристика 
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM "Catalog"."Products" p
JOIN "Catalog"."ProductAttributes" a
  ON a."ProductId" = p."Id" AND a."Name" = 'ram_gb' AND a."ValueNumber" = 8
WHERE p."Category" = 'smartphone';

--  Т3. Категорія + 2 характеристики 
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM "Catalog"."Products" p
JOIN "Catalog"."ProductAttributes" a1
  ON a1."ProductId" = p."Id" AND a1."Name" = 'ram_gb' AND a1."ValueNumber" = 8
JOIN "Catalog"."ProductAttributes" a2
  ON a2."ProductId" = p."Id" AND a2."Name" = 'storage_gb' AND a2."ValueNumber" = 256
WHERE p."Category" = 'smartphone';

--  Т4. 1000 карток 
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM "Catalog"."Products"
ORDER BY "Id"
LIMIT 1000;

--  Т5. Середня ціна за категорією 
EXPLAIN (ANALYZE, BUFFERS)
SELECT p."Category", avg(s."Price"), count(*)
FROM "Catalog"."Products" p
JOIN "Catalog"."ProductStores" s ON s."ProductId" = p."Id"
GROUP BY p."Category";

--  Т6. Дешеві товари в магазині 1 
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(DISTINCT "ProductId")
FROM "Catalog"."ProductStores"
WHERE "StoreId" = 1 AND "Price" < 300 AND "Stock" > 0;

-- Розміри даних 
SELECT c.relname, pg_size_pretty(pg_total_relation_size(c.oid)) AS total
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'Catalog' AND c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC;
