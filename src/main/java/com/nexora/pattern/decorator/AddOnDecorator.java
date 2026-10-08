package com.nexora.pattern.decorator;

import java.math.BigDecimal;

/** Decorator: තවත් OrderCost එකක් ඔතලා, ඒකට අමතර fee එකක් එකතු කරනවා */
public abstract class AddOnDecorator implements OrderCost {

    protected final OrderCost wrapped;

    protected AddOnDecorator(OrderCost wrapped) {
        this.wrapped = wrapped;
    }

    protected abstract BigDecimal addOnFee();
    protected abstract String addOnName();

    @Override
    public BigDecimal getCost() {
        return wrapped.getCost().add(addOnFee());
    }

    @Override
    public String getDescription() {
        String inner = wrapped.getDescription();
        return "None".equals(inner) ? addOnName() : inner + ", " + addOnName();
    }
}