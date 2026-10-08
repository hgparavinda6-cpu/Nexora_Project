package com.nexora.pattern.strategy;

public class CashOnDeliveryPayment implements PaymentStrategy {
    @Override public String getMethodName() { return "Cash on Delivery"; }
    @Override public String getInstructions() { return "Pay cash to the delivery staff at your door"; }
    @Override public String pay(int orderId) {
        return "Order #" + orderId + ": cash will be collected on delivery.";
    }
}