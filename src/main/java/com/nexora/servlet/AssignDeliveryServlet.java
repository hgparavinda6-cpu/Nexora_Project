package com.nexora.servlet;

import com.nexora.dao.DeliveryDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/assigndelivery")
public class AssignDeliveryServlet extends HttpServlet {

    private static final int NOTE_MAX = 200;

    private boolean isAdmin(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        return u instanceof User && "DeliveryAdmin".equals(((User) u).getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            DeliveryDAO dao = new DeliveryDAO();
            req.setAttribute("unassigned", dao.getUnassignedOrders());
            req.setAttribute("staff", dao.getDeliveryStaff());
            req.setAttribute("deliveries", dao.getAll());
            req.getRequestDispatcher("/WEB-INF/views/assigndelivery.jsp").forward(req, resp);
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
        if (action == null) action = "assign";

        // අවසර ඇති actions විතරයි
        if (!action.equals("assign") && !action.equals("reassign")
                && !action.equals("note") && !action.equals("delete")) {
            resp.sendRedirect("assigndelivery?error=2");
            return;
        }

        // orderId වැරදි නම් 500 error එකක් වෙනුවට friendly message එකක්
        int orderId;
        try {
            orderId = Integer.parseInt(req.getParameter("orderId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect("assigndelivery?error=2");
            return;
        }
        if (orderId <= 0) {
            resp.sendRedirect("assigndelivery?error=2");
            return;
        }

        try {
            DeliveryDAO dao = new DeliveryDAO();

            // DELETE
            if ("delete".equals(action)) {
                boolean ok = dao.deleteDelivery(orderId);
                resp.sendRedirect("assigndelivery" + (ok ? "?removed=" + orderId : "?error=1"));
                return;
            }

            // UPDATE: note
            if ("note".equals(action)) {
                String note = req.getParameter("note") == null ? "" : req.getParameter("note").trim();
                if (note.length() > NOTE_MAX) {
                    resp.sendRedirect("assigndelivery?error=3");
                    return;
                }
                boolean ok = dao.updateNote(orderId, note);
                resp.sendRedirect("assigndelivery" + (ok ? "?noted=" + orderId : "?error=1"));
                return;
            }

            // assign / reassign දෙකටම staffId ඕන
            int staffId;
            try {
                staffId = Integer.parseInt(req.getParameter("staffId"));
            } catch (NumberFormatException e) {
                resp.sendRedirect("assigndelivery?error=2");
                return;
            }
            if (staffId <= 0) {
                resp.sendRedirect("assigndelivery?error=2");
                return;
            }

            // UPDATE: reassign
            if ("reassign".equals(action)) {
                boolean ok = dao.reassign(orderId, staffId);
                resp.sendRedirect("assigndelivery" + (ok ? "?reassigned=" + orderId : "?error=1"));
                return;
            }

            // CREATE: assign
            boolean ok = dao.assign(orderId, staffId);
            resp.sendRedirect("assigndelivery" + (ok ? "?assigned=" + orderId : "?error=1"));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}