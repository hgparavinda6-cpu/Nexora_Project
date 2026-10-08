package com.nexora.pattern.strategy;

import java.math.BigDecimal;

public class StandardDelivery implements DeliveryFeeStrategy {
    @Override public String getName() { return "Standard"; }
    @Override public String getDescription() { return "3-5 working days - FREE"; }
    @Override public BigDecimal calculateFee(BigDecimal subtotal) { return BigDecimal.ZERO; }
}
