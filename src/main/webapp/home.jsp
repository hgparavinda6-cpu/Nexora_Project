<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.nexora.model.User" %>
<%
    Object homeUser = session.getAttribute("user");
    if (!(homeUser instanceof User)) {
        response.sendRedirect("login.jsp");
        return;
    }
    User hu = (User) homeUser;
    String hr = hu.getRole();

    // {link, title, description, iconName, badge}
    String[][] tasks;
    String lead;
    if ("Customer".equals(hr)) {
        lead = "Welcome to your personal shopping hub. Browse the latest arrivals, track real-time shipments, and manage your orders seamlessly.";
        tasks = new String[][]{
            {"shop", "Shop Catalogue", "Discover trending products, deals, and add items to your cart", "shopping-bag", "Popular"},
            {"orders", "My Orders", "View order history, edit pending orders, or modify addresses", "package", ""},
            {"track", "Track Delivery", "Real-time GPS tracking of your delivery officer on Google Maps", "map-pin", "Live"},
            {"offers", "Exclusive Offers", "Unlock special seasonal discounts and promo coupon codes", "tag", "Deals"},
            {"cart", "Shopping Cart", "Review your selected items and proceed to secure checkout", "shopping-cart", ""},
            {"support", "Support Helpdesk", "Open assistance tickets or contact our support representatives", "help-circle", ""},
            {"feedback", "My Feedback", "Share ratings and reviews for products you have received", "star", ""}};
    } else if ("Administrator".equals(hr)) {
        lead = "Store Management & Operations Centre. Monitor inventory, manage products, and oversee system logistics.";
        tasks = new String[][]{
            {"products", "Products Inventory", "Add, update pricing, restock or delete catalog products", "box", ""},
            {"inventory", "Stock Control", "Monitor live warehouse stock levels and inventory change logs", "archive", ""},
            {"categories", "Categories", "Organize store departments, collections and product tags", "grid", ""},
            {"manageorders", "Orders Management", "Review incoming orders, process shipments and update statuses", "clipboard", "Priority"},
            {"assigndelivery", "Dispatch Deliveries", "Assign delivery officers to orders and supervise field operations", "truck", ""},
            {"promotions", "Coupons & Promos", "Create discount vouchers, promo campaigns and minimum rules", "percent", ""},
            {"shop", "Preview Storefront", "Browse the customer-facing shop to verify catalog display", "external-link", ""}};
    } else if ("DeliveryStaff".equals(hr)) {
        lead = "Logistics Field Portal. View your assigned packages, update delivery statuses, and transmit location coordinates.";
        tasks = new String[][]{
            {"deliveries", "My Deliveries", "Review customer contacts, drop-off locations, and update statuses", "truck", "Active"}};
    } else if ("SupportOfficer".equals(hr)) {
        lead = "Customer Care Helpdesk. Resolve customer inquiries and monitor customer feedback.";
        tasks = new String[][]{
            {"tickets", "Customer Tickets", "Review, reply to, and resolve customer support questions", "message-square", "Action Needed"},
            {"feedbackadmin", "Review Moderation", "Inspect customer ratings and moderate inappropriate feedback", "star", ""}};
    } else {
        lead = "Your account has no specific operational tasks assigned yet.";
        tasks = new String[0][];
    }
    String hn = hu.getFullName() == null ? "Valued Member" : hu.getFullName()
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Welcome <%= hn %></title>
<style>
.dashboard-hero {
    background: linear-gradient(135deg, #0E3B43 0%, #165662 60%, #072328 100%);
    border-radius: var(--nx-radius-xl);
    padding: 44px 40px;
    color: #FFFFFF;
    margin-top: 32px;
    margin-bottom: 36px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 12px 36px rgba(14, 59, 67, 0.22);
}

.dashboard-hero::before {
    content: "";
    position: absolute;
    top: -50px;
    right: -50px;
    width: 280px;
    height: 280px;
    background: radial-gradient(circle, rgba(245, 158, 11, 0.22) 0%, rgba(245, 158, 11, 0) 70%);
    border-radius: 50%;
    pointer-events: none;
}

.dashboard-hero h1 {
    color: #FFFFFF;
    font-size: 34px;
    margin-top: 0;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 14px;
    flex-wrap: wrap;
}

.hero-role-pill {
    background: rgba(245, 158, 11, 0.25);
    border: 1px solid rgba(245, 158, 11, 0.5);
    color: var(--nx-accent);
    font-size: 13px;
    font-weight: 700;
    padding: 4px 12px;
    border-radius: 999px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}

.dashboard-lead {
    color: #CFE3E5;
    font-size: 16px;
    max-width: 65ch;
    margin-bottom: 24px;
    line-height: 1.6;
}

.hero-quick-actions {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
}

.hero-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    border-radius: var(--nx-radius-sm);
    font-weight: 600;
    font-size: 14px;
    text-decoration: none;
    transition: all 0.2s ease;
}

.hero-btn-primary {
    background: var(--nx-accent);
    color: #0F172A !important;
}

.hero-btn-primary:hover {
    background: #FBBF24;
    transform: translateY(-2px);
}

.hero-btn-glass {
    background: rgba(255, 255, 255, 0.12);
    color: #FFFFFF !important;
    border: 1px solid rgba(255, 255, 255, 0.25);
}

.hero-btn-glass:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: translateY(-2px);
}

/* Feature grid */
.features-strip {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 16px;
    margin-bottom: 36px;
}

.feature-pill {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius);
    padding: 16px;
    display: flex;
    align-items: center;
    gap: 14px;
    box-shadow: var(--nx-shadow-sm);
}

