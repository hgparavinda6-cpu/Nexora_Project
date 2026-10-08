<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Product" %>
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
<title>Nexora - Premium Store Catalogue</title>
<style>
/* Storefront Hero */
.shop-hero {
    background: linear-gradient(135deg, #072328 0%, #0E3B43 55%, #165662 100%);
    border-radius: var(--nx-radius-xl);
    padding: 38px 36px;
    margin-top: 32px;
    margin-bottom: 32px;
    color: #FFFFFF;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    overflow: hidden;
    box-shadow: var(--nx-shadow-lg);
}

.shop-hero-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: rgba(245, 158, 11, 0.2);
    border: 1px solid rgba(245, 158, 11, 0.45);
    color: var(--nx-accent);
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 4px 12px;
    border-radius: 999px;
    margin-bottom: 12px;
}

.shop-hero h1 {
    color: #FFFFFF;
    font-size: 34px;
    margin-top: 0;
    margin-bottom: 10px;
}

.shop-hero p {
    color: #CFE3E5;
    font-size: 15px;
    margin-bottom: 0;
    max-width: 520px;
}

/* Filter & Search Bar */
.shop-controls {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    padding: 16px 20px;
    margin-bottom: 32px;
    box-shadow: var(--nx-shadow-sm);
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 14px;
}

.search-input-wrap {
    position: relative;
    flex: 1;
    min-width: 260px;
}

.search-input-wrap svg {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--nx-text-muted);
    pointer-events: none;
}

.search-input-wrap input {
    width: 100%;
    padding-left: 42px;
}

.shop-controls select {
    min-width: 180px;
}

.shop-count {
    margin-left: auto;
    color: var(--nx-text-muted);
    font-size: 13.5px;
    font-weight: 600;
    background: var(--nx-card-subtle);
    padding: 6px 14px;
    border-radius: 999px;
    border: 1px solid var(--nx-border);
}

/* Products Grid */
.shop-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 28px;
    margin-bottom: 60px;
}

.product-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-lg);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    transition: all 0.28s cubic-bezier(0.16, 1, 0.3, 1);
    box-shadow: var(--nx-shadow-sm);
    position: relative;
}

.product-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--nx-shadow-hover);
    border-color: #B4D1D6;
}

