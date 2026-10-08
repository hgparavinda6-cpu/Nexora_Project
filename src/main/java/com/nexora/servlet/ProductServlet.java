package com.nexora.servlet;

import com.nexora.dao.ProductDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    private static final int NAME_MIN = 2;
    private static final int NAME_MAX = 100;
    private static final int DESC_MAX = 255;
    private static final BigDecimal PRICE_MAX = new BigDecimal("1000000");
    private static final int STOCK_MAX = 100000;

    private boolean isAdmin(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        return u instanceof User && "Administrator".equals(((User) u).getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            ProductDAO dao = new ProductDAO();
            req.setAttribute("products", dao.getAllProducts());
            req.setAttribute("categories", dao.getCategories());
            req.getRequestDispatcher("/WEB-INF/views/products.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        ProductDAO dao = new ProductDAO();
        try {
            // ---------- ADD ----------
            if ("add".equals(action)) {
                String name = trim(req.getParameter("name"));
                String desc = trim(req.getParameter("description"));

                int err = checkName(name);
                if (err == 0 && desc.length() > DESC_MAX) err = 4;

                BigDecimal price = parsePrice(req.getParameter("price"));
                if (err == 0 && price == null) err = 2;

                Integer stock = parseStock(req.getParameter("stockQty"));
                if (err == 0 && stock == null) err = 3;

                Integer categoryId = parsePositiveInt(req.getParameter("categoryId"));
                if (err == 0 && categoryId == null) err = 7;

                if (err != 0) {
                    resp.sendRedirect("products?error=" + err);
                    return;
                }
                String img = trim(req.getParameter("imageUrl"));
                if (!img.isEmpty() && (img.length() > 255
                        || !img.matches("^(https?://\\S+|[A-Za-z0-9_./-]+)$"))) {
                    resp.sendRedirect("products?error=8");
                    return;
                }
                dao.addProduct(name, desc, price, stock, categoryId, img);
                resp.sendRedirect("products?added=1");
                return;
            }

            // ---------- UPDATE ----------
            if ("update".equals(action)) {
                Integer productId = parsePositiveInt(req.getParameter("productId"));
                String name = trim(req.getParameter("name"));

                int err = 0;
                if (productId == null) err = 7;
                if (err == 0) err = checkName(name);

                BigDecimal price = parsePrice(req.getParameter("price"));
                if (err == 0 && price == null) err = 2;

                Integer stock = parseStock(req.getParameter("stockQty"));
                if (err == 0 && stock == null) err = 3;

                if (err != 0) {
                    resp.sendRedirect("products?error=" + err);
                    return;
                }
                dao.updateProduct(productId, name, price, stock);
                resp.sendRedirect("products?updated=1");
                return;
            }

            // ---------- DELETE ----------
            if ("delete".equals(action)) {
                Integer productId = parsePositiveInt(req.getParameter("productId"));
                if (productId == null) {
                    resp.sendRedirect("products?error=7");
                    return;
                }
                if (dao.isProductInOrders(productId)) {
                    resp.sendRedirect("products?error=5");   // orders වල භාවිත වෙනවා
                    return;
                }
                dao.deleteProduct(productId);
                resp.sendRedirect("products?deleted=1");
                return;
            }

            resp.sendRedirect("products?error=7");   // නොදන්නා action

        } catch (SQLException e) {
            int code = e.getErrorCode();
            if (code == 2627 || code == 2601) {
                resp.sendRedirect("products?error=6");   // duplicate නම
            } else if (code == 547) {
                resp.sendRedirect("products?error=5");   // FK constraint
            } else {
                throw new ServletException(e);
            }
        }
    }

    // ---------- helpers ----------

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }


    private int checkName(String name) {
        return (name.length() >= NAME_MIN && name.length() <= NAME_MAX) ? 0 : 1;
    }


    private BigDecimal parsePrice(String s) {
        try {
            if (s == null) return null;
            BigDecimal p = new BigDecimal(s.trim());
            if (p.signum() <= 0) return null;
            if (p.compareTo(PRICE_MAX) > 0) return null;
            if (p.stripTrailingZeros().scale() > 2) return null;
            return p;
        } catch (NumberFormatException e) {
            return null;
        }
    }


    private Integer parseStock(String s) {
        try {
            if (s == null) return null;
            int v = Integer.parseInt(s.trim());
            return (v >= 0 && v <= STOCK_MAX) ? v : null;
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