<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Order, com.nexora.model.OrderItem, com.nexora.model.Delivery" %>
<%!
    private static String hx(Object o) {
        if (o == null) return "";
        return o.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - My Orders</title>
<style>
.orders-page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 32px;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 14px;
}

.orders-page-header h1 {
    margin: 0;
}

.order-detail-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 28px;
    align-items: start;
    margin-bottom: 50px;
}

.order-meta-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 24px;
    box-shadow: var(--nx-shadow-sm);
    margin-bottom: 24px;
}

.meta-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid var(--nx-border-subtle);
    font-size: 14px;
}

.meta-label {
    color: var(--nx-text-muted);
}

.meta-val {
    font-weight: 600;
    color: var(--nx-text);
}

.delivery-track-box {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 100%);
    color: #FFFFFF;
    border-radius: var(--nx-radius-lg);
    padding: 24px;
    margin-bottom: 24px;
    box-shadow: var(--nx-shadow);
}

.delivery-track-box h3 {
    color: #FFFFFF;
    margin-top: 0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.delivery-track-box a {
    color: var(--nx-accent) !important;
}

.btn-track-map {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--nx-accent);
    color: #0F172A !important;
    padding: 10px 18px;
    border-radius: var(--nx-radius-sm);
    font-weight: 700;
    font-size: 13.5px;
    text-decoration: none;
    margin-top: 14px;
}

.btn-track-map:hover {
    background: #FBBF24;
    transform: translateY(-1px);
}

/* Inline validation messages */
.form-err {
    display: block;
    color: #b91c1c;
    font-size: 12px;
    margin-top: 6px;
    min-height: 0;
}

input.invalid, textarea.invalid {
    border-color: #b91c1c !important;
}

