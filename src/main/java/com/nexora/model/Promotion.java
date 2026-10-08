package com.nexora.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Promotion {
    private int promoId;
    private String code, title, type, startDate, endDate;
    private BigDecimal value, minOrder;
    private boolean active;

    public Promotion(int promoId, String code, String title, String type, BigDecimal value,
                     BigDecimal minOrder, String startDate, String endDate, boolean active) {
        this.promoId = promoId;
        this.code = code;
        this.title = title;
        this.type = type;
        this.value = value;
        this.minOrder = minOrder;
        this.startDate = startDate;
        this.endDate = endDate;
        this.active = active;
    }

    public int getPromoId() { return promoId; }
    public String getCode() { return code; }
    public String getTitle() { return title; }
    public String getType() { return type; }
    public BigDecimal getValue() { return value; }
    public BigDecimal getMinOrder() { return minOrder; }
    public String getStartDate() { return startDate; }
    public String getEndDate() { return endDate; }
    public boolean isActive() { return active; }

    // "10%" හෝ "Rs. 500.00"
    public String getValueText() {
        return "Percent".equals(type) ? value.stripTrailingZeros().toPlainString() + "%"
                : "Rs. " + value.toPlainString();
    }

    public String getStatus() {
        if (!active) return "Disabled";
        LocalDate today = LocalDate.now();
        if (today.isBefore(LocalDate.parse(startDate))) return "Upcoming";
        if (today.isAfter(LocalDate.parse(endDate))) return "Expired";
        return "Active";
    }
}
