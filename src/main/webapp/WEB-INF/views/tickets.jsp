<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.SupportTicket" %>
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
<title>Nexora - Support Helpdesk Administration</title>
<style>
.ticket-filter-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin: 20px 0 24px;
}

.ticket-chip {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    color: var(--nx-text);
}

.ticket-chip:hover {
    border-color: var(--nx-brand);
}

.ticket-chip.active {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}

.reply-err {
    color: #b91c1c;
    font-size: 12px;
    min-height: 0;
}

textarea.invalid {
    border-color: #b91c1c !important;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">Customer Support Desk</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Respond to inquiries, provide assistance notes, and manage support ticket lifecycles.</p>

<% String msg = request.getParameter("msg");
   if ("saved".equals(msg)) { %><p style="color:green">Ticket updated and response saved.</p>
<% } else if ("deleted".equals(msg)) { %><p style="color:green">Resolved ticket archived and deleted.</p>
<% } else if ("invalid".equals(msg)) { %><p style="color:red">Invalid status chosen or reply message exceeds 1000 characters.</p>
<% } else if ("noreply".equals(msg)) { %><p style="color:red">A reply is required before a ticket can be marked as Resolved.</p>
<% } else if ("notresolved".equals(msg)) { %><p style="color:red">Only tickets marked as Resolved may be deleted.</p>
<% } else if ("fail".equals(msg)) { %><p style="color:red">Failed to update ticket.</p>
<% } %>

<% String filter = (String) request.getAttribute("filter");
   if (filter == null) filter = "";
   List<String> statuses = (List<String>) request.getAttribute("statuses"); %>

<div class="ticket-filter-bar">
    <span style="font-size: 13.5px; font-weight: 600; color: var(--nx-text-muted);">Status Filter:</span>
    <a href="tickets" class="ticket-chip <%= filter.isEmpty() ? "active" : "" %>">All Tickets</a>
    <% if (statuses != null) for (String s : statuses) { %>
        <a href="tickets?status=<%= s.replace(" ", "%20") %>" class="ticket-chip <%= s.equals(filter) ? "active" : "" %>"><%= esc(s) %></a>
    <% } %>
</div>

<% List<SupportTicket> tickets = (List<SupportTicket>) request.getAttribute("tickets");
   if (tickets == null || tickets.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 50px 20px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin: 0;">No support tickets found matching this filter.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 70px;">#</th>
                <th>Customer</th>
                <th style="width: 80px;">Order</th>
                <th>Subject &amp; Description</th>
                <th style="width: 110px;">Status</th>
                <th>Staff Reply &amp; State Transition</th>
                <th style="text-align: right; width: 80px;">Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (SupportTicket t : tickets) {
                   String st = t.getStatus();
                   String badgeClass = "badge-pending";
                   if ("Resolved".equalsIgnoreCase(st)) badgeClass = "badge-delivered";
                   else if ("Closed".equalsIgnoreCase(st)) badgeClass = "badge-cancelled";
                   else if ("Open".equalsIgnoreCase(st)) badgeClass = "badge-processing";
            %>
            <tr>
                <td style="font-weight: 700;">#<%= t.getTicketId() %></td>
                <td>
                    <b><%= esc(t.getCustomerName()) %></b><br>
                    <small style="color: var(--nx-text-muted);"><%= t.getCreatedAt() %></small>
                </td>
                <td><%= t.getOrderId() == null ? "&mdash;" : "#" + t.getOrderId() %></td>
                <td style="max-width: 280px;">
                    <div style="font-weight: 700; color: var(--nx-text); margin-bottom: 4px;"><%= esc(t.getSubject()) %></div>
                    <div style="font-size: 13px; color: var(--nx-text-muted);"><%= esc(t.getMessage()) %></div>
                </td>
                <td><span class="nx-badge <%= badgeClass %>"><%= esc(st) %></span></td>
                <td>
                    <form action="tickets" method="post" novalidate onsubmit="return checkReply(this);"
                          style="display: flex; flex-direction: column; gap: 6px;">
                        <input type="hidden" name="action" value="reply">
                        <input type="hidden" name="ticketId" value="<%= t.getTicketId() %>">
                        <input type="hidden" name="filter" value="<%= esc(filter) %>">
                        <textarea name="reply" rows="2" maxlength="1000" placeholder="Type official response..."
                                  style="padding: 6px 10px; font-size: 12.5px; width: 100%;"><%= esc(t.getReply()) %></textarea>
                        <div style="display: flex; gap: 6px;">
                            <select name="status" style="padding: 5px 8px; font-size: 12.5px;">
                                <% if (statuses != null) for (String s : statuses) { %>
                                    <option value="<%= esc(s) %>" <%= s.equals(t.getStatus()) ? "selected" : "" %>><%= esc(s) %></option>
                                <% } %>
                            </select>
                            <button type="submit" class="btn-secondary" style="padding: 5px 12px; font-size: 12px;">Save</button>
                        </div>
                        <span class="reply-err"></span>
                    </form>
                </td>
                <td style="text-align: right;">
                    <% if ("Resolved".equals(t.getStatus())) { %>
                    <form action="tickets" method="post" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="ticketId" value="<%= t.getTicketId() %>">
                        <input type="hidden" name="filter" value="<%= esc(filter) %>">
                        <button type="submit" class="btn-danger" style="padding: 5px 8px; font-size: 12px;"
                                onclick="return confirm('Delete ticket #<%= t.getTicketId() %>?')">Delete</button>
                    </form>
                    <% } else { %>&mdash;<% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<script>
// Resolved කරන්න reply එකක් ඕන. Reply උපරිම 1000
function checkReply(f) {
    var reply = f.elements['reply'];
    var status = f.elements['status'].value;
    var text = reply.value.trim();
    var msg = '';

    if (text.length > 1000) {
        msg = 'Reply is too long (max 1000 characters).';
    } else if (status === 'Resolved' && text.length === 0) {
        msg = 'Please write a reply before marking this ticket as Resolved.';
    }

    reply.classList.toggle('invalid', msg !== '');
    f.querySelector('.reply-err').innerText = msg;
    return msg === '';
}
</script>
</body>
</html>