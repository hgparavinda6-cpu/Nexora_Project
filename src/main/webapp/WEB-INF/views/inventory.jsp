<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.InventoryItem" %>
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
<title>Nexora - Inventory Control</title>
<style>
.admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 32px;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 14px;
}

.admin-tabs {
    display: flex;
    gap: 8px;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    padding: 6px;
    border-radius: var(--nx-radius);
    box-shadow: var(--nx-shadow-sm);
}

.admin-tab {
    padding: 8px 16px;
    border-radius: var(--nx-radius-sm);
    font-size: 13.5px;
    font-weight: 600;
    text-decoration: none;
    color: var(--nx-text-muted);
}

.admin-tab.active {
    background: var(--nx-brand);
    color: #FFFFFF;
}

.filter-pills {
    display: flex;
    gap: 8px;
    margin-bottom: 20px;
}

.filter-pill {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    color: var(--nx-text);
    text-decoration: none;
}

.filter-pill.active {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}

/* Observer pattern: low stock alerts box */
.stock-alerts {
    background: #FFF7E6;
    border: 1px solid #F5C75B;
    border-left: 5px solid #F59E0B;
    border-radius: 12px;
    padding: 16px 20px;
    margin-bottom: 20px;
}

.stock-alerts-title {
    font-weight: 800;
    color: #92400E;
    margin-bottom: 8px;
}

.stock-alerts ul {
    margin: 0;
    padding-left: 20px;
    color: #78350F;
    line-height: 1.7;
}

.adjust-wrap {
    display: inline-flex;
    flex-direction: column;
    align-items: flex-end;
}

.adjust-error {
    color: #b91c1c;
    font-size: 11.5px;
    margin-top: 4px;
    max-width: 260px;
    text-align: right;
}

