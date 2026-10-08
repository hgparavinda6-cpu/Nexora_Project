package com.nexora.pattern.strategy;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Factory: payment method නමට අනුව හරි PaymentStrategy object එක හදලා දෙනවා */
public class PaymentStrategyFactory {

    public static PaymentStrategy create(String method) {
        if (method == null) {
            throw new IllegalArgumentException("Payment method is required");
        }
        switch (method) {
            case "Credit Card":      return new CardPayment();
            case "Cash on Delivery": return new CashOnDeliveryPayment();
            case "Bank Transfer":    return new BankTransferPayment();
            default: throw new IllegalArgumentException("Unknown payment method: " + method);
        }
    }

    public static List<String> getMethodNames() {
        List<String> names = new ArrayList<>();
        names.add("Credit Card");
        names.add("Cash on Delivery");
        names.add("Bank Transfer");
        return names;
    }

    public static boolean isSupported(String method) {
        return method != null && getMethodNames().contains(method);
    }

    // Checkout page එකේ පෙන්නන්න: method නම -> විස්තරය
    public static Map<String, String> getDescriptions() {
        Map<String, String> map = new LinkedHashMap<>();
        for (String n : getMethodNames()) {
            map.put(n, create(n).getInstructions());
        }
        return map;
    }
}