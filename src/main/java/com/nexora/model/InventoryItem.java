package com.nexora.model;

public class InventoryItem {
    private int productId;
    private String productName;
    private String categoryName;
    private int stockQty;
    private int lowStockLevel;

    public InventoryItem(int productId, String productName, String categoryName,
                         int stockQty, int lowStockLevel) {
        this.productId = productId;
        this.productName = productName;
        this.categoryName = categoryName;
        this.stockQty = stockQty;
        this.lowStockLevel = lowStockLevel;
    }

    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public String getCategoryName() { return categoryName; }
    public int getStockQty() { return stockQty; }
    public int getLowStockLevel() { return lowStockLevel; }

    public String getStatus() {
        if (stockQty == 0) return "Out of stock";
        if (stockQty <= lowStockLevel) return "Low";
        return "OK";
    }
}
