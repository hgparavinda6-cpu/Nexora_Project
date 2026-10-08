package com.nexora.servlet;

import com.nexora.dao.OrderDAO;
import com.nexora.dao.SupportDAO;
import com.nexora.model.SupportTicket;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/support")
public class SupportServlet extends HttpServlet {

    private static final int SUBJECT_MIN = 3;
    private static final int SUBJECT_MAX = 100;
    private static final int MESSAGE_MIN = 10;
    private static final int MESSAGE_MAX = 1000;

    private User getCustomer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Customer".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    private Integer parseInt(String s) {
        try {
            return Integer.valueOf(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private boolean validText(String subject, String message) {
        return subject.length() >= SUBJECT_MIN && subject.length() <= SUBJECT_MAX
                && message.length() >= MESSAGE_MIN && message.length() <= MESSAGE_MAX;
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
            SupportDAO dao = new SupportDAO();
            req.setAttribute("tickets", dao.getByUser(user.getUserId()));
            req.setAttribute("orders", new OrderDAO().getOrdersByUser(user.getUserId()));

            // ?edit=<ticketId> : Open ticket එකක් edit කරන්න form එක පෙන්නනවා
            Integer editId = parseInt(req.getParameter("edit") == null ? "" : req.getParameter("edit"));
            if (editId != null) {
                SupportTicket t = dao.getOne(editId, user.getUserId());
                if (t != null && "Open".equals(t.getStatus())) req.setAttribute("editTicket", t);
            }
            req.getRequestDispatcher("/WEB-INF/views/support.jsp").forward(req, resp);
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
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        // FIX: form එකේ input නම "subject" (small s)
        String subject = req.getParameter("subject") == null ? "" : req.getParameter("subject").trim();
        String message = req.getParameter("message") == null ? "" : req.getParameter("message").trim();
        Integer ticketId = parseInt(req.getParameter("ticketId") == null ? "" : req.getParameter("ticketId"));

        try {
            SupportDAO dao = new SupportDAO();

            if ("create".equals(action)) {
                if (!validText(subject, message)) {
                    resp.sendRedirect("support?msg=invalid");
                    return;
                }
                String o = req.getParameter("orderId");
                Integer orderId = null;
                if (o != null && !o.trim().isEmpty()) {
                    orderId = parseInt(o);
                    if (orderId == null || orderId <= 0) {      // අංකයක් නොවෙන අගයක්
                        resp.sendRedirect("support?msg=invalid");
                        return;
                    }
                }
                boolean ok = dao.create(user.getUserId(), orderId, subject, message);
                resp.sendRedirect("support?msg=" + (ok ? "created" : "badorder"));

            } else if ("update".equals(action) && ticketId != null) {
                if (!validText(subject, message)) {
                    resp.sendRedirect("support?msg=invalid&edit=" + ticketId);
                    return;
                }
                boolean ok = dao.update(ticketId, user.getUserId(), subject, message);
                resp.sendRedirect("support?msg=" + (ok ? "updated" : "locked"));

            } else if ("delete".equals(action) && ticketId != null) {
                boolean ok = dao.deleteByUser(ticketId, user.getUserId());
                resp.sendRedirect("support?msg=" + (ok ? "deleted" : "fail"));

            } else {
                resp.sendRedirect("support");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}