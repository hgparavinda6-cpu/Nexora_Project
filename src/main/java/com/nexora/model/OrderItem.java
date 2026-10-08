package com.nexora.model;

import java.math.BigDecimal;

public class OrderItem {
    private int productId;
    private String productName;
    private BigDecimal unitPrice;
    private int quantity;

    public OrderItem(int productId, String productName, BigDecimal unitPrice, int quantity) {
        this.productId = productId;
        this.productName = productName;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
    }

    public OrderItem(String productName, BigDecimal unitPrice, int quantity) {
        this(0, productName, unitPrice, quantity);
    }

    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public int getQuantity() { return quantity; }
    public BigDecimal getSubtotal() { return unitPrice.multiply(BigDecimal.valueOf(quantity)); }
}
