package com.nexora.servlet;

import com.nexora.dao.InventoryDAO;
import com.nexora.model.User;
import com.nexora.pattern.observer.StockMonitor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    private static final int QTY_LIMIT = 10000;
    private static final List<String> REASONS =
            Arrays.asList("Restock", "Damaged", "Correction", "Returned");

    private User getAdmin(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Administrator".equals(((User) u).getRole())) {
            return (User) u;
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (getAdmin(req) == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        boolean lowOnly = "low".equals(req.getParameter("filter"));
        try {
            InventoryDAO dao = new InventoryDAO();
            req.setAttribute("items", dao.getInventory(lowOnly));
            req.setAttribute("logs", dao.getRecentLogs(15));
            req.setAttribute("lowOnly", lowOnly);
            req.getRequestDispatcher("/WEB-INF/views/inventory.jsp").forward(req, resp);
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
        req.setCharacterEncoding("UTF-8");


        int productId;
        int changeQty;
        try {
            productId = Integer.parseInt(req.getParameter("productId").trim());
            changeQty = Integer.parseInt(req.getParameter("changeQty").trim());
        } catch (NumberFormatException | NullPointerException e) {
            resp.sendRedirect("inventory?error=2");
            return;
        }
        if (productId <= 0) {
            resp.sendRedirect("inventory?error=4");
            return;
        }


        if (changeQty == 0 || changeQty > QTY_LIMIT || changeQty < -QTY_LIMIT) {
            resp.sendRedirect("inventory?error=2");
            return;
        }


        String reason = req.getParameter("reason");
        if (reason == null || !REASONS.contains(reason)) {
            resp.sendRedirect("inventory?error=4");
            return;
        }


        boolean mustBePositive = "Restock".equals(reason) || "Returned".equals(reason);
        boolean mustBeNegative = "Damaged".equals(reason);
        if ((mustBePositive && changeQty < 0) || (mustBeNegative && changeQty > 0)) {
            resp.sendRedirect("inventory?error=3");
            return;
        }

        try {
            boolean ok = new InventoryDAO().adjustStock(productId, changeQty, reason, admin.getUserId());
            if (ok) {

                StockMonitor.checkProduct(productId);
            }
            resp.sendRedirect(ok ? "inventory?updated=1" : "inventory?error=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}