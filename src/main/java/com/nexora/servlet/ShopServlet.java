package com.nexora.servlet;

import com.nexora.dao.ProductDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

// Login ඕන නෑ: Guest ටත් products බලන්න පුළුවන්
@WebServlet("/shop")
public class ShopServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String keyword = req.getParameter("q");
        int categoryId = 0;
        try {
            String c = req.getParameter("categoryId");
            if (c != null && !c.isEmpty()) categoryId = Integer.parseInt(c);
        } catch (NumberFormatException ignored) { }

        try {
            ProductDAO dao = new ProductDAO();
            req.setAttribute("products", dao.searchProducts(keyword, categoryId));
            req.setAttribute("categories", dao.getCategories());
            req.setAttribute("q", keyword == null ? "" : keyword);
            req.setAttribute("selectedCategory", categoryId);
            req.getRequestDispatcher("/WEB-INF/views/shop.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