input.invalid {
    border-color: #b91c1c !important;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="admin-header">
    <h1 style="margin: 0;">Inventory &amp; Warehouse Control</h1>
    <div class="admin-tabs">
        <a href="products" class="admin-tab">Products</a>
        <a href="categories" class="admin-tab">Categories</a>
        <a href="inventory" class="admin-tab active">Stock Control</a>
    </div>
</div>

<%
    String errCode = request.getParameter("error");
    if (request.getParameter("updated") != null) { %>
    <p style="color:green">Stock level updated successfully.</p>
<% } else if (errCode != null) {
       String msg;
       if ("2".equals(errCode))      msg = "Quantity must be a whole number between -10000 and 10000 (not 0).";
       else if ("3".equals(errCode)) msg = "Quantity does not match the reason. Restock/Returned need a positive (+) number; Damaged needs a negative (-) number.";
       else if ("4".equals(errCode)) msg = "Invalid request. Please try again.";
       else                          msg = "Stock level cannot drop below 0. Operation rejected.";
%>
    <p style="color:red"><%= msg %></p>
<% } %>

<%-- Observer pattern: AdminAlertObserver එකේ ගබඩා කරපු low stock alerts --%>
<%
    List<String> nxAlerts = com.nexora.pattern.observer.AdminAlertObserver.getAlerts();
    if (!nxAlerts.isEmpty()) {
%>
<div class="stock-alerts">
    <div class="stock-alerts-title">⚠ Low Stock Alerts (<%= nxAlerts.size() %>)</div>
    <ul>
        <% for (int k = nxAlerts.size() - 1; k >= 0; k--) { %>
            <li><%= hx(nxAlerts.get(k)) %></li>
        <% } %>
    </ul>
</div>
<% } %>

<% boolean lowOnly = (Boolean) request.getAttribute("lowOnly"); %>

<div class="filter-pills">
    <a href="inventory" class="filter-pill <%= !lowOnly ? "active" : "" %>">All Products Stock</a>
    <a href="inventory?filter=low" class="filter-pill <%= lowOnly ? "active" : "" %>">Low / Critical Stock Only</a>
</div>

<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 40px;">
    <div style="padding: 18px 24px; border-bottom: 1px solid var(--nx-border); display: flex; justify-content: space-between; align-items: center;">
        <h3 style="margin: 0; font-size: 18px;"><%= lowOnly ? "Low / Out of Stock Alert" : "Live Product Inventory" %></h3>
    </div>

    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 70px;">ID</th>
                <th>Product</th>
                <th>Category</th>
                <th style="width: 100px;">Current Stock</th>
                <th style="width: 100px;">Alert Level</th>
                <th style="width: 120px;">Health</th>
                <th style="text-align: right;">Adjust Stock Level</th>
            </tr>
        </thead>
        <tbody>
            <% List<InventoryItem> items = (List<InventoryItem>) request.getAttribute("items");
               if (items != null) for (InventoryItem i : items) {
                   String st = i.getStatus();
                   String badgeClass = "badge-delivered";
                   if ("Low".equalsIgnoreCase(st)) badgeClass = "badge-pending";
                   else if ("Out".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";
            %>
            <tr>
                <td style="font-weight: 700; color: var(--nx-text-muted);"><%= i.getProductId() %></td>
                <td style="font-weight: 600;"><%= hx(i.getProductName()) %></td>
                <td><span class="nx-badge badge-processing"><%= hx(i.getCategoryName()) %></span></td>
                <td style="font-weight: 700; font-size: 15px;"><%= i.getStockQty() %></td>
                <td style="color: var(--nx-text-muted);"><%= i.getLowStockLevel() %></td>
                <td><span class="nx-badge <%= badgeClass %>"><%= hx(st) %></span></td>
                <td style="text-align: right;">
                    <form action="inventory" method="post" novalidate onsubmit="return checkAdjust(this);">
                        <div class="adjust-wrap">
                            <div style="display:inline-flex; align-items:center; gap:6px;">
                                <input type="hidden" name="productId" value="<%= i.getProductId() %>">
                                <input type="number" name="changeQty" step="1" min="-10000" max="10000"
                                       style="width:74px; padding: 6px; text-align: center;" placeholder="+10">
                                <select name="reason" style="padding: 6px 10px; font-size: 13px;">
                                    <option>Restock</option>
                                    <option>Damaged</option>
                                    <option>Correction</option>
                                    <option>Returned</option>
                                </select>
                                <button type="submit" style="padding: 6px 12px; font-size: 12.5px;">Apply</button>
                            </div>
                            <span class="adjust-error"></span>
                        </div>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<h2 style="font-size: 20px; margin-bottom: 14px;">Recent Stock Audit History</h2>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Timestamp</th>
                <th>Product</th>
                <th>Quantity Delta</th>
                <th>Reason</th>
                <th>Performed By</th>
            </tr>
        </thead>
        <tbody>
            <% List<String[]> logs = (List<String[]>) request.getAttribute("logs");
               if (logs != null) for (String[] l : logs) { %>
            <tr>
                <td style="font-size: 13px; color: var(--nx-text-muted);"><%= hx(l[0]) %></td>
                <td style="font-weight: 600;"><%= hx(l[1]) %></td>
                <td style="font-weight: 700; color: <%= l[2].startsWith("+") ? "#059669" : "#DC2626" %>;"><%= hx(l[2]) %></td>
                <td><span class="nx-badge badge-processing"><%= hx(l[3]) %></span></td>
                <td style="font-size: 13.5px;"><%= hx(l[4]) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<script>
function checkAdjust(f) {
    var qtyInput = f.elements['changeQty'];
    var v = qtyInput.value.trim();
    var reason = f.elements['reason'].value;
    var box = f.querySelector('.adjust-error');
    var msg = '';

    if (!/^-?\d+$/.test(v)) {
        msg = 'Enter a whole number (e.g. +10 or -3).';
    } else {
        var n = parseInt(v, 10);
        if (n === 0) {
            msg = 'Quantity cannot be 0.';
        } else if (n > 10000 || n < -10000) {
            msg = 'Quantity must be between -10000 and 10000.';
        } else if ((reason === 'Restock' || reason === 'Returned') && n < 0) {
            msg = reason + ' needs a positive (+) number.';
        } else if (reason === 'Damaged' && n > 0) {
            msg = 'Damaged needs a negative (-) number.';
        }
    }

    box.innerText = msg;
    qtyInput.classList.toggle('invalid', msg !== '');
    return msg === '';
}
</script>
</body>
</html>