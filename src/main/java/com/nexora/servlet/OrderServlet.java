package com.nexora.servlet;

import com.nexora.dao.DeliveryDAO;
import com.nexora.dao.OrderDAO;
import com.nexora.model.Order;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    private static final int ADDRESS_MIN = 5;
    private static final int ADDRESS_MAX = 200;
    private static final int QTY_MAX = 1000;
    // Register එකේ වගේම Sri Lankan phone format: 0771234567 හෝ +94771234567
    private static final String PHONE_PATTERN = "^(?:0[1-9]\\d{8}|\\+94[1-9]\\d{8})$";

    private User getCustomer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Customer".equals(((User) u).getRole())) return (User) u;
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
            OrderDAO dao = new OrderDAO();
            String id = req.getParameter("id");
            if (id != null) {
                // id වැරදි නම් 500 error එකක් වෙනුවට orders list එකට යවනවා
                Integer orderId = parsePositiveInt(id);
                if (orderId == null) {
                    resp.sendRedirect("orders?error=invalid");
                    return;
                }
                Order order = dao.getOrder(orderId, user.getUserId());
                if (order == null) {
                    resp.sendRedirect("orders");
                    return;
                }
                req.setAttribute("order", order);
                req.setAttribute("delivery", new DeliveryDAO().getByOrder(orderId, user.getUserId()));
                req.setAttribute("discount", dao.getDiscountInfo(orderId, user.getUserId()));
                if ("Pending".equals(order.getStatus())) {
                    req.setAttribute("products", dao.getAvailableProducts());
                }
            } else {
                req.setAttribute("orders", dao.getOrdersByUser(user.getUserId()));
            }
            req.getRequestDispatcher("/WEB-INF/views/orders.jsp").forward(req, resp);
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
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if (action == null) action = "";

        Integer orderIdObj = parsePositiveInt(req.getParameter("orderId"));
        if (orderIdObj == null) {
            resp.sendRedirect("orders?error=invalid");
            return;
        }
        int orderId = orderIdObj;
        String back = "orders?id=" + orderId;

        try {
            if ("cancel".equals(action)) {
                boolean ok = new OrderDAO().cancelOrder(orderId, user.getUserId());
                resp.sendRedirect(back + "&cancel=" + (ok ? "ok" : "fail"));
                return;
            }

            if ("address".equals(action)) {
                String address = req.getParameter("address") == null ? "" : req.getParameter("address").trim();
                if (address.length() < ADDRESS_MIN || address.length() > ADDRESS_MAX) {
                    resp.sendRedirect(back + "&addr=invalid");
                    return;
                }
                boolean ok = new DeliveryDAO().updateAddress(orderId, user.getUserId(), address);
                resp.sendRedirect(back + "&addr=" + (ok ? "ok" : "fail"));
                return;
            }

            if ("phone".equals(action)) {
                // spaces අයින් කරලා format එක check කරනවා
                String phone = req.getParameter("phone") == null
                        ? "" : req.getParameter("phone").replaceAll("\\s+", "");
                if (!phone.matches(PHONE_PATTERN)) {
                    resp.sendRedirect(back + "&phone=invalid");
                    return;
                }
                boolean ok = new OrderDAO().updatePhone(user.getUserId(), phone);
                resp.sendRedirect(back + "&phone=" + (ok ? "ok" : "fail"));
                return;
            }

            if ("edit".equals(action)) {
                Map<Integer, Integer> wanted = new HashMap<>();
                Enumeration<String> names = req.getParameterNames();
                while (names.hasMoreElements()) {
                    String n = names.nextElement();
                    if (!n.startsWith("qty_")) continue;
                    Integer pid = parsePositiveInt(n.substring(4));
                    Integer q = parseInt(req.getParameter(n));
                    if (pid == null || q == null || q < 0 || q > QTY_MAX) {
                        resp.sendRedirect(back + "&edit=invalid");
                        return;
                    }
                    wanted.put(pid, q);
                }

                int addProduct = 0, addQty = 0;
                String ap = req.getParameter("addProduct");
                if (ap != null && !ap.isEmpty()) {
                    Integer p = parsePositiveInt(ap);
                    Integer q = parseInt(req.getParameter("addQty"));
                    if (p == null || q == null || q < 1 || q > QTY_MAX) {
                        resp.sendRedirect(back + "&edit=invalid");
                        return;
                    }
                    addProduct = p;
                    addQty = q;
                }

                int result = new OrderDAO().editOrder(orderId, user.getUserId(), wanted, addProduct, addQty);
                String code = result == OrderDAO.EDIT_OK ? "ok"
                        : result == OrderDAO.NOT_ENOUGH_STOCK ? "stock"
                        : result == OrderDAO.EMPTY_CART ? "empty"
                        : result == OrderDAO.NOT_EDITABLE ? "locked" : "fail";
                resp.sendRedirect(back + "&edit=" + code);
                return;
            }

            if ("delete".equals(action)) {
                boolean ok = new OrderDAO().deleteOrder(orderId, user.getUserId());
                resp.sendRedirect(ok ? "orders?deleted=" + orderId : back + "&delete=fail");
                return;
            }

            resp.sendRedirect("orders");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ---------- helpers ----------

    private Integer parseInt(String s) {
        try {
            if (s == null) return null;
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer parsePositiveInt(String s) {
        Integer v = parseInt(s);
        return (v != null && v > 0) ? v : null;
    }
}