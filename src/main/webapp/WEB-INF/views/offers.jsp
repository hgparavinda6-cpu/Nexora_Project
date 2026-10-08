<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Promotion" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Exclusive Deals & Offers</title>
<style>
.offers-hero {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 60%, #165662 100%);
    border-radius: var(--nx-radius-xl);
    padding: 38px 36px;
    margin-top: 32px;
    margin-bottom: 36px;
    color: #FFFFFF;
    box-shadow: var(--nx-shadow-lg);
}

.offers-hero h1 {
    color: #FFFFFF;
    margin-top: 0;
    margin-bottom: 8px;
    font-size: 32px;
}

.offers-hero p {
    color: #CFE3E5;
    margin-bottom: 0;
    font-size: 15px;
    max-width: 560px;
}

.coupons-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    margin-bottom: 60px;
}

.coupon-ticket {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    box-shadow: var(--nx-shadow-sm);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: relative;
    transition: all 0.25s ease;
}

.coupon-ticket:hover {
    transform: translateY(-4px);
    box-shadow: var(--nx-shadow-hover);
    border-color: #0E3B43;
}

.ticket-header {
    background: linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%);
    padding: 20px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 2px dashed #CBD5E1;
}

.ticket-discount {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 26px;
    font-weight: 800;
    color: #065F46;
}

.ticket-body {
    padding: 24px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.ticket-title {
    font-size: 17px;
    font-weight: 700;
    margin-bottom: 8px;
    color: var(--nx-text);
}

.ticket-rules {
    font-size: 13.5px;
    color: var(--nx-text-muted);
    margin-bottom: 20px;
    line-height: 1.5;
}

.ticket-code-row {
    margin-top: auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--nx-card-subtle);
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-sm);
    padding: 8px 12px;
}

.ticket-code {
    font-family: 'Courier New', Courier, monospace;
    font-size: 16px;
    font-weight: 800;
    letter-spacing: 0.08em;
    color: #0E3B43;
}

.btn-copy {
    background: var(--nx-brand);
    color: #FFFFFF;
    border: none;
    padding: 6px 12px;
    font-size: 12px;
    border-radius: 6px;
    cursor: pointer;
    box-shadow: none;
}

.btn-copy:hover {
    background: #14525D;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="offers-hero">
    <h1>Exclusive Promo Vouchers</h1>
    <p>Apply these promotional codes during checkout to receive special savings on your orders.</p>
</div>

<% List<Promotion> list = (List<Promotion>) request.getAttribute("promotions");
   if (list == null || list.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 60px 20px; margin-bottom: 50px;">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--nx-text-muted); margin-bottom: 16px;"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
        <h2 style="font-size: 20px; margin-bottom: 6px;">No Active Offers at this moment</h2>
        <p style="color: var(--nx-text-muted); font-size: 14px; margin-bottom: 20px;">Check back shortly for new holiday promotions and discounts.</p>
        <a href="shop" class="btn">Explore Storefront</a>
    </div>
<% } else { %>
<div class="coupons-grid">
    <% for (Promotion p : list) { %>
    <div class="coupon-ticket">
        <div class="ticket-header">
            <span class="ticket-discount"><%= p.getValueText() %> OFF</span>
            <span class="nx-badge badge-delivered">Verified Active</span>
        </div>
        <div class="ticket-body">
            <div class="ticket-title"><%= p.getTitle() %></div>
            <div class="ticket-rules">
                <span>Minimum Order: <b><%= p.getMinOrder().signum() == 0 ? "No minimum" : "Rs. " + p.getMinOrder() %></b></span><br>
                <span>Valid Until: <b><%= p.getEndDate() %></b></span>
            </div>
            <div class="ticket-code-row">
                <span class="ticket-code"><%= p.getCode() %></span>
                <button type="button" class="btn-copy"
                        onclick="navigator.clipboard.writeText('<%= p.getCode() %>'); this.innerText='Copied!'; setTimeout(()=>this.innerText='Copy', 2000);">
                    Copy Code
                </button>
            </div>
        </div>
    </div>
    <% } %>
</div>
<% } %>

</body>
</html>