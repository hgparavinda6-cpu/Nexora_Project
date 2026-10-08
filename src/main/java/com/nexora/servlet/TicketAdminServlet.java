package com.nexora.servlet;

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
import java.util.Arrays;
import java.util.List;

@WebServlet("/tickets")
public class TicketAdminServlet extends HttpServlet {

    private static final List<String> STATUSES = Arrays.asList("Open", "In Progress", "Resolved");
    private static final int REPLY_MAX = 1000;

    private User getOfficer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "SupportOfficer".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User officer = getOfficer(req);
        if (officer == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String filter = req.getParameter("status");
        if (filter != null && !STATUSES.contains(filter)) filter = null;
        try {
            req.setAttribute("tickets", new SupportDAO().getAll(filter));
            req.setAttribute("filter", filter == null ? "" : filter);
            req.setAttribute("statuses", STATUSES);
            req.getRequestDispatcher("/WEB-INF/views/tickets.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User officer = getOfficer(req);
        if (officer == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");

        // filter අගය අවසර ඇති status එකක් නොවේ නම් අයින් කරනවා
        String filter = req.getParameter("filter") == null ? "" : req.getParameter("filter");
        if (!filter.isEmpty() && !STATUSES.contains(filter)) filter = "";
        String back = "tickets" + (filter.isEmpty() ? "?" : "?status=" + java.net.URLEncoder.encode(filter, "UTF-8") + "&");

        int ticketId;
        try {
            ticketId = Integer.parseInt(req.getParameter("ticketId").trim());
        } catch (Exception e) {
            resp.sendRedirect("tickets");
            return;
        }

        try {
            SupportDAO dao = new SupportDAO();

            if ("reply".equals(action)) {
                String reply = req.getParameter("reply") == null ? "" : req.getParameter("reply").trim();
                String status = req.getParameter("status");
                if (status == null || !STATUSES.contains(status) || reply.length() > REPLY_MAX) {
                    resp.sendRedirect(back + "msg=invalid");
                    return;
                }
                SupportTicket t = dao.getById(ticketId);
                if (t == null) {
                    resp.sendRedirect(back + "msg=fail");
                    return;
                }
                // Reply කොටුව හිස් නම් කලින් reply එක තියාගන්නවා (status විතරක් වෙනස් කරන්න)
                String finalReply = reply.isEmpty() ? t.getReply() : reply;

                // Resolved කරන්න නම් customer ට පිළිතුරක් තියෙන්න ඕන
                if ("Resolved".equals(status) && (finalReply == null || finalReply.trim().isEmpty())) {
                    resp.sendRedirect(back + "msg=noreply");
                    return;
                }
                boolean ok = dao.reply(ticketId, officer.getUserId(), finalReply, status);
                resp.sendRedirect(back + "msg=" + (ok ? "saved" : "fail"));

            } else if ("delete".equals(action)) {
                boolean ok = dao.deleteResolved(ticketId);
                resp.sendRedirect(back + "msg=" + (ok ? "deleted" : "notresolved"));

            } else {
                resp.sendRedirect("tickets");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}