.feature-icon-circle {
    width: 42px;
    height: 42px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.feature-title {
    font-weight: 700;
    font-size: 14px;
    color: var(--nx-text);
}

.feature-sub {
    font-size: 12.5px;
    color: var(--nx-text-muted);
}

/* Task Cards Grid */
.tasks-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
    margin-bottom: 50px;
}

.task-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 24px;
    text-decoration: none;
    color: var(--nx-text);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    box-shadow: var(--nx-shadow-sm);
    position: relative;
    overflow: hidden;
}

.task-card:hover {
    border-color: #0E3B43;
    transform: translateY(-3px);
    box-shadow: var(--nx-shadow-hover);
}

.task-card-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 16px;
}

.task-icon-box {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background: #F0FDF4;
    border: 1px solid #DCFCE7;
    color: #166534;
    display: flex;
    align-items: center;
    justify-content: center;
}

.task-card:nth-child(2) .task-icon-box {
    background: #EFF6FF;
    border-color: #DBEAFE;
    color: #1E40AF;
}

.task-card:nth-child(3) .task-icon-box {
    background: #FAF5FF;
    border-color: #F3E8FF;
    color: #6B21A8;
}

.task-card:nth-child(4) .task-icon-box {
    background: #FFFBEB;
    border-color: #FEF3C7;
    color: #92400E;
}

.task-card:nth-child(5) .task-icon-box {
    background: #ECFEFF;
    border-color: #CFFAFE;
    color: #155E75;
}

.task-card:nth-child(6) .task-icon-box {
    background: #FFF1F2;
    border-color: #FFE4E6;
    color: #9F1239;
}

.task-badge {
    background: var(--nx-accent-light);
    color: #B45309;
    font-size: 11.5px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 999px;
    border: 1px solid #FDE68A;
}

.task-title {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 6px;
    color: var(--nx-text);
}

.task-desc {
    color: var(--nx-text-muted);
    font-size: 13.5px;
    line-height: 1.5;
    margin-bottom: 16px;
    flex-grow: 1;
}

.task-card-footer {
    display: flex;
    align-items: center;
    gap: 6px;
    font-weight: 600;
    font-size: 13.5px;
    color: var(--nx-brand);
    margin-top: auto;
}

.task-card:hover .task-card-footer {
    color: var(--nx-accent-hover);
}

@media (max-width: 768px) {
    .dashboard-hero {
        padding: 28px 20px;
    }
    .dashboard-hero h1 {
        font-size: 26px;
    }
    .tasks-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="dashboard-hero">
    <h1>
        <span>Welcome back, <%= hn %></span>
        <span class="hero-role-pill"><%= hr %></span>
    </h1>
    <p class="dashboard-lead"><%= lead %></p>
    
    <div class="hero-quick-actions">
        <% if ("Customer".equals(hr)) { %>
            <a href="shop" class="hero-btn hero-btn-primary">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                Explore Catalogue
            </a>
            <a href="orders" class="hero-btn hero-btn-glass">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                My Orders
            </a>
            <a href="track" class="hero-btn hero-btn-glass">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon></svg>
                Live Tracking
            </a>
        <% } else if ("Administrator".equals(hr)) { %>
            <a href="manageorders" class="hero-btn hero-btn-primary">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                Manage Orders
            </a>
            <a href="products" class="hero-btn hero-btn-glass">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                Catalogue & Stock
            </a>
        <% } else if ("DeliveryStaff".equals(hr)) { %>
            <a href="deliveries" class="hero-btn hero-btn-primary">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                View Assigned Deliveries
            </a>
        <% } else if ("SupportOfficer".equals(hr)) { %>
            <a href="tickets" class="hero-btn hero-btn-primary">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                Open Ticket Inquiries
            </a>
        <% } %>
    </div>
</div>

<div class="features-strip">
    <div class="feature-pill">
        <div class="feature-icon-circle" style="background:#ECFDF5; color:#059669;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
        </div>
        <div>
            <div class="feature-title">Express Delivery</div>
            <div class="feature-sub">Direct to your doorstep</div>
        </div>
    </div>
    <div class="feature-pill">
        <div class="feature-icon-circle" style="background:#EFF6FF; color:#2563EB;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
        </div>
        <div>
            <div class="feature-title">Verified Quality</div>
            <div class="feature-sub">100% Genuine products</div>
        </div>
    </div>
    <div class="feature-pill">
        <div class="feature-icon-circle" style="background:#FFFBEB; color:#D97706;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>
        </div>
        <div>
            <div class="feature-title">Real-Time GPS</div>
            <div class="feature-sub">Live route status tracking</div>
        </div>
    </div>
    <div class="feature-pill">
        <div class="feature-icon-circle" style="background:#F5F3FF; color:#7C3AED;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"></path></svg>
        </div>
        <div>
            <div class="feature-title">Dedicated Support</div>
            <div class="feature-sub">Assistance on every order</div>
        </div>
    </div>
</div>

<div class="nx-section-header">
    <h2 class="nx-section-title">Operational Portal & Shortcuts</h2>
    <p class="nx-section-lead">Quickly access management tools and services for your account.</p>
</div>

<div class="tasks-grid">
    <% for (String[] t : tasks) { %>
    <a class="task-card" href="<%= t[0] %>">
        <div>
            <div class="task-card-top">
                <div class="task-icon-box">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                </div>
                <% if (t.length > 4 && !t[4].isEmpty()) { %>
                    <span class="task-badge"><%= t[4] %></span>
                <% } %>
            </div>
            <div class="task-title"><%= t[1] %></div>
            <div class="task-desc"><%= t[2] %></div>
        </div>
        <div class="task-card-footer">
            <span>Open <%= t[1] %></span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
        </div>
    </a>
    <% } %>
</div>

</body>
</html>