package com.nexora.servlet;

import com.nexora.dao.FeedbackDAO;
import com.nexora.model.Feedback;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private User getCustomer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Customer".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    private Integer num(String s) {
        try {
            return Integer.valueOf(s.trim());
        } catch (Exception e) {
            return null;
        }
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
            FeedbackDAO dao = new FeedbackDAO();
            req.setAttribute("reviewable", dao.getReviewable(user.getUserId()));
            req.setAttribute("myFeedback", dao.getByUser(user.getUserId()));

            Integer editId = num(req.getParameter("edit") == null ? "" : req.getParameter("edit"));
            if (editId != null) {
                Feedback f = dao.getOne(editId, user.getUserId());
                if (f != null) req.setAttribute("editFeedback", f);
            }
            req.getRequestDispatcher("/WEB-INF/views/feedback.jsp").forward(req, resp);
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
        String comment = req.getParameter("comment") == null ? "" : req.getParameter("comment").trim();
        Integer rating = num(req.getParameter("rating") == null ? "" : req.getParameter("rating"));
        Integer productId = num(req.getParameter("productId") == null ? "" : req.getParameter("productId"));
        Integer feedbackId = num(req.getParameter("feedbackId") == null ? "" : req.getParameter("feedbackId"));

        try {
            FeedbackDAO dao = new FeedbackDAO();

            if ("create".equals(action)) {
                if (productId == null || rating == null || rating < 1 || rating > 5 || comment.length() > 500) {
                    resp.sendRedirect("feedback?msg=invalid");
                    return;
                }
                int r = dao.create(user.getUserId(), productId, rating, comment);
                resp.sendRedirect("feedback?msg=" + (r == FeedbackDAO.OK ? "created"
                        : r == FeedbackDAO.DUPLICATE ? "duplicate" : "noteligible"));

            } else if ("update".equals(action) && feedbackId != null) {
                if (rating == null || rating < 1 || rating > 5 || comment.length() > 500) {
                    resp.sendRedirect("feedback?msg=invalid&edit=" + feedbackId);
                    return;
                }
                boolean ok = dao.update(feedbackId, user.getUserId(), rating, comment);
                resp.sendRedirect("feedback?msg=" + (ok ? "updated" : "fail"));

            } else if ("delete".equals(action) && feedbackId != null) {
                boolean ok = dao.delete(feedbackId, user.getUserId());
                resp.sendRedirect("feedback?msg=" + (ok ? "deleted" : "fail"));

            } else {
                resp.sendRedirect("feedback");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}