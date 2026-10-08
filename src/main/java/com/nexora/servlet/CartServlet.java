package com.nexora.servlet;

import com.nexora.dao.CartDAO;
import com.nexora.model.CartItem;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private static final int MIN_QTY = 1;
    private static final int SANITY_MAX = 100000;   // අසාධාරණ ලොකු අගයන් වළක්වන්න විතරයි. සැබෑ සීමාව stock එක (DAO එකේ check කරනවා)

    // Customer කෙනෙක් විතරයි Cart පාවිච්චි කරන්නේ
    private User getCustomer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Customer".equals(((User) u).getRole())) {
            return (User) u;
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getCustomer(req);
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            List<CartItem> items = new CartDAO().getCart(user.getUserId());
            BigDecimal total = BigDecimal.ZERO;
            for (CartItem i : items) total = total.add(i.getSubtotal());
            req.setAttribute("items", items);
            req.setAttribute("total", total);
            req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getCustomer(req);
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String action = req.getParameter("action");
        if (action == null) action = "";

        // productId වැරදි නම් 500 error එකක් වෙනුවට cart එකට යවනවා
        Integer productId = parsePositiveInt(req.getParameter("productId"));
        if (productId == null || !(action.equals("add") || action.equals("update") || action.equals("remove"))) {
            resp.sendRedirect("cart?error=invalid");
            return;
        }

        CartDAO dao = new CartDAO();
        try {
            if ("add".equals(action)) {
                Integer qty = parseQty(req.getParameter("quantity"));
                if (qty == null) {
                    resp.sendRedirect("shop?error=qty");
                    return;
                }
                boolean ok = dao.addToCart(user.getUserId(), productId, qty);
                resp.sendRedirect(ok ? "cart" : "shop?error=stock");
                return;
            }

            if ("update".equals(action)) {
                Integer qty = parseQty(req.getParameter("quantity"));
                if (qty == null) {
                    resp.sendRedirect("cart?error=qty");
                    return;
                }
                boolean ok = dao.updateQuantity(user.getUserId(), productId, qty);
                resp.sendRedirect(ok ? "cart" : "cart?error=stock");
                return;
            }

            // remove
            dao.removeItem(user.getUserId(), productId);
            resp.sendRedirect("cart");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ---------- helpers ----------

    /** 1 හෝ ඊට වැඩි පූර්ණ සංඛ්‍යාවක් නම් ඒක, නැත්නම් null */
    private Integer parseQty(String s) {
        try {
            if (s == null) return null;
            int v = Integer.parseInt(s.trim());
            return (v >= MIN_QTY && v <= SANITY_MAX) ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer parsePositiveInt(String s) {
        try {
            if (s == null) return null;
            int v = Integer.parseInt(s.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}