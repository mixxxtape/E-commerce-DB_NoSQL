// індекси для сценаріїв Т2, Т3 (характеристики) і Т6 (магазин + ціна).
use("ecommerce_nosql");
db.products.createIndex({category:1, "attributes.ram_gb":1, "attributes.storage_gb":1});
db.products.createIndex({"stores.storeId":1, "stores.price":1});
