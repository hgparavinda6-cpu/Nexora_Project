<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.dao.AdminOrderDAO" %>
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
<title>Nexora - Manage Orders</title>
<style>
.filter-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin: 20px 0 24px;
}

.status-chip {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    color: var(--nx-text);
}

.status-chip:hover {
    border-color: var(--nx-brand);
}

.status-chip.active {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">Order Operations &amp; Fulfilment</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Supervise incoming customer orders and progress their fulfilment lifecycle.</p>

<% String errCode = request.getParameter("error");
   if (request.getParameter("updated") != null) { %>
    <p style="color:green">Order #<%= hx(request.getParameter("updated")) %> status updated successfully.</p>
<% } else if ("2".equals(errCode)) { %>
    <p style="color:red">Invalid request. Please select a valid order and status.</p>
<% } else if (errCode != null) { %>
    <p style="color:red">Requested status change transition is not permitted.</p>
<% } %>

<% String curFilter = request.getParameter("status"); %>
<div class="filter-bar">
    <span style="font-size: 13.5px; font-weight: 600; color: var(--nx-text-muted);">Filter by Status:</span>
    <a href="manageorders" class="status-chip <%= curFilter == null ? "active" : "" %>">All Orders</a>
    <% for (String s : (List<String>) request.getAttribute("statuses")) { %>
        <a href="manageorders?status=<%= java.net.URLEncoder.encode(s, "UTF-8") %>"
           class="status-chip <%= s.equalsIgnoreCase(curFilter) ? "active" : "" %>"><%= hx(s) %></a>
    <% } %>
</div>

<% List<String[]> orders = (List<String[]>) request.getAttribute("orders");
   if (orders == null || orders.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 50px 20px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin-bottom: 0;">No customer orders found under this filter criteria.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Order #</th>
                <th>Customer</th>
                <th>Date Placed</th>
                <th>Items</th>
                <th>Total (Rs.)</th>
                <th>Payment</th>
                <th>Delivery Address</th>
                <th>Current Status</th>
                <th style="text-align: right;">Transition Status</th>
            </tr>
        </thead>
        <tbody>
            <% for (String[] o : orders) {
                   String st = o[5];
                   String badgeClass = "badge-pending";
                   if ("Delivered".equalsIgnoreCase(st)) badgeClass = "badge-delivered";
                   else if ("Processing".equalsIgnoreCase(st)) badgeClass = "badge-processing";
                   else if ("Cancelled".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";
                   else if ("Out for Delivery".equalsIgnoreCase(st)) badgeClass = "badge-delivery";
                   List<String> next = AdminOrderDAO.nextStatuses(st);
            %>
            <tr>
                <td style="font-weight: 700;">#<%= hx(o[0]) %></td>
                <td style="font-weight: 600;"><%= hx(o[1]) %></td>
                <td style="font-size: 13px; color: var(--nx-text-muted);"><%= hx(o[2]) %></td>
                <td style="font-size: 13.5px;"><%= hx(o[7]) %></td>
                <td style="font-weight: 700; color: #0E3B43;">Rs. <%= hx(o[3]) %></td>
                <td><span class="nx-badge badge-processing"><%= hx(o[4]) %></span></td>
                <td style="max-width: 220px; font-size: 13px;"><%= hx(o[6]) %></td>
                <td><span class="nx-badge <%= badgeClass %>"><%= hx(st) %></span></td>
                <td style="text-align: right;">
                    <% if (next.isEmpty()) { %>
                        <span style="font-size: 12px; color: var(--nx-text-muted);">&mdash;</span>
                    <% } else { %>
                    <form action="manageorders" method="post" style="display:inline-flex; align-items:center; gap:6px;">
                        <input type="hidden" name="orderId" value="<%= hx(o[0]) %>">
                        <select name="newStatus" style="padding: 6px 10px; font-size: 12.5px;">
                            <% for (String n : next) { %><option><%= hx(n) %></option><% } %>
                        </select>
                        <button type="submit" style="padding: 6px 12px; font-size: 12.5px;"
                                onclick="return this.form.newStatus.value !== 'Cancelled' || confirm('Cancel order #<%= hx(o[0]) %>? Stock will be returned to inventory.')">Update</button>
                    </form>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

</body>
</html>