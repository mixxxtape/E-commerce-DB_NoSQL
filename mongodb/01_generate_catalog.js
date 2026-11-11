// генерація каталогу товарів (100 000 документів) у MongoDB.

use("ecommerce_nosql");

db.products.drop();
db.stores.drop();

db.stores.insertMany([
  { _id: 1, name: "Магазин Київ-Центр", city: "Київ" },
  { _id: 2, name: "Магазин Львів", city: "Львів" },
  { _id: 3, name: "Магазин Одеса", city: "Одеса" },
  { _id: 4, name: "Магазин Харків", city: "Харків" },
  { _id: 5, name: "Онлайн-склад", city: "Київ" }
]);

const rnd = (a, b) => Math.floor(Math.random() * (b - a + 1)) + a;
const pick = arr => arr[rnd(0, arr.length - 1)];

const categories = {
  smartphone: {
    prefix: "SMA", brands: ["Samsung", "Apple", "Xiaomi", "Motorola"], price: [5000, 50000],
    attrs: () => ({ ram_gb: pick([4, 6, 8, 12]), storage_gb: pick([64, 128, 256, 512]),
                    battery_mah: rnd(3000, 6000), os: pick(["Android", "iOS"]) })
  },
  laptop: {
    prefix: "LAP", brands: ["Lenovo", "HP", "Asus", "Dell"], price: [15000, 90000],
    attrs: () => ({ cpu: pick(["i5", "i7", "Ryzen 5", "Ryzen 7"]), ram_gb: pick([8, 16, 32]),
                    screen_inch: pick([13.3, 14, 15.6, 17]), ssd_gb: pick([256, 512, 1024]) })
  },
  shoes: {
    prefix: "SHO", brands: ["Nike", "Adidas", "Puma", "Reebok"], price: [1000, 6000],
    attrs: () => ({ size_eu: rnd(36, 46), color: pick(["black", "white", "red", "blue"]),
                    material: pick(["leather", "textile", "mesh"]), gender: pick(["M", "F", "U"]) })
  },
  book: {
    prefix: "BOO", brands: ["Ранок", "Фабула", "Видавництво Старого Лева", "КМ-Букс"], price: [150, 800],
    attrs: () => ({ author: pick(["Ж. Верн", "І. Франко", "Л. Українка", "С. Жадан"]),
                    pages: rnd(80, 900), language: pick(["uk", "en"]), isbn: "978-" + rnd(100000000, 999999999) })
  }
};

const catNames = Object.keys(categories);
const TOTAL = 100000, BATCH = 5000;

for (let i = 0; i < TOTAL; i += BATCH) {
  const docs = [];
  for (let j = 0; j < BATCH; j++) {
    const n = i + j + 1;
    const cat = pick(catNames), c = categories[cat], brand = pick(c.brands);
    const basePrice = rnd(c.price[0], c.price[1]);
    const storeIds = [1, 2, 3, 4, 5].sort(() => Math.random() - 0.5).slice(0, rnd(1, 3));
    docs.push({
      sku: c.prefix + "-" + String(n).padStart(6, "0"),
      name: brand + " " + cat + " " + n,
      brand: brand,
      category: cat,
      attributes: c.attrs(),
      tags: [pick(["new", "sale", "popular", "eco"]), pick(["gift", "premium", "budget"])],
      images: ["img/" + n + "-1.jpg", "img/" + n + "-2.jpg"],
      stores: storeIds.map(id => ({ storeId: id, price: Math.max(1, basePrice + rnd(-200, 200)), stock: rnd(0, 50) })),
      rating: { avg: Math.round((Math.random() * 2 + 3) * 10) / 10, count: rnd(0, 500) },
      createdAt: new Date(Date.now() - rnd(0, 365) * 86400000)
    });
  }
  db.products.insertMany(docs);
}

db.products.createIndex({ sku: 1 }, { unique: true });
print("Готово: " + db.products.countDocuments() + " товарів");
