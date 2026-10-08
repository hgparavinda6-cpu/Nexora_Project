<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.nexora.model.Order, com.nexora.model.Delivery" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Real-Time Order Tracking</title>
<style>
.track-hero {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 60%, #165662 100%);
    border-radius: var(--nx-radius-xl);
    padding: 36px;
    margin-top: 32px;
    margin-bottom: 32px;
    color: #FFFFFF;
    box-shadow: var(--nx-shadow-lg);
}

.track-hero h1 {
    color: #FFFFFF;
    margin-top: 0;
    margin-bottom: 8px;
    font-size: 32px;
}

.track-hero p {
    color: #CFE3E5;
    margin-bottom: 24px;
    font-size: 14.5px;
}

.track-form-card {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: var(--nx-radius);
    padding: 16px 20px;
    display: inline-flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    max-width: 100%;
}

.track-form-card input[type=number] {
    width: 220px;
    background: #FFFFFF;
}

.track-form-card button {
    background: var(--nx-accent);
    color: #0F172A;
    font-weight: 700;
}

.track-form-card button:hover {
    background: #FBBF24;
}

/* Stepper */
.progress-stepper {
    display: flex;
    justify-content: space-between;
    position: relative;
    margin: 40px 0;
    max-width: 800px;
}

.progress-stepper::before {
    content: "";
    position: absolute;
    top: 20px;
    left: 20px;
    right: 20px;
    height: 3px;
    background: var(--nx-border);
    z-index: 1;
}

.step-node {
    position: relative;
    z-index: 2;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    width: 120px;
}

.node-circle {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    background: #FFFFFF;
    border: 3px solid var(--nx-border);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 14px;
    color: var(--nx-text-muted);
    margin-bottom: 8px;
    transition: all 0.3s ease;
}

.step-node.completed .node-circle {
    background: #0E3B43;
    border-color: #0E3B43;
    color: #FFFFFF;
}

.step-node.active .node-circle {
    background: var(--nx-accent);
    border-color: var(--nx-accent);
    color: #0F172A;
    box-shadow: 0 0 0 5px rgba(245, 158, 11, 0.25);
}

.node-label {
    font-size: 13px;
    font-weight: 600;
    color: var(--nx-text);
}

/* Map Card */
.map-container-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    overflow: hidden;
    box-shadow: var(--nx-shadow);
    margin-top: 28px;
    margin-bottom: 50px;
}

