package com.nexora.model;

public class SupportTicket {
    private final int ticketId;
    private final int userId;
    private final String customerName;
    private final Integer orderId;      // අදාළ order එක නැත්නම් null
    private final String subject;
    private final String message;
    private final String status;        // Open / In Progress / Resolved
    private final String reply;         // තාම reply නැත්නම් ""
    private final String createdAt;
    private final String updatedAt;

    public SupportTicket(int ticketId, int userId, String customerName, Integer orderId,
                         String subject, String message, String status, String reply,
                         String createdAt, String updatedAt) {
        this.ticketId = ticketId;
        this.userId = userId;
        this.customerName = customerName;
        this.orderId = orderId;
        this.subject = subject;
        this.message = message;
        this.status = status;
        this.reply = reply == null ? "" : reply;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getTicketId() { return ticketId; }
    public int getUserId() { return userId; }
    public String getCustomerName() { return customerName; }
    public Integer getOrderId() { return orderId; }
    public String getSubject() { return subject; }
    public String getMessage() { return message; }
    public String getStatus() { return status; }
    public String getReply() { return reply; }
    public String getCreatedAt() { return createdAt; }
    public String getUpdatedAt() { return updatedAt; }
}