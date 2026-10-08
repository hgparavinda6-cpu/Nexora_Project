package com.nexora.model;

public class Feedback {
    private final int feedbackId;
    private final String customerName;
    private final int productId;
    private final String productName;
    private final Integer orderId;
    private final int rating;
    private final String comment;
    private final String createdAt;

    public Feedback(int feedbackId, String customerName, int productId, String productName,
                    Integer orderId, int rating, String comment, String createdAt) {
        this.feedbackId = feedbackId;
        this.customerName = customerName;
        this.productId = productId;
        this.productName = productName;
        this.orderId = orderId;
        this.rating = rating;
        this.comment = comment == null ? "" : comment;
        this.createdAt = createdAt;
    }

    public int getFeedbackId() { return feedbackId; }
    public String getCustomerName() { return customerName; }
    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public Integer getOrderId() { return orderId; }
    public int getRating() { return rating; }
    public String getComment() { return comment; }
    public String getCreatedAt() { return createdAt; }
}
