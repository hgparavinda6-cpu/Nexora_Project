package com.nexora.pattern.decorator;

import java.math.BigDecimal;

/** තෝරපු add-ons අනුව decorators ඔතනවා */
public class AddOnBuilder {

    public static OrderCost build(BigDecimal subtotal, boolean giftWrap, boolean insurance) {
        OrderCost cost = new BaseOrderCost(subtotal);
        if (giftWrap)  cost = new GiftWrapDecorator(cost);     // Base -> GiftWrap
        if (insurance) cost = new InsuranceDecorator(cost);    // GiftWrap -> Insurance
        return cost;
    }

    // Add-ons වලින් එකතු වුණ fee එක විතරක් (final - base)
    public static BigDecimal feeOf(BigDecimal subtotal, boolean giftWrap, boolean insurance) {
        return build(subtotal, giftWrap, insurance).getCost().subtract(subtotal);
    }

    // Order එකේ ගබඩා කරන විස්තරය: "Gift Wrap, Insurance" හෝ "None"
    public static String descriptionOf(BigDecimal subtotal, boolean giftWrap, boolean insurance) {
        return build(subtotal, giftWrap, insurance).getDescription();
    }
}