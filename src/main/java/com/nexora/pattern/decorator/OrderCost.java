package com.nexora.pattern.decorator;

import java.math.BigDecimal;

/** Component interface: ගාණ සහ විස්තරය */
public interface OrderCost {
    BigDecimal getCost();
    String getDescription();
}