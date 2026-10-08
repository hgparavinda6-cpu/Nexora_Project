package com.nexora.model;

import java.math.BigDecimal;

public class Delivery {
    private int deliveryId, orderId;
    private String customerName, customerPhone, address, items;
    private BigDecimal total;
    private String paymentMethod, status, notes, staffName, updatedAt;

    public Delivery(int deliveryId, int orderId, String customerName, String customerPhone,
                    String address, String items, BigDecimal total, String paymentMethod,
                    String status, String notes, String staffName, String updatedAt) {
        this.deliveryId = deliveryId;
        this.orderId = orderId;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.address = address;
        this.items = items;
        this.total = total;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.notes = notes;
        this.staffName = staffName;
        this.updatedAt = updatedAt;
    }

    public int getDeliveryId() { return deliveryId; }
    public int getOrderId() { return orderId; }
    public String getCustomerName() { return customerName; }
    public String getCustomerPhone() { return customerPhone; }
    public String getAddress() { return address; }
    public String getItems() { return items; }
    public BigDecimal getTotal() { return total; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getStatus() { return status; }
    public String getNotes() { return notes; }
    public String getStaffName() { return staffName; }
    public String getUpdatedAt() { return updatedAt; }
}