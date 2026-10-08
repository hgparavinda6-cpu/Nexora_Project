package com.nexora.model;

import java.math.BigDecimal;

public class CartItem {
    private int productId;
    private String productName;
    private BigDecimal price;
    private int quantity;
    private int stockQty;

    public CartItem(int productId, String productName, BigDecimal price,
                    int quantity, int stockQty) {
        this.productId = productId;
        this.productName = productName;
        this.price = price;
        this.quantity = quantity;
        this.stockQty = stockQty;
    }

    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public BigDecimal getPrice() { return price; }
    public int getQuantity() { return quantity; }
    public int getStockQty() { return stockQty; }

    public BigDecimal getSubtotal() {
        return price.multiply(BigDecimal.valueOf(quantity));
    }
}