.product-visual {
    position: relative;
    aspect-ratio: 4 / 3;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    background: linear-gradient(135deg, #112F35 0%, #1A4E57 100%);
}

.product-card.palette-0 .product-visual { background: linear-gradient(135deg, #0F2027, #203A43, #2C5364); }
.product-card.palette-1 .product-visual { background: linear-gradient(135deg, #141E30, #243B55); }
.product-card.palette-2 .product-visual { background: linear-gradient(135deg, #16222F, #1F4037); }
.product-card.palette-3 .product-visual { background: linear-gradient(135deg, #1A1A24, #2A363B); }

/* PRODUCT IMAGE: card එකේ උඩ සම්පූර්ණයෙන් පිරෙනවා */
.product-img {
    position: absolute;
    top: 0; left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    z-index: 1;
    transition: transform 0.4s ease;
}

.product-card:hover .product-img {
    transform: scale(1.06);
}

.product-visual.has-img::after {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 70px;
    background: linear-gradient(to bottom, rgba(0,0,0,0.35), rgba(0,0,0,0));
    z-index: 2;
    pointer-events: none;
}

.product-monogram {
    width: 80px;
    height: 80px;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.12);
    border: 1px solid rgba(255, 255, 255, 0.25);
    backdrop-filter: blur(8px);
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 38px;
    font-weight: 800;
    color: #FFFFFF;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
    transition: transform 0.3s ease;
}

.product-card:hover .product-monogram {
    transform: scale(1.08) rotate(-2deg);
}

.product-category-tag {
    position: absolute;
    top: 14px;
    left: 14px;
    z-index: 3;
    background: rgba(15, 23, 42, 0.65);
    backdrop-filter: blur(6px);
    color: #FFFFFF;
    font-size: 11px;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 6px;
    border: 1px solid rgba(255, 255, 255, 0.15);
}

.product-stock-overlay {
    position: absolute;
    top: 14px;
    right: 14px;
    z-index: 3;
}

.product-body {
    padding: 20px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.product-name {
    font-size: 17px;
    font-weight: 700;
    color: var(--nx-text);
    margin-bottom: 6px;
    line-height: 1.35;
}

.product-desc {
    color: var(--nx-text-muted);
    font-size: 13px;
    line-height: 1.5;
    margin-bottom: 14px;
    flex-grow: 1;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.product-price-row {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-top: auto;
    padding-top: 12px;
    border-top: 1px solid var(--nx-border);
}

.price-currency {
    font-size: 13px;
    font-weight: 600;
    color: var(--nx-text-muted);
}

.price-amount {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 20px;
    font-weight: 800;
    color: #0E3B43;
}

.product-stock-label {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 12.5px;
    font-weight: 600;
    margin-top: 10px;
}

.stock-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
}

.stock-in { color: #059669; }
.stock-in .stock-dot { background: #10B981; box-shadow: 0 0 6px rgba(16, 185, 129, 0.4); }

.stock-low { color: #D97706; }
.stock-low .stock-dot { background: #F59E0B; box-shadow: 0 0 6px rgba(245, 158, 11, 0.4); }

.stock-out { color: #DC2626; }
.stock-out .stock-dot { background: #EF4444; }

/* Product Add Form */
.product-add-form {
    display: flex;
    gap: 8px;
    margin-top: 14px;
}

.quantity-stepper {
    display: flex;
    align-items: center;
    background: var(--nx-card-subtle);
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-sm);
    overflow: hidden;
    width: 100px;
}

.quantity-stepper.invalid {
    border-color: #b91c1c;
}

.quantity-stepper button {
    background: transparent;
    border: none;
    box-shadow: none;
    color: var(--nx-text);
    padding: 0 8px;
    font-size: 16px;
    font-weight: 700;
    cursor: pointer;
    height: 100%;
}

.quantity-stepper button:hover {
    background: rgba(0, 0, 0, 0.05);
    transform: none;
    color: var(--nx-brand);
}

.quantity-stepper input[type=number] {
    width: 100%;
    border: none;
    background: transparent;
    text-align: center;
    padding: 8px 2px;
    box-shadow: none;
    font-weight: 700;
    -moz-appearance: textfield;
}

.quantity-stepper input[type=number]::-webkit-outer-spin-button,
.quantity-stepper input[type=number]::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

.btn-add-cart {
    flex: 1;
    background: var(--nx-brand);
    color: #FFFFFF;
    font-size: 13.5px;
    padding: 10px 14px;
}

.btn-add-cart:hover {
    background: #14525D;
}

/* Inline quantity validation message */
.qty-error {
    color: #b91c1c;
    font-size: 12px;
    margin-top: 6px;
    min-height: 0;
}

/* Empty State */
.shop-empty {
    background: #FFFFFF;
    border: 1px dashed var(--nx-border-strong);
    border-radius: var(--nx-radius-xl);
    padding: 60px 24px;
    text-align: center;
    max-width: 500px;
    margin: 40px auto;
}

.shop-empty-icon {
    width: 64px;
    height: 64px;
    background: var(--nx-card-subtle);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 18px;
    color: var(--nx-text-muted);
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="shop-hero">
    <div>
        <div class="shop-hero-badge">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
            Premium Collection
        </div>
        <h1>Explore Products</h1>
        <p>Premium quality items backed by authentic guarantees, express delivery, and real-time live map tracking.</p>
    </div>
</div>

<% String shopErr = request.getParameter("error");
   if (shopErr != null) {
       String shopMsg = "qty".equals(shopErr)
               ? "Quantity must be a whole number of 1 or more."
               : "Requested quantity exceeds available warehouse stock.";
%>
    <p style="color:red">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
        <%= shopMsg %>
    </p>
<% } %>

<% List<Product> products = (List<Product>) request.getAttribute("products"); %>

<form action="shop" method="get" class="shop-controls">
    <div class="search-input-wrap">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        <input type="text" name="q" placeholder="Search by product name or description..."
               value="<%= esc((String) request.getAttribute("q")) %>">
    </div>

    <select name="categoryId" onchange="this.form.submit()">
        <option value="0">All Categories</option>
        <% Map<Integer, String> cats = (Map<Integer, String>) request.getAttribute("categories");
           int selected = (Integer) request.getAttribute("selectedCategory");
           for (Map.Entry<Integer, String> c : cats.entrySet()) { %>
            <option value="<%= c.getKey() %>" <%= c.getKey() == selected ? "selected" : "" %>>
                <%= esc(c.getValue()) %>
            </option>
        <% } %>
    </select>

    <button type="submit">Filter</button>

    <div class="shop-count">
        <%= products.size() %> Product<%= products.size() == 1 ? "" : "s" %> Available
    </div>
</form>

<% if (products.isEmpty()) { %>
    <div class="shop-empty">
        <div class="shop-empty-icon">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </div>
        <h3 style="margin-bottom: 8px;">No matching products found</h3>
        <p style="color: var(--nx-text-muted); font-size: 14px; margin-bottom: 20px;">We couldn't find anything matching your search terms or category selection.</p>
        <a href="shop" class="btn">View All Products</a>
    </div>
<% } else { %>
<div class="shop-grid">
    <% int idx = 0;
       for (Product p : products) {
           String nm = p.getProductName() == null ? "" : p.getProductName().trim();
           String letter = nm.isEmpty() ? "N" : nm.substring(0, 1).toUpperCase();
           boolean in = p.getStockQty() > 0;
           boolean low = in && p.getStockQty() <= 5;

           String img = p.getImageUrl() == null ? "" : p.getImageUrl().trim();
           boolean hasImg = !img.isEmpty();
           String imgSrc = "";
           if (hasImg) {
               imgSrc = (img.startsWith("http://") || img.startsWith("https://"))
                       ? img
                       : request.getContextPath() + "/" + img.replaceFirst("^/+", "");
           } %>
    <div class="product-card palette-<%= idx % 4 %><%= in ? "" : " out-of-stock" %>">
        <div class="product-visual<%= hasImg ? " has-img" : "" %>">
            <span class="product-category-tag"><%= esc(p.getCategoryName()) %></span>
            <div class="product-monogram"><%= esc(letter) %></div>
            <% if (hasImg) { %>
                <img class="product-img" src="<%= esc(imgSrc) %>" alt="<%= esc(p.getProductName()) %>"
                     loading="lazy" onerror="this.style.display='none'">
            <% } %>
            <div class="product-stock-overlay">
                <% if (!in) { %>
                    <span class="nx-badge badge-cancelled">Out of Stock</span>
                <% } else if (low) { %>
                    <span class="nx-badge badge-pending">Low Stock</span>
                <% } else { %>
                    <span class="nx-badge badge-delivered">In Stock</span>
                <% } %>
            </div>
        </div>

        <div class="product-body">
            <div class="product-name"><%= esc(p.getProductName()) %></div>

            <% if (p.getDescription() != null && !p.getDescription().trim().isEmpty()) { %>
                <div class="product-desc"><%= esc(p.getDescription()) %></div>
            <% } else { %>
                <div class="product-desc" style="opacity: 0.5;">Genuine premium selection from <%= esc(p.getCategoryName()) %>.</div>
            <% } %>

            <div class="product-stock-label <%= !in ? "stock-out" : (low ? "stock-low" : "stock-in") %>">
                <span class="stock-dot"></span>
                <% if (!in) { %>
                    Unavailable
                <% } else if (low) { %>
                    Only <%= p.getStockQty() %> left in stock
                <% } else { %>
                    <%= p.getStockQty() %> available
                <% } %>
            </div>

            <div class="product-price-row">
                <span class="price-currency">Price</span>
                <span class="price-amount">Rs. <%= p.getPrice() %></span>
            </div>

            <% if (in) { %>
            <form action="cart" method="post" class="product-add-form" novalidate onsubmit="return checkQty(this);">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                <div class="quantity-stepper">
                    <button type="button" onclick="var q=this.parentElement.querySelector('input'); if(parseInt(q.value)>1) q.value=parseInt(q.value)-1;">-</button>
                    <input type="number" name="quantity" value="1" min="1" max="<%= p.getStockQty() %>" step="1" aria-label="Quantity">
                    <button type="button" onclick="var q=this.parentElement.querySelector('input'); if(parseInt(q.value)<parseInt(q.max)) q.value=parseInt(q.value)+1;">+</button>
                </div>
                <button type="submit" class="btn-add-cart">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
                    Add
                </button>
            </form>
            <div class="qty-error"></div>
            <% } else { %>
            <div style="margin-top: 14px;">
                <button type="button" disabled style="width: 100%; opacity: 0.5; cursor: not-allowed; background: #94A3B8; border: none;">Sold Out</button>
            </div>
            <% } %>
        </div>
    </div>
    <% idx++; } %>
</div>
<% } %>

<script>
function checkQty(f) {
    var input = f.elements['quantity'];
    var stepper = f.querySelector('.quantity-stepper');
    var max = parseInt(input.max, 10);
    var v = input.value.trim();
    var box = f.parentElement.querySelector('.qty-error');
    var msg = '';

    if (!/^\d+$/.test(v)) {
        msg = 'Enter a whole number of 1 or more.';
    } else {
        var n = parseInt(v, 10);
        if (n < 1) {
            msg = 'Quantity must be at least 1.';
        } else if (n > max) {
            msg = 'Only ' + max + ' in stock.';
        }
    }

    box.innerText = msg;
    stepper.classList.toggle('invalid', msg !== '');
    return msg === '';
}
</script>
</body>
</html>