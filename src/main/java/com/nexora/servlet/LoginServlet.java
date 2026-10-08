package com.nexora.servlet;

import com.nexora.dao.UserDAO;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            User user = new UserDAO().login(email, password);
            if (user != null) {
                req.getSession().setAttribute("user", user);
                if ("SupportOfficer".equals(user.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/tickets");
                } else if ("DeliveryAdmin".equals(user.getRole())) {
                    resp.sendRedirect(req.getContextPath() + "/assigndelivery");
                } else {
                    resp.sendRedirect("home.jsp");
                }

            } else {
                resp.sendRedirect("login.jsp?error=1");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendRedirect("login.jsp?error=2");
        }
    }
}