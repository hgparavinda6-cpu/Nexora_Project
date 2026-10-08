<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, java.math.BigDecimal, com.nexora.model.CartItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Shopping Cart</title>
<style>
.cart-header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-top: 32px;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 12px;
}

.cart-header h1 {
    margin: 0;
}

.cart-layout {
    display: grid;
    grid-template-columns: 1fr 360px;
    gap: 32px;
    align-items: start;
    margin-bottom: 60px;
}

.cart-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    box-shadow: var(--nx-shadow-sm);
    overflow: hidden;
}

.cart-table-wrap {
    overflow-x: auto;
}

.cart-item-row td {
    padding: 18px 20px;
    vertical-align: middle;
}

.cart-prod-cell {
    display: flex;
    align-items: center;
    gap: 14px;
}

.cart-prod-icon {
    width: 48px;
    height: 48px;
    border-radius: 10px;
    background: linear-gradient(135deg, #0E3B43, #165662);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #FFFFFF;
    font-weight: 800;
    font-size: 20px;
    flex-shrink: 0;
}

.cart-prod-title {
    font-weight: 700;
    font-size: 15px;
    color: var(--nx-text);
}

.cart-summary-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 26px;
    box-shadow: var(--nx-shadow-sm);
    position: sticky;
    top: 90px;
}

.summary-title {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--nx-border);
}

.summary-line {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    font-size: 14.5px;
    color: var(--nx-text-muted);
}

.summary-line.total {
    font-size: 19px;
    font-weight: 800;
    color: var(--nx-text);
    margin-top: 18px;
    padding-top: 16px;
    border-top: 2px dashed var(--nx-border);
}

.btn-checkout {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    margin-top: 24px;
    padding: 14px 20px;
    font-size: 15.5px;
    background: linear-gradient(135deg, var(--nx-brand), #165662);
    box-shadow: 0 4px 14px rgba(14, 59, 67, 0.25);
}

.btn-checkout:hover {
    background: linear-gradient(135deg, #14525D, #1B6876);
}

.cart-security-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin-top: 18px;
    font-size: 12px;
    color: var(--nx-text-muted);
}

/* Empty state */
.cart-empty {
    background: #FFFFFF;
    border: 1px dashed var(--nx-border-strong);
    border-radius: var(--nx-radius-xl);
    padding: 70px 24px;
    text-align: center;
    max-width: 520px;
    margin: 40px auto;
}

.cart-empty-icon {
    width: 72px;
    height: 72px;
    background: #F1F5F9;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
    color: var(--nx-text-muted);
}

/* Inline quantity validation message */
.qty-error {
    display: block;
    color: #b91c1c;
    font-size: 12px;
    margin-top: 6px;
    max-width: 170px;
}

input.invalid {
    border-color: #b91c1c !important;
}

@media (max-width: 900px) {
    .cart-layout {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="cart-header">
    <h1>Shopping Cart</h1>
    <a href="shop" style="display: inline-flex; align-items: center; gap: 6px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
        Continue Shopping
    </a>
</div>

<% String cartErr = request.getParameter("error");
   if (cartErr != null) {
       String cartMsg;
       if ("qty".equals(cartErr))          cartMsg = "Quantity must be a whole number of 1 or more.";
       else if ("invalid".equals(cartErr)) cartMsg = "Invalid request. Please try again.";
       else                                cartMsg = "Not enough inventory stock available for requested quantity.";
%>
    <p style="color:red">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        <%= cartMsg %>
    </p>
<% } %>

<% List<CartItem> items = (List<CartItem>) request.getAttribute("items");
   if (items == null || items.isEmpty()) { %>
    <div class="cart-empty">
        <div class="cart-empty-icon">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
        </div>
        <h2 style="font-size: 22px; margin-bottom: 8px;">Your cart is currently empty</h2>
        <p style="color: var(--nx-text-muted); font-size: 14.5px; margin-bottom: 24px;">Discover trending items, premium selections, and place an order now.</p>
        <a href="shop" class="btn">Explore Catalogue</a>
    </div>
<% } else { %>
<div class="cart-layout">
    <div class="cart-card">
        <div class="cart-table-wrap">
            <table style="margin: 0; border: none; border-radius: 0; box-shadow: none;">
                <thead>
                    <tr>
                        <th>Product Item</th>
                        <th>Price</th>
                        <th>Quantity</th>
                        <th>Subtotal</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (CartItem i : items) {
                        String prodName = i.getProductName();
                        String initial = prodName != null && !prodName.isEmpty() ? prodName.substring(0, 1).toUpperCase() : "P";
                    %>
                    <tr class="cart-item-row">
                        <td>
                            <div class="cart-prod-cell">
                                <div class="cart-prod-icon"><%= initial %></div>
                                <div class="cart-prod-title"><%= prodName == null ? "" : prodName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") %></div>
                            </div>
                        </td>
                        <td style="font-weight: 600;">Rs. <%= i.getPrice() %></td>
                        <td>
                            <form action="cart" method="post" novalidate onsubmit="return checkQty(this);"
                                  style="display:inline-flex; align-items:center; gap:6px;">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="productId" value="<%= i.getProductId() %>">
                                <input type="number" name="quantity" min="1" max="<%= i.getStockQty() %>" step="1"
                                       value="<%= i.getQuantity() %>" style="width:68px; text-align:center; padding: 6px;">
                                <button type="submit" style="padding: 7px 12px; font-size: 12px;">Update</button>
                            </form>
                            <span class="qty-error"></span>
                        </td>
                        <td style="font-weight: 700; color: #0E3B43;">Rs. <%= i.getSubtotal() %></td>
                        <td style="text-align: right;">
                            <form action="cart" method="post" style="display:inline">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="productId" value="<%= i.getProductId() %>">
                                <button type="submit" style="padding: 6px 12px; font-size: 12.5px;">Remove</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="cart-summary-card">
        <div class="summary-title">Order Summary</div>
        <div class="summary-line">
            <span>Items Count</span>
            <span style="font-weight: 600;"><%= items.size() %> items</span>
        </div>
        <div class="summary-line">
            <span>Subtotal</span>
            <span style="font-weight: 600;">Rs. <%= request.getAttribute("total") %></span>
        </div>
        <div class="summary-line">
            <span>Estimated Shipping</span>
            <span style="color: #059669; font-weight: 700;">FREE</span>
        </div>
        <div class="summary-line total">
            <span>Total Payable</span>
            <span style="color: #0E3B43;">Rs. <%= request.getAttribute("total") %></span>
        </div>

        <a href="checkout" style="text-decoration: none;">
            <button type="button" class="btn-checkout">
                <span>Proceed to Checkout</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
            </button>
        </a>

        <div class="cart-security-badge">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            <span>Guaranteed Safe &amp; Secure Checkout</span>
        </div>
    </div>
</div>
<% } %>

<script>
function checkQty(f) {
    var input = f.elements['quantity'];
    var max = parseInt(input.max, 10);
    var v = input.value.trim();
    var box = f.parentElement.querySelector('.qty-error');
    var msg = '';

    if (!/^\d+$/.test(v)) {
        msg = 'Enter a whole number of 1 or more.';
    } else {
        var n = parseInt(v, 10);
        if (n < 1) {
            msg = 'Quantity must be at least 1.';
        } else if (n > max) {
            msg = 'Only ' + max + ' in stock.';
        }
    }

    box.innerText = msg;
    input.classList.toggle('invalid', msg !== '');
    return msg === '';
}
</script>
</body>
</html>