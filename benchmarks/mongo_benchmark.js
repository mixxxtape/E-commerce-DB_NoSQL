// Т1–Т6
// Метод: прогрів + 5 запусків, у таблицю береться медіана (median_ms).

use("ecommerce_nosql");

function bench(fn, runs = 5) {
  fn(); 
  const t = [];
  for (let i = 0; i < runs; i++) { const s = Date.now(); fn(); t.push(Date.now() - s); }
  t.sort((a, b) => a - b);
  return { median_ms: t[Math.floor(runs / 2)], min: t[0], max: t[runs - 1] };
}

// Т1. Картка за артикулом 
const sku = db.products.findOne({category:"smartphone"}).sku;
bench(() => db.products.findOne({sku}));
db.products.find({sku}).explain("executionStats")

// Т2. Категорія + 1 характеристика 
bench(() => db.products.countDocuments({category:"smartphone","attributes.ram_gb":8}));
db.products.find({category:"smartphone","attributes.ram_gb":8}).explain("executionStats")

//  Т3. Категорія + 2 характеристики 
bench(() => db.products.countDocuments({category:"smartphone","attributes.ram_gb":8,"attributes.storage_gb":256}));

// Т4. 1000 карток 
bench(() => db.products.find().limit(1000).toArray());

// Т5. Середня ціна за категорією 
bench(() => db.products.aggregate([
  {$unwind:"$stores"},
  {$group:{_id:"$category", avgPrice:{$avg:"$stores.price"}, n:{$sum:1}}}
]).toArray());

// Т6. Дешеві товари в магазині 1 
bench(() => db.products.countDocuments({stores:{$elemMatch:{storeId:1, price:{$lt:300}, stock:{$gt:0}}}}));

//  Розміри даних 
db.products.stats()  // dataSize, storageSize, totalIndexSize
