<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Delivery, com.nexora.dao.DeliveryDAO" %>
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
<title>Nexora - Delivery Staff Portal</title>
<style>
.delivery-filters {
    display: flex;
    gap: 8px;
    margin: 20px 0 24px;
}

.delivery-filter-btn {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    color: var(--nx-text);
}

.delivery-filter-btn.active {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">My Assigned Deliveries</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Manage delivery progress, customer drop-off details, and transmit live GPS location to the customer.</p>

<%
    String errCode = request.getParameter("error");
    if (request.getParameter("updated") != null) { %>
    <p style="color:green">Delivery status updated successfully.</p>
<% } else if (errCode != null) {
       String msg;
       if ("2".equals(errCode))      msg = "A reason (at least 5 characters) is required for 'Delayed' or 'Customer Unavailable'.";
       else if ("3".equals(errCode)) msg = "Note is too long. Maximum 200 characters.";
       else if ("4".equals(errCode)) msg = "Invalid request. Please try again.";
       else                          msg = "Status transition is not allowed.";
%>
    <p style="color:red"><%= msg %></p>
<% } %>

<% String show = request.getParameter("show"); %>
<div class="delivery-filters">
    <a href="deliveries" class="delivery-filter-btn <%= show == null ? "active" : "" %>">Active Deliveries</a>
    <a href="deliveries?show=all" class="delivery-filter-btn <%= "all".equals(show) ? "active" : "" %>">All History (incl. Delivered)</a>
</div>

<% List<Delivery> list = (List<Delivery>) request.getAttribute("deliveries");
   if (list == null || list.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 50px 20px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin-bottom: 0;">No packages assigned to you at this moment.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Order #</th>
                <th>Customer Contact</th>
                <th>Delivery Address</th>
                <th>Order Items</th>
                <th>Payment</th>
                <th>Status</th>
                <th>Driver Notes</th>
                <th>Update Progress</th>
                <th style="text-align: right;">Live GPS Share</th>
            </tr>
        </thead>
        <tbody>
            <% for (Delivery d : list) {
                   String st = d.getStatus();
                   String badgeClass = "badge-pending";
                   if ("Delivered".equalsIgnoreCase(st)) badgeClass = "badge-delivered";
                   else if ("Processing".equalsIgnoreCase(st)) badgeClass = "badge-processing";
                   else if ("Cancelled".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";
                   else if ("Out for Delivery".equalsIgnoreCase(st)) badgeClass = "badge-delivery";
                   List<String> next = DeliveryDAO.nextStatuses(st);
            %>
            <tr>
                <td style="font-weight: 700;">#<%= d.getOrderId() %></td>
                <td>
                    <b><%= hx(d.getCustomerName()) %></b><br>
                    <a href="tel:<%= hx(d.getCustomerPhone()) %>" style="font-size: 13px; color: var(--nx-brand);"><%= hx(d.getCustomerPhone()) %></a>
                </td>
                <td style="font-size: 13.5px; max-width: 200px;"><%= hx(d.getAddress()) %></td>
                <td style="font-size: 13px;"><%= hx(d.getItems()) %></td>
                <td>
                    <span class="nx-badge badge-processing"><%= hx(d.getPaymentMethod()) %></span>
                    <% if ("Cash on Delivery".equals(d.getPaymentMethod())) { %>
                        <br><b style="color: #0E3B43; font-size: 13px;">Collect Rs. <%= d.getTotal() %></b>
                    <% } %>
                </td>
                <td>
                    <span class="nx-badge <%= badgeClass %>"><%= hx(st) %></span><br>
                    <small style="font-size: 11px; color: var(--nx-text-muted);"><%= d.getUpdatedAt() %></small>
                </td>
                <td style="font-size: 13px; color: var(--nx-text-muted);"><%= (d.getNotes() == null || d.getNotes().isEmpty()) ? "&mdash;" : hx(d.getNotes()) %></td>
                <td>
                    <% if (next.isEmpty()) { %>
                        <span style="font-size: 12px; color: var(--nx-text-muted);">&mdash;</span>
                    <% } else { %>
                    <form action="deliveries" method="post" style="display: flex; flex-direction: column; gap: 6px;"
                          onsubmit="return checkUpdate(this);">
                        <input type="hidden" name="deliveryId" value="<%= d.getDeliveryId() %>">
                        <select name="newStatus" style="padding: 5px 8px; font-size: 12px;">
                            <% for (String n : next) { %><option><%= hx(n) %></option><% } %>
                        </select>
                        <input type="text" name="notes" maxlength="200"
                               placeholder="Drop-off note / reason" style="padding: 5px 8px; font-size: 12px;">
                        <small class="fe" style="color:#b91c1c; font-size:11.5px; display:none;"></small>
                        <button type="submit" style="padding: 5px 10px; font-size: 12px;">Update</button>
                    </form>
                    <% } %>
                </td>
                <td style="text-align: right;">
                    <% if ("Out for Delivery".equals(d.getStatus())) { %>
                        <button type="button" class="btn-secondary" style="padding: 6px 12px; font-size: 12px;" onclick="startShare(<%= d.getDeliveryId() %>)">
                            Transmit GPS
                        </button>
                        <br><small id="loc<%= d.getDeliveryId() %>" style="color: #059669; font-weight: 600;"></small>
                    <% } else { %>&mdash;<% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<script>
function checkUpdate(f) {
    var status = f.newStatus.value;
    var note = f.notes.value.trim();
    var fe = f.querySelector('.fe');
    var msg = '';

    if ((status === 'Delayed' || status === 'Customer Unavailable') && note.length < 5) {
        msg = 'Please enter a reason (at least 5 characters).';
    } else if (note.length > 200) {
        msg = 'Note is too long (max 200 characters).';
    }

    if (msg) {
        fe.innerText = msg;
        fe.style.display = 'block';
        f.notes.style.borderColor = '#b91c1c';
        return false;
    }
    fe.style.display = 'none';
    return true;
}

var timers = {};

function sendPos(id) {
    if (!navigator.geolocation) { alert('This device or browser does not support GPS.'); return; }
    navigator.geolocation.getCurrentPosition(function (p) {
        fetch('deliveries', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=location&deliveryId=' + id +
                  '&lat=' + p.coords.latitude + '&lng=' + p.coords.longitude
        }).then(function (r) {
            document.getElementById('loc' + id).innerText =
                (r.ok ? 'Sent: ' : 'Failed: ') + new Date().toLocaleTimeString();
        });
    }, function (e) {
        alert('Location error: ' + e.message);
    });
}

function startShare(id) {
    sendPos(id);
    if (!timers[id]) timers[id] = setInterval(function () { sendPos(id); }, 20000);
}
</script>
</body>
</html>