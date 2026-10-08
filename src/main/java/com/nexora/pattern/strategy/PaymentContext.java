package com.nexora.pattern.strategy;

/** Context: තෝරපු strategy එක තියාගෙන checkout කරනවා */
public class PaymentContext {

    private PaymentStrategy strategy;

    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public String checkout(int orderId) {
        return strategy.pay(orderId);
    }
}