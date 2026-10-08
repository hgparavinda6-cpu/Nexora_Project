<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, java.math.BigDecimal, com.nexora.model.CartItem" %>
<%!
    static String esc(String s) {
        return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;")
                                 .replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Secure Checkout</title>
<style>
.checkout-steps {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 16px;
    margin: 32px 0 36px;
}

.step-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-weight: 600;
    color: var(--nx-text-muted);
}

.step-item.active {
    color: var(--nx-brand);
}

.step-number {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: var(--nx-card-subtle);
    border: 1px solid var(--nx-border);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 700;
}

.step-item.active .step-number {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}

.step-divider {
    width: 40px;
    height: 2px;
    background: var(--nx-border);
}

.checkout-grid {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 32px;
    align-items: start;
    margin-bottom: 60px;
}

.checkout-section {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 24px;
    margin-bottom: 24px;
    box-shadow: var(--nx-shadow-sm);
}

.section-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 18px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--nx-border);
}

.section-head h3 {
    margin: 0;
    font-size: 18px;
}

.section-icon {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: #F0FDF4;
    color: #166534;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* Payment tiles */
.payment-tiles {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
}

.payment-label {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 14px 16px;
    border: 2px solid var(--nx-border);
    border-radius: var(--nx-radius);
    cursor: pointer;
    font-weight: 600;
    font-size: 14.5px;
    transition: all 0.2s ease;
}

.payment-label:hover {
    border-color: #B4D1D6;
    background: #F8FAFC;
}

.payment-label input[type="radio"]:checked + span,
.payment-label input[type="checkbox"]:checked + span {
    color: var(--nx-brand);
}

/* Promo input group */
.promo-group {
    display: flex;
    gap: 8px;
    margin-top: 8px;
}

.promo-group input {
    flex: 1;
    text-transform: uppercase;
    font-weight: 600;
}

/* Summary Box */
.summary-box {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 26px;
    box-shadow: var(--nx-shadow-sm);
    position: sticky;
    top: 90px;
}

.mini-items-list {
    margin-bottom: 20px;
    max-height: 240px;
    overflow-y: auto;
}

.mini-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid var(--nx-border-subtle);
    font-size: 13.5px;
}

.mini-item-name {
    font-weight: 600;
    color: var(--nx-text);
}

.mini-item-qty {
    color: var(--nx-text-muted);
    font-size: 12.5px;
}

