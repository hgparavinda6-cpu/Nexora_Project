package com.nexora.servlet;

import com.nexora.dao.AdminOrderDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@WebServlet("/manageorders")
public class ManageOrdersServlet extends HttpServlet {

    private static final List<String> ALL_STATUSES =
            Arrays.asList("Pending", "Processing", "Shipped", "Delivered", "Cancelled");

    private User getAdmin(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Administrator".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (getAdmin(req) == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String filter = req.getParameter("status");
        if (filter != null && !ALL_STATUSES.contains(filter)) filter = null;
        try {
            req.setAttribute("orders", new AdminOrderDAO().getAllOrders(filter));
            req.setAttribute("filter", filter);
            req.setAttribute("statuses", ALL_STATUSES);
            req.getRequestDispatcher("/WEB-INF/views/manageorders.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User admin = getAdmin(req);
        if (admin == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // orderId අංකයක් විය යුතුයි
        int orderId;
        try {
            orderId = Integer.parseInt(req.getParameter("orderId").trim());
        } catch (NumberFormatException | NullPointerException e) {
            resp.sendRedirect("manageorders?error=2");
            return;
        }
        if (orderId <= 0) {
            resp.sendRedirect("manageorders?error=2");
            return;
        }

        // newStatus අවසර ඇති අගයක් විය යුතුයි
        String newStatus = req.getParameter("newStatus");
        if (newStatus == null || !ALL_STATUSES.contains(newStatus)) {
            resp.sendRedirect("manageorders?error=2");
            return;
        }

        try {
            boolean ok = new AdminOrderDAO().updateStatus(orderId, newStatus, admin.getUserId());
            resp.sendRedirect("manageorders" + (ok ? "?updated=" + orderId : "?error=1"));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}