<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Feedback" %>
<%!
    static String esc(String s) {
        return s == null ? "" : s.replace("&", "&amp;").replace("<", "&lt;")
                                 .replace(">", "&gt;").replace("\"", "&quot;");
    }
    static String stars(int n) {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) sb.append(i <= n ? "\u2605" : "\u2606");
        return sb.toString();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Customer Feedback Moderation</title>
<style>
.star-filter-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin: 20px 0 24px;
}

.star-chip {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    color: var(--nx-text);
}

.star-chip:hover {
    border-color: var(--nx-brand);
}

.star-chip.active {
    background: var(--nx-brand);
    color: #FFFFFF;
    border-color: var(--nx-brand);
}

.feedback-stats-row {
    display: flex;
    gap: 16px;
    margin-bottom: 24px;
}

.stat-pill {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius);
    padding: 14px 20px;
    display: flex;
    align-items: center;
    gap: 12px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">Customer Reviews & Feedback Moderation</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Inspect customer sentiment, average product satisfaction scores, and moderate submitted reviews.</p>

<% String msg = request.getParameter("msg");
   if ("deleted".equals(msg)) { %><p style="color:green">Feedback review removed from public catalogue.</p>
<% } else if ("fail".equals(msg)) { %><p style="color:red">Could not delete that feedback.</p>
<% } %>

<% List<Feedback> all = (List<Feedback>) request.getAttribute("feedbackList");
   if (all == null) all = Collections.emptyList();
   String only = request.getParameter("rating");
   int sum = 0;
   for (Feedback f : all) sum += f.getRating();
   double avg = all.isEmpty() ? 0.0 : (sum / (double) all.size());
%>

<div class="feedback-stats-row">
    <div class="stat-pill">
        <div>
            <div style="font-size: 12px; color: var(--nx-text-muted); font-weight: 600;">TOTAL REVIEWS</div>
            <div style="font-size: 22px; font-weight: 800; color: var(--nx-text);"><%= all.size() %></div>
        </div>
    </div>
    <div class="stat-pill">
        <div>
            <div style="font-size: 12px; color: var(--nx-text-muted); font-weight: 600;">AVERAGE RATING</div>
            <div style="font-size: 22px; font-weight: 800; color: #D97706;"><%= String.format("%.1f", avg) %> / 5.0</div>
        </div>
    </div>
</div>

<div class="star-filter-bar">
    <span style="font-size: 13.5px; font-weight: 600; color: var(--nx-text-muted);">Rating Filter:</span>
    <a href="feedbackadmin" class="star-chip <%= only == null ? "active" : "" %>">All Ratings</a>
    <% for (int r = 5; r >= 1; r--) { %>
        <a href="feedbackadmin?rating=<%= r %>" class="star-chip <%= String.valueOf(r).equals(only) ? "active" : "" %>">
            <%= r %> &#9733;
        </a>
    <% } %>
</div>

<% int shown = 0; %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 70px;">#</th>
                <th>Customer</th>
                <th>Product</th>
                <th style="width: 90px;">Order #</th>
                <th style="width: 140px;">Rating</th>
                <th>Review Comment</th>
                <th style="width: 140px;">Date Posted</th>
                <th style="text-align: right; width: 80px;">Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Feedback f : all) {
                   if (only != null && !only.equals(String.valueOf(f.getRating()))) continue;
                   shown++;
            %>
            <tr>
                <td style="font-weight: 700;">#<%= f.getFeedbackId() %></td>
                <td style="font-weight: 600;"><%= esc(f.getCustomerName()) %></td>
                <td style="font-weight: 600; color: var(--nx-brand);"><%= esc(f.getProductName()) %></td>
                <td><%= f.getOrderId() == null ? "&mdash;" : "#" + f.getOrderId() %></td>
                <td><span style="color: #D97706; font-size: 15px;"><%= stars(f.getRating()) %></span></td>
                <td style="font-size: 13.5px;"><%= esc(f.getComment()) %></td>
                <td style="font-size: 12.5px; color: var(--nx-text-muted);"><%= f.getCreatedAt() %></td>
                <td style="text-align: right;">
                    <form action="feedbackadmin" method="post" style="display:inline">
                        <input type="hidden" name="feedbackId" value="<%= f.getFeedbackId() %>">
                        <button type="submit" class="btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                onclick="return confirm('Permanently delete review #<%= f.getFeedbackId() %>?')">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% if (shown == 0) { %>
        <p style="padding: 24px; color: var(--nx-text-muted); text-align: center; margin: 0;">No customer feedback found matching this rating level.</p>
    <% } %>
</div>

</body>
</html>