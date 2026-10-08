package com.nexora.pattern.strategy;

import java.math.BigDecimal;

public class ExpressDelivery implements DeliveryFeeStrategy {
    @Override public String getName() { return "Express"; }
    @Override public String getDescription() { return "1-2 working days - Rs. 450"; }
    @Override public BigDecimal calculateFee(BigDecimal subtotal) { return new BigDecimal("450.00"); }
}