@media (max-width: 900px) {
    .order-detail-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<% Order order = (Order) request.getAttribute("order");
   if (order != null) {
       boolean pending = "Pending".equals(order.getStatus());
       String[] disc = (String[]) request.getAttribute("discount");
       String status = order.getStatus();
       String badgeClass = "badge-pending";
       if ("Delivered".equalsIgnoreCase(status)) badgeClass = "badge-delivered";
       else if ("Processing".equalsIgnoreCase(status)) badgeClass = "badge-processing";
       else if ("Cancelled".equalsIgnoreCase(status)) badgeClass = "badge-cancelled";
       else if ("Out for Delivery".equalsIgnoreCase(status)) badgeClass = "badge-delivery";
%>

    <div class="orders-page-header">
        <div>
            <a href="orders" style="font-size: 14px; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                All Orders
            </a>
            <h1>
                Order #<%= order.getOrderId() %>
                <span class="nx-badge <%= badgeClass %>" style="font-size: 14px; vertical-align: middle; margin-left: 8px;">
                    <%= hx(status) %>
                </span>
            </h1>
        </div>
    </div>

    <% String edit = request.getParameter("edit");
       if ("ok".equals(edit)) { %><p style="color:green">Order updated successfully.</p>
    <% } else if ("stock".equals(edit)) { %><p style="color:red">Not enough stock for that quantity. Nothing was changed.</p>
    <% } else if ("empty".equals(edit)) { %><p style="color:red">An order must retain at least one item. Use Cancel Order instead.</p>
    <% } else if ("locked".equals(edit)) { %><p style="color:red">This order can no longer be edited as it is already being processed.</p>
    <% } else if ("invalid".equals(edit)) { %><p style="color:red">Invalid quantity specified. Use whole numbers from 0 to 1000 (extra item: 1 to 1000).</p>
    <% } else if ("fail".equals(edit)) { %><p style="color:red">That product is currently unavailable.</p>
    <% } %>
    <% if ("ok".equals(request.getParameter("cancel"))) { %>
        <p style="color:green">Order cancelled successfully. Stock has been returned to inventory.</p>
    <% } else if ("fail".equals(request.getParameter("cancel"))) { %>
        <p style="color:red">Only Pending orders can be cancelled.</p>
    <% } %>
    <% if ("ok".equals(request.getParameter("addr"))) { %>
        <p style="color:green">Delivery address updated successfully.</p>
    <% } else if ("invalid".equals(request.getParameter("addr"))) { %>
        <p style="color:red">Address must be between 5 and 200 characters.</p>
    <% } else if ("fail".equals(request.getParameter("addr"))) { %>
        <p style="color:red">Address cannot be altered at this stage.</p>
    <% } %>
    <% if ("ok".equals(request.getParameter("phone"))) { %>
        <p style="color:green">Phone number updated successfully.</p>
    <% } else if ("invalid".equals(request.getParameter("phone"))) { %>
        <p style="color:red">Please enter a valid Sri Lankan phone number (e.g. 0771234567 or +94771234567).</p>
    <% } else if ("fail".equals(request.getParameter("phone"))) { %>
        <p style="color:red">Phone number could not be updated. Please try again.</p>
    <% } %>
    <% if ("fail".equals(request.getParameter("delete"))) { %>
        <p style="color:red">This order record could not be deleted.</p>
    <% } %>

    <div class="order-detail-grid">
        <div>
            <!-- Order Items Card -->
            <div class="nx-card" style="margin-bottom: 24px;">
                <h3 style="margin-top: 0; padding-bottom: 12px; border-bottom: 1px solid var(--nx-border);">
                    Ordered Items <%= pending ? "<span style='font-size: 13px; font-weight: normal; color: var(--nx-text-muted);'>(Editable while Pending)</span>" : "" %>
                </h3>

                <% if (pending) { %>
                <form action="orders" method="post" novalidate onsubmit="return checkEdit(this);">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                    <table>
                        <thead>
                            <tr><th>Product</th><th>Unit Price</th><th>Quantity</th><th>Subtotal</th></tr>
                        </thead>
                        <tbody>
                            <% for (OrderItem i : order.getItems()) { %>
                            <tr>
                                <td style="font-weight: 600;"><%= hx(i.getProductName()) %></td>
                                <td>Rs. <%= i.getUnitPrice() %></td>
                                <td>
                                    <input type="number" name="qty_<%= i.getProductId() %>" min="0" max="1000" step="1"
                                           value="<%= i.getQuantity() %>" style="width:72px; padding: 6px;">
                                </td>
                                <td style="font-weight: 700;">Rs. <%= i.getSubtotal() %></td>
                            </tr>
                            <% } %>
                            <% if (disc != null) { %>
                            <tr>
                                <td colspan="3" align="right" style="color:#059669; font-weight: 600;">Coupon <%= hx(disc[0]) %></td>
                                <td style="color:#059669; font-weight: 700;">- Rs. <%= hx(disc[1]) %></td>
                            </tr>
                            <% } %>
                            <tr>
                                <td colspan="3" align="right" style="font-weight: 800; font-size: 16px;">Total</td>
                                <td style="font-weight: 800; font-size: 17px; color: #0E3B43;">Rs. <%= order.getTotal() %></td>
                            </tr>
                        </tbody>
                    </table>

                    <div style="background: var(--nx-card-subtle); border: 1px solid var(--nx-border); border-radius: var(--nx-radius-sm); padding: 14px; margin-top: 14px; display: flex; flex-wrap: wrap; align-items: center; gap: 10px;">
                        <span style="font-weight: 600; font-size: 13.5px;">Add extra item:</span>
                        <% List<String[]> products = (List<String[]>) request.getAttribute("products"); %>
                        <select name="addProduct">
                            <option value="">-- Choose item --</option>
                            <% if (products != null) for (String[] p : products) { %>
                                <option value="<%= hx(p[0]) %>"><%= hx(p[1]) %> (Rs. <%= hx(p[2]) %> | Stock <%= hx(p[3]) %>)</option>
                            <% } %>
                        </select>
                        <span style="font-size: 13.5px;">Qty:</span>
                        <input type="number" name="addQty" min="1" max="1000" step="1" value="1" style="width:70px; padding: 6px;">
                        <button type="submit">Save Changes</button>
                    </div>
                    <span class="form-err" id="editErr"></span>
                </form>
                <% } else { %>
                <table>
                    <thead>
                        <tr><th>Product</th><th>Unit Price</th><th>Quantity</th><th>Subtotal</th></tr>
                    </thead>
                    <tbody>
                        <% for (OrderItem i : order.getItems()) { %>
                        <tr>
                            <td style="font-weight: 600;"><%= hx(i.getProductName()) %></td>
                            <td>Rs. <%= i.getUnitPrice() %></td>
                            <td><%= i.getQuantity() %></td>
                            <td style="font-weight: 700;">Rs. <%= i.getSubtotal() %></td>
                        </tr>
                        <% } %>
                        <% if (disc != null) { %>
                        <tr>
                            <td colspan="3" align="right" style="color:#059669; font-weight: 600;">Coupon <%= hx(disc[0]) %></td>
                            <td style="color:#059669; font-weight: 700;">- Rs. <%= hx(disc[1]) %></td>
                        </tr>
                        <% } %>
                        <tr>
                            <td colspan="3" align="right" style="font-weight: 800; font-size: 16px;">Total</td>
                            <td style="font-weight: 800; font-size: 17px; color: #0E3B43;">Rs. <%= order.getTotal() %></td>
                        </tr>
                    </tbody>
                </table>
                <% } %>
            </div>

            <!-- Modifiable details if Pending/Processing -->
            <% if ("Pending".equals(order.getStatus()) || "Processing".equals(order.getStatus())) { %>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px;">
                <div class="nx-card">
                    <h3 style="margin-top: 0; font-size: 16px;">Update Address</h3>
                    <form action="orders" method="post" novalidate onsubmit="return checkAddress(this);">
                        <input type="hidden" name="action" value="address">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                        <textarea name="address" rows="2" maxlength="200" style="width: 100%; margin-bottom: 10px;"><%= hx(order.getAddress()) %></textarea>
                        <button type="submit" class="btn-secondary" style="font-size: 13px;">Save Address</button>
                        <span class="form-err"></span>
                    </form>
                </div>

                <div class="nx-card">
                    <h3 style="margin-top: 0; font-size: 16px;">Update Phone</h3>
                    <form action="orders" method="post" novalidate onsubmit="return checkPhone(this);">
                        <input type="hidden" name="action" value="phone">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                        <input type="text" name="phone" maxlength="15" placeholder="0771234567" style="width: 100%; margin-bottom: 10px;">
                        <button type="submit" class="btn-secondary" style="font-size: 13px;">Save Phone</button>
                        <span class="form-err"></span>
                    </form>
                </div>
            </div>
            <% } %>
        </div>

        <!-- Right Side: Order Meta & Tracking -->
        <div>
            <!-- Live Tracking Box -->
            <div class="delivery-track-box">
                <h3>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon></svg>
                    Delivery Tracking
                </h3>
                <% Delivery d = (Delivery) request.getAttribute("delivery");
                   if (d == null) { %>
                    <p style="color: #CFE3E5; font-size: 14px; margin-bottom: 0;">
                    <% if ("Cancelled".equals(order.getStatus())) { %>This order has been cancelled.
                    <% } else { %>A delivery officer will be assigned shortly once dispatched.<% } %>
                    </p>
                <% } else { %>
                    <p style="color: #CFE3E5; font-size: 14px; line-height: 1.6; margin-bottom: 12px;">
                        <b>Status:</b> <%= hx(d.getStatus()) %><br>
                        <b>Officer:</b> <%= hx(d.getStaffName()) %><br>
                        <b>Last Update:</b> <%= d.getUpdatedAt() %>
                        <% if (d.getNotes() != null && !d.getNotes().isEmpty()) { %><br><b>Note:</b> <%= hx(d.getNotes()) %><% } %>
                    </p>
                    <a href="track?orderId=<%= order.getOrderId() %>" class="btn-track-map">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="3 11 22 2 13 21 11 13 3 11"></polygon></svg>
                        Track on Live Map
                    </a>
                <% } %>
            </div>

            <!-- Order Meta Card -->
            <div class="order-meta-card">
                <h3 style="margin-top: 0; padding-bottom: 10px; border-bottom: 1px solid var(--nx-border);">Order Details</h3>
                <div class="meta-row">
                    <span class="meta-label">Placed On</span>
                    <span class="meta-val"><%= order.getCreatedAt() %></span>
                </div>
                <div class="meta-row">
                    <span class="meta-label">Payment Method</span>
                    <span class="meta-val"><%= hx(order.getPaymentMethod()) %></span>
                </div>
                <div class="meta-row" style="flex-direction: column; gap: 4px;">
                    <span class="meta-label">Delivery Address</span>
                    <span class="meta-val"><%= hx(order.getAddress()) %></span>
                </div>
                <% if (disc != null) { %>
                <div class="meta-row">
                    <span class="meta-label">Applied Coupon</span>
                    <span class="meta-val" style="color: #059669;"><%= hx(disc[0]) %> (-Rs. <%= hx(disc[1]) %>)</span>
                </div>
                <% } %>

                <div style="margin-top: 20px; display: flex; flex-direction: column; gap: 8px;">
                    <% if (pending) { %>
                    <form action="orders" method="post">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                        <button type="submit" class="btn-danger" style="width: 100%;"
                                onclick="return confirm('Cancel this order? Restocked inventory will be returned.')">
                            Cancel Order
                        </button>
                    </form>
                    <% } %>

                    <form action="orders" method="post">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                        <button type="submit" class="btn-danger" style="width: 100%;"
                                onclick="return confirm('Delete this order permanently from your record?')">
                            Delete Order Record
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

<% } else { %>

    <div class="orders-page-header">
        <h1>My Order History</h1>
        <a href="shop" class="btn">Explore Catalogue</a>
    </div>

    <% if (request.getParameter("placed") != null) { %>
        <p style="color:green">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            Order #<%= hx(request.getParameter("placed")) %> has been placed successfully!
        </p>
    <% } %>
    <% if (request.getParameter("deleted") != null) { %>
        <p style="color:green">Order #<%= hx(request.getParameter("deleted")) %> deleted from records.</p>
    <% } %>
    <% if ("invalid".equals(request.getParameter("error"))) { %>
        <p style="color:red">Invalid request. Please try again.</p>
    <% } %>

    <% List<Order> orders = (List<Order>) request.getAttribute("orders");
       if (orders == null || orders.isEmpty()) { %>
        <div class="nx-card" style="text-align: center; padding: 60px 20px; margin: 30px 0;">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--nx-text-muted); margin-bottom: 16px;"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
            <h2 style="font-size: 20px; margin-bottom: 6px;">No orders found yet</h2>
            <p style="color: var(--nx-text-muted); font-size: 14px; margin-bottom: 20px;">You haven't placed any orders yet. Browse our store to make your first purchase.</p>
            <a href="shop" class="btn">Start Shopping</a>
        </div>
    <% } else { %>
    <div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
        <table style="margin: 0; border: none; box-shadow: none;">
            <thead>
                <tr>
                    <th>Order #</th>
                    <th>Date Placed</th>
                    <th>Total Amount</th>
                    <th>Payment</th>
                    <th>Status</th>
                    <th style="text-align: right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Order o : orders) {
                    String status = o.getStatus();
                    String badgeClass = "badge-pending";
                    if ("Delivered".equalsIgnoreCase(status)) badgeClass = "badge-delivered";
                    else if ("Processing".equalsIgnoreCase(status)) badgeClass = "badge-processing";
                    else if ("Cancelled".equalsIgnoreCase(status)) badgeClass = "badge-cancelled";
                    else if ("Out for Delivery".equalsIgnoreCase(status)) badgeClass = "badge-delivery";
                %>
                <tr>
                    <td style="font-weight: 700; font-family: 'Plus Jakarta Sans', sans-serif;">
                        #<%= o.getOrderId() %>
                    </td>
                    <td><%= o.getCreatedAt() %></td>
                    <td style="font-weight: 700; color: #0E3B43;">Rs. <%= o.getTotal() %></td>
                    <td><%= hx(o.getPaymentMethod()) %></td>
                    <td>
                        <span class="nx-badge <%= badgeClass %>"><%= hx(status) %></span>
                    </td>
                    <td style="text-align: right;">
                        <a href="orders?id=<%= o.getOrderId() %>" class="btn-secondary" style="padding: 6px 12px; font-size: 12.5px; margin-right: 4px;">
                            View Details
                        </a>
                        <form action="orders" method="post" style="display:inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                            <button type="submit" class="btn-danger" style="padding: 6px 10px; font-size: 12.5px;"
                                    onclick="return confirm('Delete order #<%= o.getOrderId() %> permanently?')">
                                Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    <% } %>

<% } %>

