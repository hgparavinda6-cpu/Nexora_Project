<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Product" %>
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
<title>Nexora - Manage Products</title>
<style>
.admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 32px;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 14px;
}

.admin-tabs {
    display: flex;
    gap: 8px;
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    padding: 6px;
    border-radius: var(--nx-radius);
    box-shadow: var(--nx-shadow-sm);
}

.admin-tab {
    padding: 8px 16px;
    border-radius: var(--nx-radius-sm);
    font-size: 13.5px;
    font-weight: 600;
    text-decoration: none;
    color: var(--nx-text-muted);
}

.admin-tab.active {
    background: var(--nx-brand);
    color: #FFFFFF;
}

.add-product-form {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 16px;
    align-items: start;
}

.form-field {
    display: flex;
    flex-direction: column;
}

.form-field label {
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 600;
}

.field-error {
    color: #b91c1c;
    font-size: 12px;
    margin-top: 4px;
    min-height: 14px;
}

input.invalid {
    border-color: #b91c1c !important;
}

.row-error {
    display: block;
    color: #b91c1c;
    font-size: 11.5px;
    margin-top: 3px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="admin-header">
    <h1 style="margin: 0;">Product Inventory &amp; Catalog</h1>
    <div class="admin-tabs">
        <a href="products" class="admin-tab active">Products</a>
        <a href="categories" class="admin-tab">Categories</a>
        <a href="inventory" class="admin-tab">Stock Control</a>
    </div>
</div>

<%
    String errCode = request.getParameter("error");
    if (request.getParameter("added") != null) { %>
    <p style="color:green">Product added to catalog.</p>
<% } else if (request.getParameter("updated") != null) { %>
    <p style="color:green">Product updated successfully.</p>
<% } else if (request.getParameter("deleted") != null) { %>
    <p style="color:green">Product deleted.</p>
<% } else if (errCode != null) {
       String msg;
       if ("1".equals(errCode))      msg = "Product name must be 2 to 100 characters.";
       else if ("2".equals(errCode)) msg = "Price must be greater than 0, at most Rs. 1,000,000, with up to 2 decimal places.";
       else if ("3".equals(errCode)) msg = "Stock quantity must be a whole number between 0 and 100000.";
       else if ("4".equals(errCode)) msg = "Description is too long. Maximum 255 characters.";
       else if ("5".equals(errCode)) msg = "This product cannot be deleted because it is used in existing orders.";
       else if ("6".equals(errCode)) msg = "A product with this name already exists.";
       else if ("8".equals(errCode)) msg = "Invalid Image URL. Use a path like images/products/mouse.svg or a full http(s) link (max 255 characters, no spaces).";
       else                          msg = "Invalid request. Please check the values and try again.";
%>
    <p style="color:red"><%= msg %></p>
<% } %>

<div class="nx-card" style="margin-bottom: 32px;">
    <h3 style="margin-top: 0; padding-bottom: 12px; border-bottom: 1px solid var(--nx-border);">Add New Product</h3>
    <form action="products" method="post" class="add-product-form" novalidate onsubmit="return checkAdd(this);">
        <input type="hidden" name="action" value="add">

        <div class="form-field">
            <label for="pName">Product Name</label>
            <input id="pName" type="text" name="name" maxlength="100" placeholder="e.g. Wireless Headset">
            <span class="field-error" data-for="name"></span>
        </div>

        <div class="form-field">
            <label for="pDesc">Description</label>
            <input id="pDesc" type="text" name="description" maxlength="255" placeholder="Short features summary">
            <span class="field-error" data-for="description"></span>
        </div>

        <div class="form-field">
            <label for="pPrice">Price (Rs.)</label>
            <input id="pPrice" type="number" step="0.01" min="0" name="price" placeholder="2500.00">
            <span class="field-error" data-for="price"></span>
        </div>

        <div class="form-field">
            <label for="pStock">Initial Stock Qty</label>
            <input id="pStock" type="number" min="0" name="stockQty" placeholder="50">
            <span class="field-error" data-for="stockQty"></span>
        </div>

        <div class="form-field">
            <label for="pCat">Category</label>
            <select id="pCat" name="categoryId">
            <% Map<Integer, String> cats = (Map<Integer, String>) request.getAttribute("categories");
               if (cats != null) for (Map.Entry<Integer, String> c : cats.entrySet()) { %>
                <option value="<%= c.getKey() %>"><%= hx(c.getValue()) %></option>
            <% } %>
            </select>
            <span class="field-error"></span>
        </div>

        <div class="form-field">
            <label for="pImg">Image URL (optional)</label>
            <input id="pImg" type="text" name="imageUrl" maxlength="255" placeholder="images/products/mouse.svg">
            <span class="field-error" data-for="imageUrl"></span>
        </div>

        <div>
            <button type="submit" style="width: 100%; height: 44px;">Add to Catalog</button>
        </div>
    </form>
</div>

<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <div style="padding: 18px 24px; border-bottom: 1px solid var(--nx-border); display: flex; justify-content: space-between; align-items: center;">
        <h3 style="margin: 0; font-size: 18px;">All Catalog Items</h3>
        <span style="font-size: 13.5px; color: var(--nx-text-muted);">
            <% List<Product> products = (List<Product>) request.getAttribute("products"); %>
            Total: <b><%= products != null ? products.size() : 0 %></b> items
        </span>
    </div>

    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 60px;">ID</th>
                <th>Product Name</th>
                <th>Category</th>
                <th style="width: 130px;">Price (Rs.)</th>
                <th style="width: 100px;">Stock</th>
                <th style="text-align: right; width: 180px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <% if (products != null) for (Product p : products) { %>
            <tr>
                <td style="font-weight: 700; color: var(--nx-text-muted);"><%= p.getProductId() %></td>
                <td>
                    <input type="text" name="name" form="pf<%= p.getProductId() %>" maxlength="100"
                           style="width: 100%; padding: 7px 10px;"
                           value="<%= hx(p.getProductName()) %>">
                </td>
                <td><span class="nx-badge badge-processing"><%= hx(p.getCategoryName()) %></span></td>
                <td>
                    <input type="number" step="0.01" min="0" name="price" form="pf<%= p.getProductId() %>"
                           value="<%= p.getPrice() %>" style="width: 100%; padding: 7px 10px;">
                </td>
                <td>
                    <input type="number" min="0" name="stockQty" form="pf<%= p.getProductId() %>"
                           value="<%= p.getStockQty() %>" style="width: 100%; padding: 7px 10px;">
                    <small class="row-error"></small>
                </td>
                <td style="text-align: right; white-space: nowrap;">
                    <form id="pf<%= p.getProductId() %>" action="products" method="post" novalidate
                          style="display:inline" onsubmit="return checkRow(event, this);">
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    </form>
                    <button type="submit" form="pf<%= p.getProductId() %>" name="action" value="update"
                            class="btn-secondary" style="padding: 6px 12px; font-size: 12.5px;">Update</button>
                    <button type="submit" form="pf<%= p.getProductId() %>" name="action" value="delete"
                            class="btn-danger" style="padding: 6px 10px; font-size: 12.5px;"
                            onclick="return confirm('Delete product #<%= p.getProductId() %>?')">Delete</button>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<script>

function vName(v) {
    v = v.trim();
    return (v.length >= 2 && v.length <= 100) ? '' : 'Name must be 2 to 100 characters.';
}
function vDesc(v) {
    return v.trim().length <= 255 ? '' : 'Maximum 255 characters.';
}
function vPrice(v) {
    v = v.trim();
    if (v === '' || isNaN(v)) return 'Enter a valid price.';
    var n = Number(v);
    if (n <= 0) return 'Price must be greater than 0.';
    if (n > 1000000) return 'Price cannot exceed Rs. 1,000,000.';
    if (!/^\d+(\.\d{1,2})?$/.test(v)) return 'Maximum 2 decimal places.';
    return '';
}
function vStock(v) {
    v = v.trim();
    if (!/^\d+$/.test(v)) return 'Enter a whole number (0 or more).';
    if (Number(v) > 100000) return 'Stock cannot exceed 100000.';
    return '';
}
function vImage(v) {
    v = v.trim();
    if (v === '') return '';
    if (v.length > 255) return 'Maximum 255 characters.';
    if (!/^(https?:\/\/\S+|[A-Za-z0-9_.\/-]+)$/.test(v)) return 'Use a path like images/products/x.svg or a full http(s) link.';
    return '';
}

function showErr(form, field, msg) {
    var span = form.querySelector('.field-error[data-for="' + field + '"]');
    var input = form.elements[field];
    if (span) span.innerText = msg;
    if (input) { if (msg) input.classList.add('invalid'); else input.classList.remove('invalid'); }
    return msg === '';
}

// ---------- Add form ----------
function checkAdd(f) {
    var ok = true;
    ok = showErr(f, 'name', vName(f.name.value)) && ok;
    ok = showErr(f, 'description', vDesc(f.description.value)) && ok;
    ok = showErr(f, 'price', vPrice(f.price.value)) && ok;
    ok = showErr(f, 'stockQty', vStock(f.stockQty.value)) && ok;
    ok = showErr(f, 'imageUrl', vImage(f.imageUrl.value)) && ok;
    return ok;
}

// ---------- Table row (Update / Delete) ----------
function checkRow(e, f) {
    // Delete එකට validation ඕන නැහැ
    if (e.submitter && e.submitter.value === 'delete') return true;

    var id = f.elements['productId'].value;
    var row = f.closest('tr');
    var name = row.querySelector('input[name="name"]');
    var price = row.querySelector('input[name="price"]');
    var stock = row.querySelector('input[name="stockQty"]');
    var errBox = row.querySelector('.row-error');

    var msg = vName(name.value) || vPrice(price.value) || vStock(stock.value);
    name.classList.toggle('invalid', vName(name.value) !== '');
    price.classList.toggle('invalid', vPrice(price.value) !== '');
    stock.classList.toggle('invalid', vStock(stock.value) !== '');
    errBox.innerText = msg;
    return msg === '';
}
</script>
</body>
</html>