package com.nexora.pattern.strategy;

import java.math.BigDecimal;

/** Strategy interface: delivery fee එක ගණන් කරන ක්‍රමය */
public interface DeliveryFeeStrategy {
    String getName();
    String getDescription();
    BigDecimal calculateFee(BigDecimal subtotal);
}
