package com.nexora.pattern.strategy;

public class CardPayment implements PaymentStrategy {
    @Override public String getMethodName() { return "Credit Card"; }
    @Override public String getInstructions() { return "Pay securely online with your card"; }
    @Override public String pay(int orderId) {
        return "Order #" + orderId + ": card payment authorised.";
    }
}