-- генерація 100 000 товарів. Використовує тимчасову таблицю 

TRUNCATE "Catalog"."Stores", "Catalog"."Products" RESTART IDENTITY CASCADE;

INSERT INTO "Catalog"."Stores" ("Id","Name","City") VALUES
 (1,'Магазин Київ-Центр','Київ'), (2,'Магазин Львів','Львів'),
 (3,'Магазин Одеса','Одеса'),     (4,'Магазин Харків','Харків'),
 (5,'Онлайн-склад','Київ');

-- Довідник категорій
DROP TABLE IF EXISTS cat_def;
CREATE TEMP TABLE cat_def AS
SELECT * FROM (VALUES
 (1,'smartphone','SMA',ARRAY['Samsung','Apple','Xiaomi','Motorola'],5000,50000),
 (2,'laptop','LAP',ARRAY['Lenovo','HP','Asus','Dell'],15000,90000),
 (3,'shoes','SHO',ARRAY['Nike','Adidas','Puma','Reebok'],1000,6000),
 (4,'book','BOO',ARRAY['Ранок','Фабула','Видавництво Старого Лева','КМ-Букс'],150,800)
) AS v(idx, category, prefix, brands, pmin, pmax);

–- Товари
INSERT INTO "Catalog"."Products"
    ("Sku","Name","Brand","Category","RatingAvg","RatingCount","CreatedAt")
SELECT x.prefix || '-' || lpad(x.n::text, 6, '0'),
       x.brand || ' ' || x.category || ' ' || x.n,
       x.brand,
       x.category,
       round((random()*2 + 3)::numeric, 1),
       floor(random()*501)::int,
       now() - floor(random()*366) * interval '1 day'
FROM (
    SELECT g.n, d.category, d.prefix,
           d.brands[1 + floor(random()*array_length(d.brands,1))::int] AS brand
    FROM (SELECT n, 1 + floor(random()*4)::int AS idx
          FROM generate_series(1,100000) AS n) g
    JOIN cat_def d ON d.idx = g.idx
) x
ORDER BY x.n;

-- Ціни й залишки по магазинах (1–3 випадкові магазини з 5)
INSERT INTO "Catalog"."ProductStores" ("ProductId","StoreId","Price","Stock")
SELECT b."Id", s."Id",
       GREATEST(1, b.base + floor(random()*401)::int - 200),
       floor(random()*51)::int
FROM (
    SELECT p."Id", d.pmin + floor(random()*(d.pmax - d.pmin + 1))::int AS base
    FROM "Catalog"."Products" p
    JOIN cat_def d ON d.category = p."Category"
) b
CROSS JOIN LATERAL (
    SELECT st."Id" FROM "Catalog"."Stores" st
    ORDER BY random()
    LIMIT 1 + floor(random()*3)::int
) s;

-- Характеристики (по категоріях)
INSERT INTO "Catalog"."ProductAttributes" ("ProductId","Name","ValueText","ValueNumber")
SELECT p."Id", a.n, a.t, a.v
FROM "Catalog"."Products" p
CROSS JOIN LATERAL (VALUES
  ('ram_gb',      NULL::text, (ARRAY[4,6,8,12])[1+floor(random()*4)::int]::numeric),
  ('storage_gb',  NULL,       (ARRAY[64,128,256,512])[1+floor(random()*4)::int]::numeric),
  ('battery_mah', NULL,       (3000 + floor(random()*3001))::numeric),
  ('os',          (ARRAY['Android','iOS'])[1+floor(random()*2)::int], NULL::numeric)
) AS a(n, t, v)
WHERE p."Category" = 'smartphone';

INSERT INTO "Catalog"."ProductAttributes" ("ProductId","Name","ValueText","ValueNumber")
SELECT p."Id", a.n, a.t, a.v
FROM "Catalog"."Products" p
CROSS JOIN LATERAL (VALUES
  ('cpu',         (ARRAY['i5','i7','Ryzen 5','Ryzen 7'])[1+floor(random()*4)::int], NULL::numeric),
  ('ram_gb',      NULL::text, (ARRAY[8,16,32])[1+floor(random()*3)::int]::numeric),
  ('screen_inch', NULL,       (ARRAY[13.3,14,15.6,17])[1+floor(random()*4)::int]::numeric),
  ('ssd_gb',      NULL,       (ARRAY[256,512,1024])[1+floor(random()*3)::int]::numeric)
) AS a(n, t, v)
WHERE p."Category" = 'laptop';

INSERT INTO "Catalog"."ProductAttributes" ("ProductId","Name","ValueText","ValueNumber")
SELECT p."Id", a.n, a.t, a.v
FROM "Catalog"."Products" p
CROSS JOIN LATERAL (VALUES
  ('size_eu',  NULL::text, (36 + floor(random()*11))::numeric),
  ('color',    (ARRAY['black','white','red','blue'])[1+floor(random()*4)::int], NULL::numeric),
  ('material', (ARRAY['leather','textile','mesh'])[1+floor(random()*3)::int], NULL::numeric),
  ('gender',   (ARRAY['M','F','U'])[1+floor(random()*3)::int], NULL::numeric)
) AS a(n, t, v)
WHERE p."Category" = 'shoes';

INSERT INTO "Catalog"."ProductAttributes" ("ProductId","Name","ValueText","ValueNumber")
SELECT p."Id", a.n, a.t, a.v
FROM "Catalog"."Products" p
CROSS JOIN LATERAL (VALUES
  ('author',   (ARRAY['Ж. Верн','І. Франко','Л. Українка','С. Жадан'])[1+floor(random()*4)::int], NULL::numeric),
  ('pages',    NULL::text, (80 + floor(random()*821))::numeric),
  ('language', (ARRAY['uk','en'])[1+floor(random()*2)::int], NULL::numeric),
  ('isbn',     '978-' || (100000000 + floor(random()*900000000))::bigint, NULL::numeric)
) AS a(n, t, v)
WHERE p."Category" = 'book';

-- Теги: по одному з двох наборів
INSERT INTO "Catalog"."ProductTags" ("ProductId","Tag")
SELECT p."Id", (ARRAY['new','sale','popular','eco'])[1+floor(random()*4)::int]
FROM "Catalog"."Products" p;
INSERT INTO "Catalog"."ProductTags" ("ProductId","Tag")
SELECT p."Id", (ARRAY['gift','premium','budget'])[1+floor(random()*3)::int]
FROM "Catalog"."Products" p;

-- Зображення (2 на товар)
INSERT INTO "Catalog"."ProductImages" ("ProductId","SortOrder","Url")
SELECT p."Id", k, 'img/' || p."Id" || '-' || k || '.jpg'
FROM "Catalog"."Products" p
CROSS JOIN generate_series(1,2) AS k;

ANALYZE "Catalog"."Products"; ANALYZE "Catalog"."ProductAttributes";
ANALYZE "Catalog"."ProductStores"; ANALYZE "Catalog"."ProductTags";
ANALYZE "Catalog"."ProductImages";
