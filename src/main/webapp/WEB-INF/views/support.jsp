<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.SupportTicket, com.nexora.model.Order" %>
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
<title>Nexora - Customer Support</title>
<style>
.support-hero {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 60%, #165662 100%);
    border-radius: var(--nx-radius-xl);
    padding: 36px;
    margin-top: 32px;
    margin-bottom: 32px;
    color: #FFFFFF;
    box-shadow: var(--nx-shadow-lg);
}

.support-hero h1 {
    color: #FFFFFF;
    margin-top: 0;
    margin-bottom: 8px;
    font-size: 32px;
}

.support-hero p {
    color: #CFE3E5;
    margin-bottom: 0;
    font-size: 15px;
}

/* Inline validation */
.form-err {
    display: block;
    color: #b91c1c;
    font-size: 12.5px;
    margin-bottom: 12px;
    min-height: 0;
}

.char-count {
    display: block;
    text-align: right;
    font-size: 12px;
    color: var(--nx-text-muted);
    margin-top: -12px;
    margin-bottom: 14px;
}

input.invalid, textarea.invalid {
    border-color: #b91c1c !important;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="support-hero">
    <h1>Customer Support Helpdesk</h1>
    <p>Submit inquiries regarding orders, deliveries, or account services. Our dedicated support team is here to assist.</p>
</div>

<% String msg = request.getParameter("msg");
   if ("created".equals(msg)) { %><p style="color:green">Your support ticket was sent successfully. We will reply soon.</p>
<% } else if ("updated".equals(msg)) { %><p style="color:green">Support ticket updated successfully.</p>
<% } else if ("deleted".equals(msg)) { %><p style="color:green">Ticket deleted from your records.</p>
<% } else if ("invalid".equals(msg)) { %><p style="color:red">Subject must be 3 to 100 characters and the message 10 to 1000 characters.</p>
<% } else if ("badorder".equals(msg)) { %><p style="color:red">Specified order is not associated with your account.</p>
<% } else if ("locked".equals(msg)) { %><p style="color:red">Only Open tickets can be modified.</p>
<% } else if ("fail".equals(msg)) { %><p style="color:red">Could not delete that ticket.</p>
<% } %>

<% SupportTicket editTicket = (SupportTicket) request.getAttribute("editTicket");
   if (editTicket != null) { %>
    <div class="nx-card" style="margin-bottom: 36px; max-width: 640px;">
        <h3 style="margin-top: 0;">Edit Ticket #<%= editTicket.getTicketId() %></h3>
        <form action="support" method="post" novalidate onsubmit="return checkTicket(this);">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="ticketId" value="<%= editTicket.getTicketId() %>">

            <label for="editSubject">Subject</label>
            <input id="editSubject" type="text" name="subject" maxlength="100" style="width: 100%; margin-bottom: 16px;"
                   value="<%= esc(editTicket.getSubject()) %>">

            <label for="editMessage">Message Description</label>
            <textarea id="editMessage" name="message" rows="4" maxlength="1000" style="width: 100%; margin-bottom: 16px;"><%= esc(editTicket.getMessage()) %></textarea>

            <span class="form-err"></span>

            <div style="display: flex; gap: 10px; align-items: center;">
                <button type="submit">Save Changes</button>
                <a href="support" class="btn-secondary" style="padding: 10px 18px;">Cancel</a>
            </div>
        </form>
    </div>
<% } else { %>
    <div class="nx-card" style="margin-bottom: 36px; max-width: 680px;">
        <h3 style="margin-top: 0;">Open a New Support Ticket</h3>
        <form action="support" method="post" novalidate onsubmit="return checkTicket(this);">
            <input type="hidden" name="action" value="create">

            <label for="orderSelect">Related Order (Optional)</label>
            <select id="orderSelect" name="orderId" style="width: 100%; margin-bottom: 16px;">
                <option value="">-- No specific order --</option>
                <% for (Order o : (List<Order>) request.getAttribute("orders")) { %>
                    <option value="<%= o.getOrderId() %>">Order #<%= o.getOrderId() %> (<%= o.getCreatedAt() %> &mdash; <%= esc(o.getStatus()) %>)</option>
                <% } %>
            </select>

            <label for="ticketSubject">Subject</label>
            <input id="ticketSubject" type="text" name="subject" maxlength="100" placeholder="e.g. Question about delivery time" style="width: 100%; margin-bottom: 16px;">

            <label for="ticketMessage">Message Details</label>
            <textarea id="ticketMessage" name="message" rows="4" maxlength="1000" placeholder="Describe the issue or inquiry in detail (at least 10 characters)..." style="width: 100%; margin-bottom: 20px;"></textarea>

            <span class="form-err"></span>

            <button type="submit">Send Ticket</button>
        </form>
    </div>
<% } %>

<h2 style="font-size: 22px; margin-bottom: 14px;">My Support Tickets</h2>
<% List<SupportTicket> tickets = (List<SupportTicket>) request.getAttribute("tickets");
   if (tickets == null || tickets.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 40px 20px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin-bottom: 0;">You have not submitted any support tickets yet.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Ticket #</th>
                <th>Order</th>
                <th>Subject</th>
                <th>Message</th>
                <th>Status</th>
                <th>Support Response</th>
                <th>Updated</th>
                <th style="text-align: right;">Action</th>
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
                <td><%= t.getOrderId() == null ? "-" : "#" + t.getOrderId() %></td>
                <td style="font-weight: 600;"><%= esc(t.getSubject()) %></td>
                <td style="max-width: 260px; font-size: 13.5px;"><%= esc(t.getMessage()) %></td>
                <td><span class="nx-badge <%= badgeClass %>"><%= esc(st) %></span></td>
                <td style="font-size: 13.5px;"><%= (t.getReply() == null || t.getReply().isEmpty()) ? "<span style='color:var(--nx-text-muted);'>Awaiting reply</span>" : esc(t.getReply()) %></td>
                <td style="font-size: 12.5px; color: var(--nx-text-muted);"><%= t.getUpdatedAt() %></td>
                <td style="text-align: right; white-space: nowrap;">
                    <% if ("Open".equals(t.getStatus())) { %>
                        <form action="support" method="get" style="display:inline">
                            <input type="hidden" name="edit" value="<%= t.getTicketId() %>">
                            <button type="submit" class="btn-secondary" style="padding: 5px 10px; font-size: 12px;">Edit</button>
                        </form>
                    <% } %>
                    <form action="support" method="post" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="ticketId" value="<%= t.getTicketId() %>">
                        <button type="submit" class="btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                onclick="return confirm('Delete ticket #<%= t.getTicketId() %>?')">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<script>
// Subject 3-100, Message 10-1000
function checkTicket(f) {
    var subject = f.elements['subject'];
    var message = f.elements['message'];
    var s = subject.value.trim();
    var m = message.value.trim();
    var msg = '';
    var badEl = null;

    if (s.length < 3 || s.length > 100) {
        msg = 'Subject must be 3 to 100 characters.'; badEl = subject;
    } else if (m.length < 10 || m.length > 1000) {
        msg = 'Message must be 10 to 1000 characters (currently ' + m.length + ').'; badEl = message;
    }

    subject.classList.remove('invalid');
    message.classList.remove('invalid');
    if (badEl) badEl.classList.add('invalid');

    f.querySelector('.form-err').innerText = msg;
    return msg === '';
}
</script>
</body>
</html>