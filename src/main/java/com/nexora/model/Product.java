package com.nexora.model;

import java.math.BigDecimal;

public class Product {
    private int productId;
    private String productName;
    private String description;
    private BigDecimal price;
    private int stockQty;
    private String categoryName;
    private String imageUrl;

    // පරණ constructor එක (ProductDAO ඒක පාවිච්චි කරනවා නම් කැඩෙන්නේ නැහැ)
    public Product(int productId, String productName, String description,
                   BigDecimal price, int stockQty, String categoryName) {
        this(productId, productName, description, price, stockQty, categoryName, null);
    }

    // අලුත් constructor එක (imageUrl එක්ක)
    public Product(int productId, String productName, String description,
                   BigDecimal price, int stockQty, String categoryName, String imageUrl) {
        this.productId = productId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.stockQty = stockQty;
        this.categoryName = categoryName;
        this.imageUrl = imageUrl;
    }

    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public String getDescription() { return description; }
    public BigDecimal getPrice() { return price; }
    public int getStockQty() { return stockQty; }
    public String getCategoryName() { return categoryName; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}