<script>
function setErr(f, el, msg) {
    var box = f.querySelector('.form-err');
    if (box) box.innerText = msg;
    if (el) el.classList.toggle('invalid', msg !== '');
    return msg === '';
}

// Update Address: 5 - 200 characters
function checkAddress(f) {
    var el = f.elements['address'];
    var v = el.value.trim();
    var msg = (v.length < 5 || v.length > 200) ? 'Address must be 5 to 200 characters.' : '';
    return setErr(f, el, msg);
}

// Update Phone: 0771234567 හෝ +94771234567
function checkPhone(f) {
    var el = f.elements['phone'];
    var v = el.value.replace(/\s+/g, '');
    var ok = /^(0[1-9]\d{8}|\+94[1-9]\d{8})$/.test(v);
    return setErr(f, el, ok ? '' : 'Enter a valid phone number (e.g. 0771234567 or +94771234567).');
}

// Edit order: qty_* = 0..1000, extra item qty = 1..1000
function checkEdit(f) {
    var msg = '';
    var inputs = f.querySelectorAll('input[name^="qty_"]');
    for (var i = 0; i < inputs.length; i++) {
        var v = inputs[i].value.trim();
        var bad = !/^\d+$/.test(v) || parseInt(v, 10) > 1000;
        inputs[i].classList.toggle('invalid', bad);
        if (bad && !msg) msg = 'Quantities must be whole numbers from 0 to 1000.';
    }
    var add = f.elements['addProduct'];
    var addQty = f.elements['addQty'];
    if (add && add.value !== '') {
        var q = addQty.value.trim();
        var badAdd = !/^\d+$/.test(q) || parseInt(q, 10) < 1 || parseInt(q, 10) > 1000;
        addQty.classList.toggle('invalid', badAdd);
        if (badAdd && !msg) msg = 'Extra item quantity must be a whole number from 1 to 1000.';
    } else if (addQty) {
        addQty.classList.remove('invalid');
    }
    var box = document.getElementById('editErr');
    if (box) box.innerText = msg;
    return msg === '';
}
</script>
</body>
</html>