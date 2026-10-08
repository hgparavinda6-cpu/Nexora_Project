package com.nexora.servlet;

import com.nexora.dao.PromotionDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet("/promotions")
public class PromotionServlet extends HttpServlet {

    private static final int TITLE_MIN = 3;
    private static final int TITLE_MAX = 100;
    private static final BigDecimal PERCENT_MAX = new BigDecimal("100");
    private static final BigDecimal FIXED_MAX = new BigDecimal("1000000");
    private static final BigDecimal MIN_ORDER_MAX = new BigDecimal("10000000");

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
            req.setAttribute("promotions", new PromotionDAO().getAll());
            req.getRequestDispatcher("/WEB-INF/views/promotions.jsp").forward(req, resp);
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

        try {
            PromotionDAO dao = new PromotionDAO();

            // ---------- DELETE ----------
            if ("delete".equals(action)) {
                Integer id = parsePositiveInt(req.getParameter("promoId"));
                if (id == null) {
                    resp.sendRedirect("promotions?msg=invalid");
                    return;
                }
                dao.delete(id);
                resp.sendRedirect("promotions?msg=deleted");
                return;
            }

            if (!action.equals("add") && !action.equals("update")) {
                resp.sendRedirect("promotions");
                return;
            }

            // ---------- add සහ update දෙකටම පොදු validation ----------
            String title = req.getParameter("title") == null ? "" : req.getParameter("title").trim();
            BigDecimal value, minOrder;
            LocalDate start, end;
            try {
                value = new BigDecimal(req.getParameter("value").trim());
                minOrder = new BigDecimal(req.getParameter("minOrder").trim());
                start = LocalDate.parse(req.getParameter("startDate"));
                end = LocalDate.parse(req.getParameter("endDate"));
            } catch (Exception e) {
                resp.sendRedirect("promotions?msg=invalid");
                return;
            }

            // Discount type: add වලදී form එකෙන්, update වලදී DB එකෙන් (hidden field එක විශ්වාස කරන්නේ නැහැ)
            String type;
            Integer promoId = null;
            String code = null;
            if ("add".equals(action)) {
                type = req.getParameter("type");
                if (!"Percent".equals(type) && !"Fixed".equals(type)) {
                    resp.sendRedirect("promotions?msg=invalid");
                    return;
                }
                code = req.getParameter("code") == null ? "" : req.getParameter("code").trim().toUpperCase();
                if (!code.matches("[A-Z0-9]{3,20}")) {
                    resp.sendRedirect("promotions?msg=badcode");
                    return;
                }
            } else {
                promoId = parsePositiveInt(req.getParameter("promoId"));
                type = promoId == null ? null : dao.getType(promoId);
                if (type == null) {
                    resp.sendRedirect("promotions?msg=invalid");
                    return;
                }
            }

            String err = null;
            if (title.length() < TITLE_MIN || title.length() > TITLE_MAX) {
                err = "badtitle";
            } else if (value.signum() <= 0 || value.stripTrailingZeros().scale() > 2) {
                err = "badvalue";
            } else if ("Percent".equals(type) && value.compareTo(PERCENT_MAX) > 0) {
                err = "badpercent";
            } else if ("Fixed".equals(type) && value.compareTo(FIXED_MAX) > 0) {
                err = "badvalue";
            } else if (minOrder.signum() < 0 || minOrder.compareTo(MIN_ORDER_MAX) > 0
                    || minOrder.stripTrailingZeros().scale() > 2) {
                err = "badmin";
            } else if (end.isBefore(start)) {
                err = "baddates";
            } else if ("add".equals(action) && end.isBefore(LocalDate.now())) {
                err = "pastend";      // අලුත් coupon එකක end date එක අතීතයේ විය නොහැක
            }
            if (err != null) {
                resp.sendRedirect("promotions?msg=" + err);
                return;
            }

            if ("add".equals(action)) {
                int result = dao.add(code, title, type, value, minOrder, start.toString(), end.toString());
                resp.sendRedirect("promotions?msg=" + (result == PromotionDAO.DUPLICATE ? "duplicate" : "added"));
            } else {
                boolean active = "1".equals(req.getParameter("active"));
                boolean ok = dao.update(promoId, title, value, minOrder,
                        start.toString(), end.toString(), active);
                resp.sendRedirect("promotions?msg=" + (ok ? "updated" : "invalid"));
            }
        } catch (SQLException e) {
            // 2627 / 2601 = code එක දැනටමත් තියෙනවා (UNIQUE)
            if (e.getErrorCode() == 2627 || e.getErrorCode() == 2601) {
                resp.sendRedirect("promotions?msg=duplicate");
            } else {
                throw new ServletException(e);
            }
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