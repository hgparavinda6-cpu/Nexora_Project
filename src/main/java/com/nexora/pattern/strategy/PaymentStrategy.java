package com.nexora.pattern.strategy;

/** Strategy interface: payment method එකක් කරන්න ඕන දේවල් */
public interface PaymentStrategy {
    String getMethodName();      // DB එකේ ගබඩා වෙන නම
    String getInstructions();    // Checkout page එකේ පෙන්නන කෙටි විස්තරය
    String pay(int orderId);     // Order එක සඳහා payment process කරනවා
}