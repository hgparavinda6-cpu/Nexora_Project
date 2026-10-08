package com.nexora.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Order {
    private int orderId;
    private BigDecimal total;
    private String status;
    private String paymentMethod;
    private String address;
    private String createdAt;
    private List<OrderItem> items = new ArrayList<>();

    public Order(int orderId, BigDecimal total, String status, String paymentMethod,
                 String address, String createdAt) {
        this.orderId = orderId;
        this.total = total;
        this.status = status;
        this.paymentMethod = paymentMethod;
        this.address = address;
        this.createdAt = createdAt;
    }

    public int getOrderId() { return orderId; }
    public BigDecimal getTotal() { return total; }
    public String getStatus() { return status; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getAddress() { return address; }
    public String getCreatedAt() { return createdAt; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
}
