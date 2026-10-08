package com.nexora.servlet;

import com.nexora.dao.DeliveryDAO;
import com.nexora.model.User;
import com.nexora.pattern.observer.DeliveryTracker;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@WebServlet("/deliveries")
public class DeliveryServlet extends HttpServlet {

    private static final int NOTE_MAX = 200;
    private static final int REASON_MIN = 5;
    private static final List<String> ALLOWED_STATUSES =
            Arrays.asList("Out for Delivery", "Delivered", "Customer Unavailable", "Delayed");

    private User getStaff(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "DeliveryStaff".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User staff = getStaff(req);
        if (staff == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        boolean activeOnly = !"all".equals(req.getParameter("show"));
        try {
            req.setAttribute("deliveries", new DeliveryDAO().getByStaff(staff.getUserId(), activeOnly));
            req.setAttribute("activeOnly", activeOnly);
            req.getRequestDispatcher("/WEB-INF/views/deliveries.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User staff = getStaff(req);
        if (staff == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        req.setCharacterEncoding("UTF-8");

        // deliveryId වැරදි නම් 500 error එකක් වෙනුවට ආපහු යවනවා
        int deliveryId;
        try {
            deliveryId = Integer.parseInt(req.getParameter("deliveryId"));
        } catch (NumberFormatException e) {
            if ("location".equals(req.getParameter("action"))) {
                respondText(resp, 400, "FAIL");
            } else {
                resp.sendRedirect("deliveries?error=4");
            }
            return;
        }

        try {
            // Live GPS share
            if ("location".equals(req.getParameter("action"))) {
                double lat, lng;
                try {
                    lat = Double.parseDouble(req.getParameter("lat"));
                    lng = Double.parseDouble(req.getParameter("lng"));
                } catch (NumberFormatException | NullPointerException e) {
                    respondText(resp, 400, "FAIL");
                    return;
                }
                boolean valid = !Double.isNaN(lat) && !Double.isNaN(lng)
                        && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
                boolean ok = valid && new DeliveryDAO().updateLocation(deliveryId, staff.getUserId(), lat, lng);
                respondText(resp, ok ? 200 : 400, ok ? "OK" : "FAIL");
                return;
            }

            // Status update
            String newStatus = req.getParameter("newStatus");
            String notes = req.getParameter("notes") == null ? "" : req.getParameter("notes").trim();

            if (newStatus == null || !ALLOWED_STATUSES.contains(newStatus)) {
                resp.sendRedirect("deliveries?error=4");          // අවසර නැති status එකක්
                return;
            }
            if (notes.length() > NOTE_MAX) {
                resp.sendRedirect("deliveries?error=3");          // Notes දිගයි
                return;
            }
            boolean needsReason = "Customer Unavailable".equals(newStatus) || "Delayed".equals(newStatus);
            if (needsReason && notes.length() < REASON_MIN) {
                resp.sendRedirect("deliveries?error=2");          // හේතුව ඕන
                return;
            }

            boolean ok = new DeliveryDAO().updateStatus(deliveryId, staff.getUserId(), newStatus, notes);
            if (ok) {
                DeliveryTracker.statusChanged(deliveryId, newStatus, staff.getUserId());
            }
            resp.sendRedirect("deliveries" + (ok ? "?updated=1" : "?error=1"));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void respondText(HttpServletResponse resp, int status, String text) throws IOException {
        resp.setContentType("text/plain");
        resp.setStatus(status);
        resp.getWriter().write(text);
    }
}