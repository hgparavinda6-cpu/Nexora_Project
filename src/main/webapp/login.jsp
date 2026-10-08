<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nexora - Log in</title>
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
    max-width: 440px;
    padding: 40px 36px;
    position: relative;
    overflow: hidden;
}

.auth-header {
    text-align: center;
    margin-bottom: 30px;
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
    margin-bottom: 20px;
}

.auth-field label {
    display: block;
    margin-bottom: 7px;
    font-size: 13.5px;
    font-weight: 600;
}

.auth-field input {
    width: 100%;
    padding: 12px 14px;
    font-size: 15px;
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
            <h1>Welcome Back</h1>
            <p class="lead">Sign in to manage your orders, deliveries, and saved items.</p>
        </div>
        <% if (request.getParameter("registered") != null) { %>
                    <p style="color:green">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        Account created successfully! Please log in below.
                    </p>
                <% } %>

        <% String err = request.getParameter("error");
           if ("2".equals(err)) { %>
            <p style="color:red">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                Service temporary issue. Please try again in a moment.
            </p>
        <% } else if (err != null) { %>
            <p style="color:red">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                Email or password is incorrect. Check both and try again.
            </p>
        <% } %>

        <form action="login" method="post">
            <div class="auth-field">
                <label for="email">Email Address</label>
                <input id="email" type="email" name="email" autocomplete="email" placeholder="name@domain.com" required autofocus>
            </div>

            <div class="auth-field">
                <label for="password">Password</label>
                <div class="password-input-wrap">
                    <input id="password" type="password" name="password" autocomplete="current-password" placeholder="••••••••" required>
                    <button type="button" class="password-toggle-btn"
                            onclick="var p=document.getElementById('password'); p.type = p.type==='password'?'text':'password'; this.innerText = p.type==='password'?'Show':'Hide';">
                        Show
                    </button>
                </div>
            </div>

            <button type="submit" class="auth-submit-btn">Log in to Nexora</button>
        </form>

        <div class="auth-footer">
            New to Nexora? <a href="register.jsp">Create an account</a>
        </div>
    </div>
</div>

</body>
</html>