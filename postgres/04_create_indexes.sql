-- Індекси для сценаріїв Т2, Т3 (ProductAttributes, Products) і Т6 (ProductStores)
CREATE INDEX "IX_Catalog_Products_Category" ON "Catalog"."Products" ("Category");
CREATE INDEX "IX_Catalog_PA_Name_ValueNumber"
  ON "Catalog"."ProductAttributes" ("Name", "ValueNumber", "ProductId");
CREATE INDEX "IX_Catalog_PS_Store_Price" ON "Catalog"."ProductStores" ("StoreId", "Price");
ANALYZE "Catalog"."Products"; ANALYZE "Catalog"."ProductAttributes"; ANALYZE "Catalog"."ProductStores";
