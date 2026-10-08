package com.nexora.pattern.strategy;

public class BankTransferPayment implements PaymentStrategy {
    @Override public String getMethodName() { return "Bank Transfer"; }
    @Override public String getInstructions() { return "Transfer the amount to our bank account"; }
    @Override public String pay(int orderId) {
        return "Order #" + orderId + ": awaiting bank transfer confirmation.";
    }
}