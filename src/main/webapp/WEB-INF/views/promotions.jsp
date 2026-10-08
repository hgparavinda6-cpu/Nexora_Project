<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, com.nexora.model.Promotion" %>
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
<title>Nexora - Promotions Management</title>
<style>
.promo-create-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    align-items: end;
}

.promo-form-field {
    display: flex;
    flex-direction: column;
}

.promo-form-field label {
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 600;
}

.form-err {
    color: #b91c1c;
    font-size: 12.5px;
    min-height: 0;
}

.promo-create-grid .form-err {
    grid-column: 1 / -1;
}

.promo-row-err {
    display: block;
    width: 100%;
}

input.invalid {
    border-color: #b91c1c !important;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<h1 style="margin-top: 32px; margin-bottom: 8px;">Promotions &amp; Coupons</h1>
<p style="color: var(--nx-text-muted); font-size: 14.5px;">Create discount campaigns, percentage vouchers, and minimum spend requirements.</p>

<% String msg = request.getParameter("msg");
   if ("added".equals(msg)) { %><p style="color:green">Promotion campaign created successfully.</p>
<% } else if ("updated".equals(msg)) { %><p style="color:green">Promotion parameters updated.</p>
<% } else if ("deleted".equals(msg)) { %><p style="color:green">Promotion deleted.</p>
<% } else if ("duplicate".equals(msg)) { %><p style="color:red">That promotion code already exists.</p>
<% } else if ("badcode".equals(msg)) { %><p style="color:red">Coupon code must be 3 to 20 characters (letters and numbers only).</p>
<% } else if ("badtitle".equals(msg)) { %><p style="color:red">Campaign title must be 3 to 100 characters.</p>
<% } else if ("badvalue".equals(msg)) { %><p style="color:red">Discount value must be greater than 0, with at most 2 decimal places (Fixed amount up to Rs. 1,000,000).</p>
<% } else if ("badpercent".equals(msg)) { %><p style="color:red">A percentage discount cannot exceed 100%.</p>
<% } else if ("badmin".equals(msg)) { %><p style="color:red">Minimum order must be between 0 and Rs. 10,000,000, with at most 2 decimal places.</p>
<% } else if ("baddates".equals(msg)) { %><p style="color:red">End date cannot be before the start date.</p>
<% } else if ("pastend".equals(msg)) { %><p style="color:red">End date cannot be in the past for a new promotion.</p>
<% } else if ("invalid".equals(msg)) { %><p style="color:red">Invalid promotion details. Please check the values and try again.</p>
<% } %>

<div class="nx-card" style="margin-bottom: 36px;">
    <h3 style="margin-top: 0; padding-bottom: 12px; border-bottom: 1px solid var(--nx-border);">Create New Promotion Voucher</h3>
    <form action="promotions" method="post" class="promo-create-grid" novalidate onsubmit="return checkPromo(this, true);">
        <input type="hidden" name="action" value="add">

        <div class="promo-form-field">
            <label for="pCode">Coupon Code</label>
            <input id="pCode" type="text" name="code" maxlength="20" placeholder="e.g. FLASH20" style="text-transform: uppercase;">
        </div>

        <div class="promo-form-field">
            <label for="pTitle">Campaign Title</label>
            <input id="pTitle" type="text" name="title" maxlength="100" placeholder="e.g. 20% Off Weekend Special">
        </div>

        <div class="promo-form-field">
            <label for="pType">Discount Type</label>
            <select id="pType" name="type">
                <option value="Percent">Percent (%)</option>
                <option value="Fixed">Fixed Amount (Rs.)</option>
            </select>
        </div>

        <div class="promo-form-field">
            <label for="pVal">Discount Value</label>
            <input id="pVal" type="number" name="value" step="0.01" min="0.01" placeholder="10.00">
        </div>

        <div class="promo-form-field">
            <label for="pMin">Minimum Order (Rs.)</label>
            <input id="pMin" type="number" name="minOrder" step="0.01" min="0" value="0">
        </div>

        <div class="promo-form-field">
            <label for="pStart">Start Date</label>
            <input id="pStart" type="date" name="startDate">
        </div>

        <div class="promo-form-field">
            <label for="pEnd">End Date</label>
            <input id="pEnd" type="date" name="endDate">
        </div>

        <div>
            <button type="submit" style="width: 100%; height: 44px;">Create Promotion</button>
        </div>

        <div class="form-err"></div>
    </form>
</div>

<div class="nx-card" style="padding: 0; overflow: hidden; margin-bottom: 60px;">
    <div style="padding: 18px 24px; border-bottom: 1px solid var(--nx-border);">
        <h3 style="margin: 0; font-size: 18px;">All Configured Promotions</h3>
    </div>

    <% List<Promotion> list = (List<Promotion>) request.getAttribute("promotions");
       if (list == null || list.isEmpty()) { %>
        <p style="padding: 24px; color: var(--nx-text-muted); margin: 0;">No promotions configured yet.</p>
    <% } else { %>
    <table style="margin: 0; border: none; box-shadow: none;">
        <thead>
            <tr>
                <th style="width: 120px;">Code</th>
                <th style="width: 140px;">Discount</th>
                <th style="width: 100px;">Status</th>
                <th>Promotion Details &amp; Configuration</th>
                <th style="text-align: right; width: 100px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <% for (Promotion p : list) {
                   boolean act = p.isActive();
            %>
            <tr>
                <td><b style="font-family: monospace; font-size: 15px; color: #0E3B43;"><%= hx(p.getCode()) %></b></td>
                <td>
                    <span style="font-weight: 700; color: #059669;"><%= hx(p.getValueText()) %></span><br>
                    <small style="color: var(--nx-text-muted);">(<%= hx(p.getType()) %>)</small>
                </td>
                <td>
                    <span class="nx-badge <%= act ? "badge-delivered" : "badge-cancelled" %>">
                        <%= act ? "Active" : "Disabled" %>
                    </span>
                </td>
                <td>
                    <form action="promotions" method="post" novalidate onsubmit="return checkPromo(this, false);"
                          style="display: flex; flex-wrap: wrap; gap: 8px; align-items: center;">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="promoId" value="<%= p.getPromoId() %>">
                        <input type="hidden" name="type" value="<%= hx(p.getType()) %>">

                        <input type="text" name="title" value="<%= hx(p.getTitle()) %>" maxlength="100" style="padding: 6px 10px; font-size: 13px; width: 180px;">
                        <input type="number" name="value" step="0.01" min="0.01" value="<%= p.getValue() %>" style="padding: 6px 10px; font-size: 13px; width: 80px;">
                        <input type="number" name="minOrder" step="0.01" min="0" value="<%= p.getMinOrder() %>" style="padding: 6px 10px; font-size: 13px; width: 90px;" title="Min Order">
                        <input type="date" name="startDate" value="<%= hx(p.getStartDate()) %>" style="padding: 6px 8px; font-size: 12.5px;">
                        <input type="date" name="endDate" value="<%= hx(p.getEndDate()) %>" style="padding: 6px 8px; font-size: 12.5px;">
                        <select name="active" style="padding: 6px 8px; font-size: 12.5px;">
                            <option value="1" <%= act ? "selected" : "" %>>Enabled</option>
                            <option value="0" <%= !act ? "selected" : "" %>>Disabled</option>
                        </select>
                        <button type="submit" class="btn-secondary" style="padding: 6px 12px; font-size: 12.5px;">Save</button>
                        <span class="form-err promo-row-err"></span>
                    </form>
                </td>
                <td style="text-align: right;">
                    <form action="promotions" method="post" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="promoId" value="<%= p.getPromoId() %>">
                        <button type="submit" class="btn-danger" style="padding: 6px 10px; font-size: 12.5px;"
                                onclick="return confirm('Delete promotion <%= hx(p.getCode()) %>?')">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% } %>
</div>

<script>
function todayStr() {
    var t = new Date();
    return t.getFullYear() + '-' + String(t.getMonth() + 1).padStart(2, '0') + '-' + String(t.getDate()).padStart(2, '0');
}

function decimals(v) {
    var i = v.indexOf('.');
    return i < 0 ? 0 : v.length - i - 1;
}

// isAdd = true: Create form (code + type + අතීත end date check). false: Save (update) form
function checkPromo(f, isAdd) {
    var msg = '';
    var bad = [];
    var type = f.elements['type'].value;

    if (isAdd) {
        var code = f.elements['code'];
        code.value = code.value.trim().toUpperCase();
        if (!/^[A-Z0-9]{3,20}$/.test(code.value)) { msg = 'Coupon code must be 3 to 20 letters/numbers.'; bad.push(code); }
    }

    var title = f.elements['title'];
    if (!msg && (title.value.trim().length < 3 || title.value.trim().length > 100)) {
        msg = 'Campaign title must be 3 to 100 characters.'; bad.push(title);
    }

    var value = f.elements['value'];
    var vv = value.value.trim();
    if (!msg) {
        if (vv === '' || isNaN(vv) || Number(vv) <= 0) { msg = 'Discount value must be greater than 0.'; bad.push(value); }
        else if (decimals(vv) > 2) { msg = 'Discount value can have at most 2 decimal places.'; bad.push(value); }
        else if (type === 'Percent' && Number(vv) > 100) { msg = 'A percentage discount cannot exceed 100%.'; bad.push(value); }
        else if (type === 'Fixed' && Number(vv) > 1000000) { msg = 'Fixed discount cannot exceed Rs. 1,000,000.'; bad.push(value); }
    }

    var min = f.elements['minOrder'];
    var mv = min.value.trim();
    if (!msg) {
        if (mv === '' || isNaN(mv) || Number(mv) < 0) { msg = 'Minimum order must be 0 or more.'; bad.push(min); }
        else if (decimals(mv) > 2) { msg = 'Minimum order can have at most 2 decimal places.'; bad.push(min); }
        else if (Number(mv) > 10000000) { msg = 'Minimum order cannot exceed Rs. 10,000,000.'; bad.push(min); }
    }

    var sd = f.elements['startDate'], ed = f.elements['endDate'];
    if (!msg) {
        if (!sd.value || !ed.value) { msg = 'Please select both start and end dates.'; bad.push(!sd.value ? sd : ed); }
        else if (ed.value < sd.value) { msg = 'End date cannot be before the start date.'; bad.push(ed); }
        else if (isAdd && ed.value < todayStr()) { msg = 'End date cannot be in the past.'; bad.push(ed); }
    }

    // සියලුම fields වල රතු border එක reset කරලා, වැරදි එකට විතරක් දානවා
    var all = f.querySelectorAll('input');
    for (var i = 0; i < all.length; i++) all[i].classList.remove('invalid');
    for (var j = 0; j < bad.length; j++) bad[j].classList.add('invalid');

    var box = f.querySelector('.form-err');
    if (box) box.innerText = msg;
    return msg === '';
}
</script>
</body>
</html>