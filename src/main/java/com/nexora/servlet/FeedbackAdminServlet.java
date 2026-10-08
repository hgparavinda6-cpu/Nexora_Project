package com.nexora.servlet;

import com.nexora.dao.FeedbackDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/feedbackadmin")
public class FeedbackAdminServlet extends HttpServlet {

    private boolean isOfficer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        return u instanceof User && "SupportOfficer".equals(((User) u).getRole());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isOfficer(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            req.setAttribute("feedbackList", new FeedbackDAO().getAll());
            req.getRequestDispatcher("/WEB-INF/views/feedbackadmin.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isOfficer(req)) {
            resp.sendRedirect("login.jsp");
            return;
        }
        try {
            int id = Integer.parseInt(req.getParameter("feedbackId"));
            boolean ok = new FeedbackDAO().deleteAny(id);
            resp.sendRedirect("feedbackadmin?msg=" + (ok ? "deleted" : "fail"));
        } catch (NumberFormatException e) {
            resp.sendRedirect("feedbackadmin");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}