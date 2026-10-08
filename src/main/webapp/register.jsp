<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
<title>Nexora - Create Account</title>
<style>
.auth-wrapper {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: calc(100vh - 180px);
    padding: 40px 20px;
}

.auth-card {
    background: #FFFFFF;
    border: 1px solid var(--nx-border);
    border-radius: var(--nx-radius-xl);
    box-shadow: var(--nx-shadow-lg);
    width: 100%;
    max-width: 480px;
    padding: 40px 36px;
    position: relative;
    overflow: hidden;
}

.auth-header {
    text-align: center;
    margin-bottom: 28px;
}

.auth-header h1 {
    font-size: 28px;
    margin-top: 10px;
    margin-bottom: 8px;
}

.auth-header .lead {
    color: var(--nx-text-muted);
    font-size: 14.5px;
    margin-bottom: 0;
}

.auth-field {
    margin-bottom: 18px;
}

.auth-field label {
    display: block;
    margin-bottom: 6px;
    font-size: 13.5px;
    font-weight: 600;
}

.auth-field label span {
    color: var(--nx-text-muted);
    font-weight: 400;
    font-size: 12.5px;
}

.auth-field input, .auth-field textarea {
    width: 100%;
    padding: 12px 14px;
    font-size: 14.5px;
}

.auth-field input.invalid, .auth-field textarea.invalid {
    border-color: #DC2626 !important;
}

.field-error {
    display: block;
    color: #DC2626;
    font-size: 12.5px;
    margin-top: 5px;
}

.field-hint {
    display: block;
    color: var(--nx-text-muted);
    font-size: 12px;
    margin-top: 5px;
}

.form-error {
    background: #FEF2F2;
    border: 1px solid #FCA5A5;
    color: #B91C1C;
    border-radius: 10px;
    padding: 12px 14px;
    margin-bottom: 18px;
    font-size: 14px;
}

.password-input-wrap {
    position: relative;
}

.password-toggle-btn {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
    color: var(--nx-text-muted) !important;
    padding: 4px !important;
    font-size: 13px !important;
    cursor: pointer;
}

.auth-submit-btn {
    width: 100%;
    padding: 13px;
    font-size: 15.5px;
    margin-top: 10px;
    background: linear-gradient(135deg, #0E3B43, #165662);
}

.auth-submit-btn:hover {
    background: linear-gradient(135deg, #14525D, #1B6876);
}

.auth-footer {
    text-align: center;
    margin-top: 24px;
    padding-top: 20px;
    border-top: 1px solid var(--nx-border);
    font-size: 14px;
    color: var(--nx-text-muted);
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/navbar.jspf" %>

<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-header">
            <span class="nx-brand-icon" style="margin: 0 auto 12px; width: 44px; height: 44px;">
                <svg width="24" height="24" viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
            </span>
            <h1>Create Account</h1>
            <p class="lead">Join Nexora for direct access to premium products, fast shipping, and live delivery updates.</p>
        </div>

        <% String formError = (String) request.getAttribute("formError");
           if (formError != null) { %>
            <div class="form-error"><%= esc(formError) %></div>
        <% } %>

        <form action="register" method="post" id="registerForm" novalidate>
            <div class="auth-field">
                <label for="fullName">Full Name</label>
                <input id="fullName" type="text" name="fullName" autocomplete="name" placeholder="John Doe"
                       maxlength="50" value="<%= esc((String) request.getAttribute("fullName")) %>" autofocus>
                <small class="field-error" id="err-fullName"></small>
            </div>

            <div class="auth-field">
                <label for="email">Email Address</label>
                <input id="email" type="email" name="email" autocomplete="email" placeholder="name@domain.com"
                       maxlength="100" value="<%= esc((String) request.getAttribute("email")) %>">
                <small class="field-error" id="err-email"></small>
            </div>

            <div class="auth-field">
                <label for="password">Password</label>
                <div class="password-input-wrap">
                    <input id="password" type="password" name="password" autocomplete="new-password"
                           placeholder="At least 6 characters" maxlength="50">
                    <button type="button" class="password-toggle-btn"
                            onclick="var p=document.getElementById('password'); p.type = p.type==='password'?'text':'password'; this.innerText = p.type==='password'?'Show':'Hide';">
                        Show
                    </button>
                </div>
                <small class="field-hint">6-50 characters, with at least one letter and one number.</small>
                <small class="field-error" id="err-password"></small>
            </div>

            <div class="auth-field">
                <label for="phone">Phone Number <span>(Optional &mdash; used by delivery courier)</span></label>
                <input id="phone" type="tel" name="phone" autocomplete="tel" placeholder="0771234567"
                       maxlength="15" value="<%= esc((String) request.getAttribute("phone")) %>">
                <small class="field-error" id="err-phone"></small>
            </div>

            <div class="auth-field">
                <label for="address">Delivery Address <span>(Optional)</span></label>
                <textarea id="address" name="address" rows="2" autocomplete="street-address" maxlength="200"
                          placeholder="Street address, apartment or city"><%= esc((String) request.getAttribute("address")) %></textarea>
                <small class="field-error" id="err-address"></small>
            </div>

            <button type="submit" class="auth-submit-btn">Create Free Account</button>
        </form>

        <div class="auth-footer">
            Already have an account? <a href="login.jsp">Log in here</a>
        </div>
    </div>
</div>

<script>
(function () {
    // හැම field එකකටම rule එකක්. හරි නම් "" ; වැරදි නම් message එක return කරනවා
    var rules = {
        fullName: function (v) {
            return /^\p{L}[\p{L} .'-]{2,49}$/u.test(v.trim())
                ? "" : "Name must be 3-50 letters (no numbers or symbols).";
        },
        email: function (v) {
            v = v.trim();
            return (v.length <= 100 && /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v))
                ? "" : "Enter a valid email address.";
        },
        password: function (v) {
            return (v.length >= 6 && v.length <= 50 && /[A-Za-z]/.test(v) && /\d/.test(v))
                ? "" : "Password must be 6-50 characters with at least one letter and one number.";
        },
        phone: function (v) {
            v = v.replace(/\s+/g, "");
            return (v === "" || /^(?:0[1-9]\d{8}|\+94[1-9]\d{8})$/.test(v))
                ? "" : "Use a Sri Lankan number like 0771234567 or +94771234567.";
        },
        address: function (v) {
            return v.length <= 200 ? "" : "Address must be 200 characters or less.";
        }
    };

    function check(name) {
        var input = document.getElementById(name);
        var msg = rules[name](input.value);
        document.getElementById("err-" + name).textContent = msg;
        input.classList.toggle("invalid", msg !== "");
        return msg === "";
    }

    Object.keys(rules).forEach(function (name) {
        var input = document.getElementById(name);
        input.addEventListener("blur", function () { check(name); });
        input.addEventListener("input", function () {
            if (input.classList.contains("invalid")) check(name);   // වැරදි එකක් හදද්දි ලයිව් එකෙන් මැකෙනවා
        });
    });

    document.getElementById("registerForm").addEventListener("submit", function (e) {
        var firstBad = null;
        Object.keys(rules).forEach(function (name) {
            if (!check(name) && firstBad === null) firstBad = name;
        });
        if (firstBad !== null) {
            e.preventDefault();
            document.getElementById(firstBad).focus();
        }
    });
})();
</script>

</body>
</html>