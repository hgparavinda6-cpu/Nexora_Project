package com.nexora.pattern.decorator;

import java.math.BigDecimal;

public class InsuranceDecorator extends AddOnDecorator {

    public InsuranceDecorator(OrderCost wrapped) { super(wrapped); }

    @Override protected BigDecimal addOnFee() { return new BigDecimal("150.00"); }
    @Override protected String addOnName() { return "Insurance"; }
}