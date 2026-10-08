package com.nexora.servlet;

import com.nexora.dao.CategoryDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/categories")
public class CategoryServlet extends HttpServlet {

    private static final int NAME_MIN = 2;
    private static final int NAME_MAX = 50;

    private static final String NAME_PATTERN = "^[\\p{L}0-9][\\p{L}0-9 &'.,/-]*$";

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
            req.setAttribute("categories", new CategoryDAO().getAll());
            req.getRequestDispatcher("/WEB-INF/views/categories.jsp").forward(req, resp);
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

        CategoryDAO dao = new CategoryDAO();
        try {
            // ---------- ADD ----------
            if ("add".equals(action)) {
                String name = trim(req.getParameter("name"));
                if (!validName(name)) {
                    resp.sendRedirect("categories?error=name");
                    return;
                }
                dao.add(name);
                resp.sendRedirect("categories?added=1");
                return;
            }

            // ---------- RENAME ----------
            if ("rename".equals(action)) {
                Integer id = parseId(req.getParameter("id"));
                String name = trim(req.getParameter("name"));
                if (id == null) {
                    resp.sendRedirect("categories?error=invalid");
                    return;
                }
                if (!validName(name)) {
                    resp.sendRedirect("categories?error=name");
                    return;
                }
                dao.rename(id, name);
                resp.sendRedirect("categories?renamed=1");
                return;
            }

            // ---------- DELETE ----------
            if ("delete".equals(action)) {
                Integer id = parseId(req.getParameter("id"));
                if (id == null) {
                    resp.sendRedirect("categories?error=invalid");
                    return;
                }
                if (!dao.delete(id)) {
                    resp.sendRedirect("categories?error=inuse");
                    return;
                }
                resp.sendRedirect("categories?deleted=1");
                return;
            }

            resp.sendRedirect("categories?error=invalid");

        } catch (SQLException e) {

            if (e.getErrorCode() == 2627 || e.getErrorCode() == 2601) {
                resp.sendRedirect("categories?error=duplicate");
            } else if (e.getErrorCode() == 547) {
                resp.sendRedirect("categories?error=inuse");
            } else {
                throw new ServletException(e);
            }
        }
    }

    // ---------- helpers ----------

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private boolean validName(String name) {
        return name.length() >= NAME_MIN && name.length() <= NAME_MAX
                && name.matches(NAME_PATTERN);
    }

    private Integer parseId(String s) {
        try {
            if (s == null) return null;
            int v = Integer.parseInt(s.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}