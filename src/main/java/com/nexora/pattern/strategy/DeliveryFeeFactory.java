package com.nexora.pattern.strategy;

import java.util.ArrayList;
import java.util.List;

/** Factory: delivery type එකේ නමට අනුව හරි fee strategy එක හදලා දෙනවා */
public class DeliveryFeeFactory {

    public static DeliveryFeeStrategy create(String type) {
        if (type == null) {
            return new StandardDelivery();
        }
        switch (type) {
            case "Express":  return new ExpressDelivery();
            case "Standard": return new StandardDelivery();
            default: throw new IllegalArgumentException("Unknown delivery type: " + type);
        }
    }

    public static boolean isSupported(String type) {
        return "Standard".equals(type) || "Express".equals(type);
    }

    public static List<DeliveryFeeStrategy> getAll() {
        List<DeliveryFeeStrategy> list = new ArrayList<>();
        list.add(new StandardDelivery());
        list.add(new ExpressDelivery());
        return list;
    }
}