.btn-place-order {
    width: 100%;
    margin-top: 20px;
    padding: 15px 24px;
    font-size: 16px;
    background: linear-gradient(135deg, #0E3B43, #165662);
    box-shadow: 0 4px 14px rgba(14, 59, 67, 0.25);
}

@media (max-width: 900px) {
    .checkout-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="checkout-steps">
    <div class="step-item">
        <span class="step-number">&#10003;</span>
        <span>Cart</span>
    </div>
    <div class="step-divider"></div>
    <div class="step-item active">
        <span class="step-number">2</span>
        <span>Shipping & Payment</span>
    </div>
    <div class="step-divider"></div>
    <div class="step-item">
        <span class="step-number">3</span>
        <span>Confirmation</span>
    </div>
</div>

<% boolean applied = (Boolean) request.getAttribute("promoApplied");
   BigDecimal discount = (BigDecimal) request.getAttribute("discount");
   String promoError = (String) request.getAttribute("promoError");
   BigDecimal addOnFee = (BigDecimal) request.getAttribute("addOnFee");
   boolean giftWrapOn = (Boolean) request.getAttribute("giftWrap");
   boolean insuranceOn = (Boolean) request.getAttribute("insurance");
   // Add-on fee අගයන් Decorator classes වලින්ම ගන්නවා
   BigDecimal giftWrapFee = com.nexora.pattern.decorator.AddOnBuilder.feeOf(BigDecimal.ZERO, true, false);
   BigDecimal insuranceFee = com.nexora.pattern.decorator.AddOnBuilder.feeOf(BigDecimal.ZERO, false, true);
   String refreshJs = "var h=document.createElement('input');h.type='hidden';h.name='step';h.value='refresh';this.form.appendChild(h);this.form.submit();"; %>

<form action="checkout" method="post" id="checkoutForm">
    <div class="checkout-grid">
        <div>
            <!-- Address Section -->
            <div class="checkout-section">
                <div class="section-head">
                    <div class="section-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                    </div>
                    <h3>1. Delivery Address</h3>
                </div>
                <label for="addressInput">Street Address, City & Landmark (Delivery staff will drop package here):</label>
                <textarea id="addressInput" name="address" rows="3" style="width: 100%;" required
                          placeholder="e.g. No. 45, Temple Road, Colombo 03"><%= esc((String) request.getAttribute("address")) %></textarea>
                <% if ("POST".equals(request.getMethod()) && "".equals(((String) request.getAttribute("address")).trim())
                       && !"apply".equals(request.getParameter("step"))
                       && !"refresh".equals(request.getParameter("step"))) { %>
                    <p style="color:red; margin-top: 8px;">Please enter a delivery address to proceed.</p>
                <% } %>
            </div>

            <!-- Delivery Option Section (Strategy pattern) -->
            <div class="checkout-section">
                <div class="section-head">
                    <div class="section-icon" style="background:#FFF7ED; color:#9A3412;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                    </div>
                    <h3>2. Delivery Option</h3>
                </div>
                <div class="payment-tiles">
                    <% List<com.nexora.pattern.strategy.DeliveryFeeStrategy> dOptions =
                               (List<com.nexora.pattern.strategy.DeliveryFeeStrategy>) request.getAttribute("deliveryOptions");
                       String selDelivery = (String) request.getAttribute("selectedDelivery");
                       for (com.nexora.pattern.strategy.DeliveryFeeStrategy dopt : dOptions) { %>
                        <label class="payment-label">
                            <input type="radio" name="deliveryType" value="<%= dopt.getName() %>"
                                   <%= dopt.getName().equals(selDelivery) ? "checked" : "" %>
                                   onchange="<%= refreshJs %>">
                            <span><%= dopt.getName() %><br><small style="font-weight:400; color:var(--nx-text-muted);"><%= dopt.getDescription() %></small></span>
                        </label>
                    <% } %>
                </div>
            </div>

            <!-- Add-ons Section (Decorator pattern) -->
            <div class="checkout-section">
                <div class="section-head">
                    <div class="section-icon" style="background:#FDF2F8; color:#9D174D;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 12 20 22 4 22 4 12"></polyline><rect x="2" y="7" width="20" height="5"></rect><line x1="12" y1="22" x2="12" y2="7"></line><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"></path><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"></path></svg>
                    </div>
                    <h3>3. Add-ons (optional)</h3>
                </div>
                <div class="payment-tiles">
                    <label class="payment-label">
                        <input type="checkbox" name="giftWrap" value="1" <%= giftWrapOn ? "checked" : "" %>
                               onchange="<%= refreshJs %>">
                        <span>Gift Wrap<br><small style="font-weight:400; color:var(--nx-text-muted);">+ Rs. <%= giftWrapFee %></small></span>
                    </label>
                    <label class="payment-label">
                        <input type="checkbox" name="insurance" value="1" <%= insuranceOn ? "checked" : "" %>
                               onchange="<%= refreshJs %>">
                        <span>Insurance<br><small style="font-weight:400; color:var(--nx-text-muted);">+ Rs. <%= insuranceFee %></small></span>
                    </label>
                </div>
            </div>

            <!-- Payment Method Section -->
            <div class="checkout-section">
                <div class="section-head">
                    <div class="section-icon" style="background:#EFF6FF; color:#1E40AF;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                    </div>
                    <h3>4. Payment Method</h3>
                </div>
                <div class="payment-tiles">
                    <% List<String> methods = (List<String>) request.getAttribute("methods");
                       String selected = (String) request.getAttribute("selectedPayment");
                       for (String m : methods) { %>
                        <label class="payment-label">
                            <input type="radio" name="paymentMethod" value="<%= m %>"
                                   <%= m.equals(selected) ? "checked" : "" %>>
                            <span><%= m %><br><small style="font-weight:400; color:var(--nx-text-muted);"><%= ((Map<String,String>) request.getAttribute("descriptions")).get(m) %></small></span>
                        </label>
                    <% } %>
                </div>
            </div>

            <!-- Coupon Code Section -->
            <div class="checkout-section">
                <div class="section-head">
                    <div class="section-icon" style="background:#FFFBEB; color:#92400E;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
                    </div>
                    <h3>5. Promo Coupon</h3>
                </div>
                <div class="promo-group">
                    <input type="text" name="promoCode" maxlength="20" placeholder="Enter coupon (e.g. SAVE10)"
                           value="<%= esc((String) request.getAttribute("promoCode")) %>">
                    <button type="submit" name="step" value="apply" class="btn-secondary">Apply Coupon</button>
                </div>
                <% if (applied) { %>
                    <p style="color:green; margin-top: 12px; margin-bottom: 0;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        Coupon applied! You save Rs. <%= discount %>
                    </p>
                <% } else if (promoError != null) { %>
                    <p style="color:red; margin-top: 12px; margin-bottom: 0;"><%= promoError %></p>
                <% } %>
                <p style="font-size: 13px; color: var(--nx-text-muted); margin-top: 10px; margin-bottom: 0;">
                    Check current promotions under <a href="offers">Current Offers</a>.
                </p>
            </div>
        </div>

        <!-- Summary Column -->
        <div class="summary-box">
            <h3 style="margin-top: 0; padding-bottom: 12px; border-bottom: 1px solid var(--nx-border);">Order Summary</h3>

            <div class="mini-items-list">
                <% for (CartItem i : (List<CartItem>) request.getAttribute("items")) { %>
                <div class="mini-item">
                    <div>
                        <div class="mini-item-name"><%= i.getProductName() %></div>
                        <div class="mini-item-qty"><%= i.getQuantity() %> &times; Rs. <%= i.getPrice() %></div>
                    </div>
                    <div style="font-weight: 700;">Rs. <%= i.getSubtotal() %></div>
                </div>
                <% } %>
            </div>

            <div style="display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14.5px; color: var(--nx-text-muted);">
                <span>Subtotal</span>
                <span>Rs. <%= request.getAttribute("subtotal") %></span>
            </div>

            <% if (applied) { %>
            <div style="display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14.5px; color: #059669; font-weight: 600;">
                <span>Coupon (<%= esc((String) request.getAttribute("promoCode")) %>)</span>
                <span>- Rs. <%= discount %></span>
            </div>
            <% } %>

            <% if (addOnFee.signum() > 0) { %>
            <div style="display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14.5px; color: var(--nx-text-muted);">
                <span>Add-ons (<%= esc((String) request.getAttribute("addOnDescription")) %>)</span>
                <span>+ Rs. <%= addOnFee %></span>
            </div>
            <% } %>

            <div style="display: flex; justify-content: space-between; margin-bottom: 16px; font-size: 14.5px; color: var(--nx-text-muted);">
                <span>Shipping Fee (<%= request.getAttribute("selectedDelivery") %>)</span>
                <span style="color: #059669; font-weight: 700;"><%= ((BigDecimal) request.getAttribute("shippingFee")).signum() == 0 ? "FREE" : "Rs. " + request.getAttribute("shippingFee") %></span>
            </div>

            <div style="display: flex; justify-content: space-between; padding-top: 16px; border-top: 2px dashed var(--nx-border); font-size: 19px; font-weight: 800; color: #0E3B43;">
                <span>Total to Pay</span>
                <span>Rs. <%= request.getAttribute("total") %></span>
            </div>

            <button type="submit" name="step" value="place" class="btn-place-order"
                    onclick="if (document.getElementById('addressInput').value.trim() === '') { alert('Please enter a delivery address.'); return false; }">
                Place Order Now
            </button>

            <div style="text-align: center; margin-top: 14px;">
                <a href="cart" style="font-size: 13.5px; color: var(--nx-text-muted);">&laquo; Back to Cart</a>
            </div>

            <div style="margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--nx-border); font-size: 12px; color: var(--nx-text-muted); display: flex; flex-direction: column; gap: 8px;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                    <span>256-Bit SSL Encrypted Transaction</span>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                    <span>Dispatch tracking on live map</span>
                </div>
            </div>
        </div>
    </div>
</form>

</body>
</html>