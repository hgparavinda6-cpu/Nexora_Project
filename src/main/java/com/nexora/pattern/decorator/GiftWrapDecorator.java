package com.nexora.pattern.decorator;

import java.math.BigDecimal;

public class GiftWrapDecorator extends AddOnDecorator {

    public GiftWrapDecorator(OrderCost wrapped) { super(wrapped); }

    @Override protected BigDecimal addOnFee() { return new BigDecimal("250.00"); }
    @Override protected String addOnName() { return "Gift Wrap"; }
}