.map-header-bar {
    padding: 16px 20px;
    background: #F8FAFC;
    border-bottom: 1px solid var(--nx-border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.live-pulse {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #059669;
    font-weight: 700;
    font-size: 13px;
}

.pulse-dot {
    width: 8px;
    height: 8px;
    background: #10B981;
    border-radius: 50%;
    animation: livePulseAnim 1.8s infinite;
}

@keyframes livePulseAnim {
    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
    70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
}

.map-embed {
    width: 100%;
    height: 440px;
    border: none;
    display: block;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="track-hero">
    <h1>Track Order Status</h1>
    <p>Enter your Order ID to see real-time updates and live location coordinates on the map.</p>

    <form action="track" method="get" class="track-form-card">
        <label for="orderIdInput" style="color: #FFFFFF; margin: 0; font-size: 14px;">Order ID:</label>
        <input id="orderIdInput" type="number" name="orderId" min="1" required placeholder="e.g. 1024"
               value="<%= request.getParameter("orderId") == null ? "" : request.getParameter("orderId").replaceAll("[^0-9]", "") %>">
        <button type="submit">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            Track Order
        </button>
    </form>
</div>

<% if (request.getAttribute("notFound") != null) { %>
    <p style="color:red">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        Order not found. Please verify your Order ID and try again.
    </p>
<% } %>

<% Order order = (Order) request.getAttribute("order");
   if (order != null) {
       Delivery d = (Delivery) request.getAttribute("delivery");
       String[] loc = (String[]) request.getAttribute("location");
       boolean live = d != null && "Out for Delivery".equals(d.getStatus());
       String st = order.getStatus();

       boolean step1 = true;
       boolean step2 = "Processing".equalsIgnoreCase(st) || "Out for Delivery".equalsIgnoreCase(st) || "Delivered".equalsIgnoreCase(st);
       boolean step3 = "Out for Delivery".equalsIgnoreCase(st) || "Delivered".equalsIgnoreCase(st);
       boolean step4 = "Delivered".equalsIgnoreCase(st);
%>

    <!-- Status Stepper -->
    <div class="progress-stepper">
        <div class="step-node <%= step1 ? (step2 ? "completed" : "active") : "" %>">
            <div class="node-circle">&#10003;</div>
            <div class="node-label">Order Placed</div>
        </div>
        <div class="step-node <%= step2 ? (step3 ? "completed" : "active") : "" %>">
            <div class="node-circle"><%= step2 && !step3 ? "2" : (step3 ? "&#10003;" : "2") %></div>
            <div class="node-label">Processing</div>
        </div>
        <div class="step-node <%= step3 ? (step4 ? "completed" : "active") : "" %>">
            <div class="node-circle"><%= step3 && !step4 ? "3" : (step4 ? "&#10003;" : "3") %></div>
            <div class="node-label">Out for Delivery</div>
        </div>
        <div class="step-node <%= step4 ? "completed" : "" %>">
            <div class="node-circle">&#9733;</div>
            <div class="node-label">Delivered</div>
        </div>
    </div>

    <!-- Order Info Details -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-bottom: 24px;">
        <div class="nx-card">
            <h3 style="margin-top: 0; font-size: 16px;">Order Details #<%= order.getOrderId() %></h3>
            <p style="font-size: 14px; margin-bottom: 6px;"><b>Status:</b> <span class="nx-badge badge-pending"><%= order.getStatus() %></span></p>
            <p style="font-size: 14px; margin-bottom: 0;"><b>Address:</b> <%= order.getAddress() %></p>
        </div>

        <div class="nx-card">
            <h3 style="margin-top: 0; font-size: 16px;">Logistics & Dispatch</h3>
            <% if (d == null) { %>
                <p style="color: var(--nx-text-muted); font-size: 14px;">A delivery officer has not been dispatched yet. We will assign one once packing is complete.</p>
            <% } else { %>
                <p style="font-size: 14px; margin-bottom: 6px;"><b>Officer:</b> <%= d.getStaffName() %></p>
                <p style="font-size: 14px; margin-bottom: 6px;"><b>Status:</b> <%= d.getStatus() %></p>
                <p style="font-size: 13px; color: var(--nx-text-muted); margin-bottom: 0;"><b>Last Ping:</b> <%= d.getUpdatedAt() %>
                    <% if (!d.getNotes().isEmpty()) { %><br><b>Driver Note:</b> <%= d.getNotes() %><% } %></p>
            <% } %>
        </div>
    </div>

    <!-- Live Map View -->
    <% if (d != null) { %>
        <% if (loc != null) { %>
            <div class="map-container-card">
                <div class="map-header-bar">
                    <div>
                        <span style="font-weight: 700; font-size: 15px;"><%= live ? "Real-Time Courier GPS Position" : "Last Recorded Location" %></span>
                        <div style="font-size: 12.5px; color: var(--nx-text-muted);">Pinged at: <%= loc[2] %></div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <% if (live) { %>
                            <span class="live-pulse">
                                <span class="pulse-dot"></span>
                                Live Sync (20s)
                            </span>
                        <% } %>
                        <a href="https://www.google.com/maps?q=<%= loc[0] %>,<%= loc[1] %>" target="_blank"
                           class="btn-secondary" style="font-size: 12.5px; padding: 6px 12px;">
                            Open in Google Maps
                        </a>
                    </div>
                </div>
                <iframe class="map-embed"
                        src="https://maps.google.com/maps?q=<%= loc[0] %>,<%= loc[1] %>&z=15&output=embed"></iframe>
            </div>
        <% } else if (live) { %>
            <div class="nx-card" style="text-align: center; padding: 36px 20px; margin-bottom: 40px;">
                <p style="color: var(--nx-brand); font-weight: 600; font-size: 15px; margin-bottom: 4px;">
                    The delivery is currently en route.
                </p>
                <p style="color: var(--nx-text-muted); font-size: 13.5px; margin-bottom: 0;">
                    Waiting for the delivery officer to transmit GPS location coordinates...
                </p>
            </div>
        <% } %>
    <% } %>

    <% if (live) { %>
    <script>setTimeout(function () { location.reload(); }, 20000);</script>
    <% } %>
<% } %>

</body>
</html>