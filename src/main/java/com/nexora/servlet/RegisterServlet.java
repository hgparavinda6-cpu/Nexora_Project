package com.nexora.servlet;

import com.nexora.dao.UserDAO;
import com.nexora.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    // /register කෙලින්ම browser එකේ ටයිප් කළොත් (GET) register form එකට යවනවා
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect("register.jsp");
    }

    // Error එකක් එක්ක form එකම ආපහු පෙන්නනවා (ලියපු අගයන් රැකගෙන)
    private void showError(HttpServletRequest req, HttpServletResponse resp, String message,
                           String fullName, String email, String phone, String address)
            throws ServletException, IOException {
        req.setAttribute("formError", message);
        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("phone", phone);
        req.setAttribute("address", address);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String fullName = nz(req.getParameter("fullName")).trim();
        String email = nz(req.getParameter("email")).trim().toLowerCase();
        String password = nz(req.getParameter("password"));
        String phone = nz(req.getParameter("phone")).replaceAll("\\s+", "");
        String address = nz(req.getParameter("address")).trim();

        // Server-side validation
        String problem = ValidationUtil.validateRegistration(fullName, email, password, phone, address);
        if (problem != null) {
            showError(req, resp, problem, fullName, email, phone, address);
            return;
        }

        UserDAO dao = new UserDAO();
        try {
            if (dao.emailExists(email)) {
                showError(req, resp, "This email is already registered. Please log in or use another email.",
                        fullName, email, phone, address);
                return;
            }
            dao.registerUser(fullName, email, password, phone, address);
            resp.sendRedirect("login.jsp?registered=1");        // සාර්ථකයි: Login එකට යවනවා
        } catch (SQLException e) {
            e.printStackTrace();
            showError(req, resp, "Something went wrong. Please try again.",
                    fullName, email, phone, address);
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}