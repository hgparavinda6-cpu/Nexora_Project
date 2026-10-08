<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*" %>
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
<title>Nexora - Manage Categories</title>
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

.field-error {
    color: #b91c1c;
    font-size: 12px;
    display: block;
    margin-top: 4px;
    min-height: 14px;
}

input.invalid {
    border-color: #b91c1c !important;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="admin-header">
    <h1 style="margin: 0;">Product Categories</h1>
    <div class="admin-tabs">
        <a href="products" class="admin-tab">Products</a>
        <a href="categories" class="admin-tab active">Categories</a>
        <a href="inventory" class="admin-tab">Stock Control</a>
    </div>
</div>

<% String error = request.getParameter("error");
   if (request.getParameter("added") != null) { %>
    <p style="color:green">Category added.</p>
<% } else if (request.getParameter("renamed") != null) { %>
    <p style="color:green">Category renamed.</p>
<% } else if (request.getParameter("deleted") != null) { %>
    <p style="color:green">Category deleted.</p>
<% } else if ("duplicate".equals(error)) { %>
    <p style="color:red">A category with that name already exists.</p>
<% } else if ("inuse".equals(error)) { %>
    <p style="color:red">Cannot delete this category because active products are assigned to it.</p>
<% } else if ("name".equals(error)) { %>
    <p style="color:red">Category name must be 2 to 50 characters, start with a letter or number, and use only letters, numbers, spaces and &amp; ' . , / -</p>
<% } else if ("invalid".equals(error)) { %>
    <p style="color:red">Invalid request. Please try again.</p>
<% } %>

<div class="nx-card" style="margin-bottom: 32px; max-width: 500px;">
    <h3 style="margin-top: 0;">Add New Category</h3>
    <form action="categories" method="post" novalidate onsubmit="return checkAdd(this);">
        <input type="hidden" name="action" value="add">
        <div style="display: flex; gap: 10px;">
            <input type="text" name="name" maxlength="50" placeholder="Category name (e.g. Footwear)" style="flex: 1;">
            <button type="submit">Add Category</button>
        </div>
        <span class="field-error"></span>
    </form>
</div>

<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <div style="padding: 18px 24px; border-bottom: 1px solid var(--nx-border);">
        <h3 style="margin: 0; font-size: 18px;">Existing Categories</h3>
    </div>

    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 80px;">ID</th>
                <th>Category Title</th>
                <th style="width: 150px;">Associated Products</th>
                <th style="text-align: right; width: 180px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <% List<String[]> cats = (List<String[]>) request.getAttribute("categories");
               if (cats != null) for (String[] c : cats) { %>
            <tr>
                <td style="font-weight: 700; color: var(--nx-text-muted);"><%= hx(c[0]) %></td>
                <td>
                    <input type="text" name="name" form="cf<%= hx(c[0]) %>" maxlength="50"
                           style="width: 100%; max-width: 300px; padding: 7px 10px;"
                           value="<%= hx(c[1]) %>">
                    <span class="field-error"></span>
                </td>
                <td><span class="nx-badge badge-pending"><%= hx(c[2]) %> Products</span></td>
                <td style="text-align: right; white-space: nowrap;">
                    <form id="cf<%= hx(c[0]) %>" action="categories" method="post" novalidate
                          style="display:inline" onsubmit="return checkRow(event, this);">
                        <input type="hidden" name="id" value="<%= hx(c[0]) %>">
                    </form>
                    <button type="submit" form="cf<%= hx(c[0]) %>" name="action" value="rename"
                            class="btn-secondary" style="padding: 6px 12px; font-size: 12.5px;">Rename</button>
                    <button type="submit" form="cf<%= hx(c[0]) %>" name="action" value="delete"
                            class="btn-danger" style="padding: 6px 10px; font-size: 12.5px;"
                            onclick="return confirm('Delete this category?')">Delete</button>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<script>
function vCat(v) {
    v = v.trim();
    if (v.length < 2 || v.length > 50) return 'Name must be 2 to 50 characters.';
    if (!/^[\p{L}0-9][\p{L}0-9 &'.,\/-]*$/u.test(v)) return "Start with a letter/number; use only letters, numbers, spaces and & ' . , / -";
    return '';
}

function checkAdd(f) {
    var input = f.elements['name'];
    var msg = vCat(input.value);
    f.querySelector('.field-error').innerText = msg;
    input.classList.toggle('invalid', msg !== '');
    return msg === '';
}

function checkRow(e, f) {
    if (e.submitter && e.submitter.value === 'delete') return true;
    var row = f.closest('tr');
    var input = row.querySelector('input[name="name"]');
    var msg = vCat(input.value);
    row.querySelector('.field-error').innerText = msg;
    input.classList.toggle('invalid', msg !== '');
    return msg === '';
}
</script>
</body>
</html>