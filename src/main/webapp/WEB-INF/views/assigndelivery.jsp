<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Delivery" %>
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
<title>Nexora - Dispatch Management</title>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">Delivery Dispatch Management</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Assign couriers to processing orders and supervise active field delivery shipments.</p>

<% if (request.getParameter("assigned") != null) { %>
    <p style="color:green">Order #<%= hx(request.getParameter("assigned")) %> assigned to delivery officer.</p>
<% } else if (request.getParameter("reassigned") != null) { %>
    <p style="color:green">Order #<%= hx(request.getParameter("reassigned")) %> reassigned to officer.</p>
<% } else if (request.getParameter("noted") != null) { %>
    <p style="color:green">Note for Order #<%= hx(request.getParameter("noted")) %> saved.</p>
<% } else if (request.getParameter("removed") != null) { %>
    <p style="color:green">Delivery record for Order #<%= hx(request.getParameter("removed")) %> removed.</p>
<% } else if (request.getParameter("error") != null) {
       String ec = request.getParameter("error");
       String em;
       if ("2".equals(ec))      em = "Invalid request. Please select valid values and try again.";
       else if ("3".equals(ec)) em = "Note is too long. Maximum 200 characters.";
       else                     em = "Operation disallowed (e.g. delivered orders cannot be reassigned).";
%>
    <p style="color:red"><%= em %></p>
<% } %>

<h3 style="margin-top: 28px;">Orders Awaiting Dispatch (Processing Status)</h3>
<% List<String[]> unassigned = (List<String[]>) request.getAttribute("unassigned");
   List<String[]> staff = (List<String[]>) request.getAttribute("staff");
   if (unassigned == null || unassigned.isEmpty()) { %>
    <div class="nx-card" style="padding: 24px; margin-bottom: 32px;">
        <p style="color: var(--nx-text-muted); margin: 0;">No pending packages waiting for dispatch. (Orders must be set to <b>Processing</b> in Orders management first.)</p>
    </div>
<% } else if (staff == null || staff.isEmpty()) { %>
    <p style="color:red">No active Delivery Staff accounts found in system.</p>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 36px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 100px;">Order #</th>
                <th>Customer Name</th>
                <th>Delivery Address</th>
                <th>Total Value</th>
                <th style="text-align: right;">Assign Delivery Courier</th>
            </tr>
        </thead>
        <tbody>
            <% for (String[] o : unassigned) { %>
            <tr>
                <td style="font-weight: 700;">#<%= hx(o[0]) %></td>
                <td style="font-weight: 600;"><%= hx(o[1]) %></td>
                <td style="font-size: 13.5px;"><%= hx(o[2]) %></td>
                <td style="font-weight: 700; color: #0E3B43;">Rs. <%= hx(o[3]) %></td>
                <td style="text-align: right;">
                    <form action="assigndelivery" method="post" style="display:inline-flex; align-items:center; gap:8px;">
                        <input type="hidden" name="orderId" value="<%= hx(o[0]) %>">
                        <select name="staffId" required style="padding: 6px 10px; font-size: 13px;">
                            <% for (String[] s : staff) { %>
                                <option value="<%= hx(s[0]) %>"><%= hx(s[1]) %> (ID: <%= hx(s[0]) %>)</option>
                            <% } %>
                        </select>
                        <button type="submit" style="padding: 6px 14px; font-size: 13px;">Assign</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<h3 style="margin-top: 28px;">All Dispatched Deliveries</h3>
<% List<Delivery> all = (List<Delivery>) request.getAttribute("deliveries");
   if (all == null || all.isEmpty()) { %>
    <div class="nx-card" style="padding: 24px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin: 0;">No delivery dispatches created yet.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Order #</th>
                <th>Customer</th>
                <th>Address</th>
                <th>Assigned Officer</th>
                <th>Status</th>
                <th>Admin Note</th>
                <th>Last Update</th>
                <th>Reassign</th>
                <th style="text-align: right;">Delete</th>
            </tr>
        </thead>
        <tbody>
            <% for (Delivery d : all) {
                   String st = d.getStatus();
                   String badgeClass = "badge-pending";
                   if ("Delivered".equalsIgnoreCase(st)) badgeClass = "badge-delivered";
                   else if ("Processing".equalsIgnoreCase(st)) badgeClass = "badge-processing";
                   else if ("Cancelled".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";
                   else if ("Out for Delivery".equalsIgnoreCase(st)) badgeClass = "badge-delivery";
            %>
            <tr>
                <td style="font-weight: 700;">#<%= d.getOrderId() %></td>
                <td style="font-weight: 600;"><%= hx(d.getCustomerName()) %></td>
                <td style="font-size: 13.5px;"><%= hx(d.getAddress()) %></td>
                <td><span class="nx-badge badge-processing"><%= hx(d.getStaffName()) %></span></td>
                <td><span class="nx-badge <%= badgeClass %>"><%= hx(st) %></span></td>
                <td>
                    <form action="assigndelivery" method="post" style="display:inline-flex; align-items:center; gap:4px;"
                          onsubmit="return checkNote(this);">
                        <input type="hidden" name="action" value="note">
                        <input type="hidden" name="orderId" value="<%= d.getOrderId() %>">
                        <input type="text" name="note" maxlength="200" value="<%= hx(d.getNotes()) %>" style="width:130px; padding: 5px 8px; font-size: 12px;">
                        <button type="submit" class="btn-secondary" style="padding: 5px 8px; font-size: 12px;">Save</button>
                    </form>
                </td>
                <td style="font-size: 12.5px; color: var(--nx-text-muted);"><%= d.getUpdatedAt() %></td>
                <td>
                    <% if (!"Delivered".equals(d.getStatus()) && staff != null && !staff.isEmpty()) { %>
                    <form action="assigndelivery" method="post" style="display:inline-flex; align-items:center; gap:4px;">
                        <input type="hidden" name="action" value="reassign">
                        <input type="hidden" name="orderId" value="<%= d.getOrderId() %>">
                        <select name="staffId" required style="padding: 5px 8px; font-size: 12px;">
                            <% for (String[] s : staff) { %>
                                <option value="<%= hx(s[0]) %>"><%= hx(s[1]) %></option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn-secondary" style="padding: 5px 8px; font-size: 12px;"
                                onclick="return confirm('Reassign this delivery? Status will reset to Assigned.')">Reassign</button>
                    </form>
                    <% } else { %>&mdash;<% } %>
                </td>
                <td style="text-align: right;">
                    <form action="assigndelivery" method="post" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="orderId" value="<%= d.getOrderId() %>">
                        <button type="submit" class="btn-danger" style="padding: 5px 8px; font-size: 12px;"
                                onclick="return confirm('Delete this delivery record?')">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<script>
function checkNote(f) {
    if (f.note.value.trim().length > 200) {
        alert('Note is too long (max 200 characters).');
        return false;
    }
    return true;
}
</script>
</body>
</html>