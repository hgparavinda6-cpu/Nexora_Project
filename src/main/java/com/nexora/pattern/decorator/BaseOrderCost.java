package com.nexora.pattern.decorator;

import java.math.BigDecimal;

/** ConcreteComponent: add-ons නැති මුල් ගාණ */
public class BaseOrderCost implements OrderCost {

    private final BigDecimal amount;

    public BaseOrderCost(BigDecimal amount) {
        this.amount = amount;
    }

    @Override public BigDecimal getCost() { return amount; }
    @Override public String getDescription() { return "None"; }
}