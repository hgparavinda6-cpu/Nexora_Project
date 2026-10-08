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
<title>Nexora - Product Feedback & Ratings</title>
<style>
.feedback-hero {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 60%, #165662 100%);
    border-radius: var(--nx-radius-xl);
    padding: 36px;
    margin-top: 32px;
    margin-bottom: 32px;
    color: #FFFFFF;
    box-shadow: var(--nx-shadow-lg);
}

.feedback-hero h1 {
    color: #FFFFFF;
    margin-top: 0;
    margin-bottom: 8px;
    font-size: 32px;
}

.feedback-hero p {
    color: #CFE3E5;
    margin-bottom: 0;
    font-size: 15px;
}

.stars-gold {
    color: var(--nx-accent);
    font-size: 16px;
    letter-spacing: 2px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="feedback-hero">
    <h1>Product Reviews & Feedback</h1>
    <p>Rate the products from your delivered orders and help other Nexora customers shop with confidence.</p>
</div>

<% String msg = request.getParameter("msg");
   if ("created".equals(msg)) { %><p style="color:green">Thank you! Your product review was saved.</p>
<% } else if ("updated".equals(msg)) { %><p style="color:green">Your feedback was updated successfully.</p>
<% } else if ("deleted".equals(msg)) { %><p style="color:green">Feedback review deleted.</p>
<% } else if ("invalid".equals(msg)) { %><p style="color:red">Please select a rating (1-5 stars). Comments can be up to 500 characters.</p>
<% } else if ("duplicate".equals(msg)) { %><p style="color:red">You have already submitted a review for this product. You can update it below.</p>
<% } else if ("noteligible".equals(msg)) { %><p style="color:red">You can only review items from Delivered orders.</p>
<% } else if ("fail".equals(msg)) { %><p style="color:red">That feedback could not be modified.</p>
<% } %>

<% Feedback ef = (Feedback) request.getAttribute("editFeedback");
   if (ef != null) { %>
    <div class="nx-card" style="margin-bottom: 36px; max-width: 620px;">
        <h3 style="margin-top: 0;">Edit Review for <%= esc(ef.getProductName()) %></h3>
        <form action="feedback" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="feedbackId" value="<%= ef.getFeedbackId() %>">
            
            <label for="ratingEdit">Rating</label>
            <select id="ratingEdit" name="rating" style="width: 100%; margin-bottom: 16px;">
                <% for (int r = 5; r >= 1; r--) { %>
                    <option value="<%= r %>" <%= r == ef.getRating() ? "selected" : "" %>><%= r %> Stars (<%= stars(r) %>)</option>
                <% } %>
            </select>
            
            <label for="commentEdit">Your Review Comment</label>
            <textarea id="commentEdit" name="comment" rows="3" maxlength="500" style="width: 100%; margin-bottom: 18px;"><%= esc(ef.getComment()) %></textarea>
            
            <div style="display: flex; gap: 10px; align-items: center;">
                <button type="submit">Update Review</button>
                <a href="feedback" class="btn-secondary" style="padding: 10px 18px;">Cancel</a>
            </div>
        </form>
    </div>
<% } else { %>
    <div class="nx-card" style="margin-bottom: 36px; max-width: 620px;">
        <h3 style="margin-top: 0;">Rate a Delivered Product</h3>
        <% List<String[]> reviewable = (List<String[]>) request.getAttribute("reviewable");
           if (reviewable == null || reviewable.isEmpty()) { %>
            <p style="color: var(--nx-text-muted); font-size: 14px; margin-bottom: 0;">
                No unreviewed products right now. Once your orders are marked as <b>Delivered</b>, eligible items will appear here for rating.
            </p>
        <% } else { %>
        <form action="feedback" method="post">
            <input type="hidden" name="action" value="create">
            
            <label for="prodSelect">Choose Product</label>
            <select id="prodSelect" name="productId" style="width: 100%; margin-bottom: 16px;">
                <% for (String[] p : reviewable) { %>
                    <option value="<%= p[0] %>"><%= esc(p[1]) %> (Order #<%= p[2] %>)</option>
                <% } %>
            </select>
            
            <label for="ratingCreate">Rating</label>
            <select id="ratingCreate" name="rating" style="width: 100%; margin-bottom: 16px;">
                <% for (int r = 5; r >= 1; r--) { %>
                    <option value="<%= r %>"><%= r %> Stars (<%= stars(r) %>)</option>
                <% } %>
            </select>
            
            <label for="commentCreate">Review Comment</label>
            <textarea id="commentCreate" name="comment" rows="3" maxlength="500" placeholder="Share your experience with this item..." style="width: 100%; margin-bottom: 18px;"></textarea>
            
            <button type="submit">Submit Review</button>
        </form>
        <% } %>
    </div>
<% } %>

<h2 style="font-size: 22px; margin-bottom: 14px;">My Submitted Reviews</h2>
<% List<Feedback> mine = (List<Feedback>) request.getAttribute("myFeedback");
   if (mine == null || mine.isEmpty()) { %>
    <div class="nx-card" style="text-align: center; padding: 40px 20px; margin-bottom: 50px;">
        <p style="color: var(--nx-text-muted); margin-bottom: 0;">You have not posted any product feedback yet.</p>
    </div>
<% } else { %>
<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th>Product</th>
                <th>Rating</th>
                <th>Comment</th>
                <th>Date Posted</th>
                <th style="text-align: right;">Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Feedback f : mine) { %>
            <tr>
                <td style="font-weight: 700;"><%= esc(f.getProductName()) %></td>
                <td><span class="stars-gold"><%= stars(f.getRating()) %></span></td>
                <td style="font-size: 13.5px;"><%= esc(f.getComment()) %></td>
                <td style="font-size: 12.5px; color: var(--nx-text-muted);"><%= f.getCreatedAt() %></td>
                <td style="text-align: right; white-space: nowrap;">
                    <form action="feedback" method="get" style="display:inline">
                        <input type="hidden" name="edit" value="<%= f.getFeedbackId() %>">
                        <button type="submit" class="btn-secondary" style="padding: 5px 10px; font-size: 12px;">Edit</button>
                    </form>
                    <form action="feedback" method="post" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="feedbackId" value="<%= f.getFeedbackId() %>">
                        <button type="submit" class="btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                onclick="return confirm('Delete this feedback review?')">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

</body>
</html>