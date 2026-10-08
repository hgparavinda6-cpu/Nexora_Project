package com.nexora.servlet;

import com.nexora.dao.DeliveryDAO;
import com.nexora.dao.OrderDAO;
import com.nexora.model.Order;
import com.nexora.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/track")
public class TrackServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Object u = req.getSession().getAttribute("user");
        if (!(u instanceof User) || !"Customer".equals(((User) u).getRole())) {
            resp.sendRedirect("login.jsp");
            return;
        }
        User user = (User) u;
        String id = req.getParameter("orderId");
        if (id != null && !id.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(id.trim());
                Order order = new OrderDAO().getOrder(orderId, user.getUserId());
                if (order == null) {
                    req.setAttribute("notFound", true);
                } else {
                    DeliveryDAO dao = new DeliveryDAO();
                    req.setAttribute("order", order);
                    req.setAttribute("delivery", dao.getByOrder(orderId, user.getUserId()));
                    req.setAttribute("location", dao.getLocation(orderId, user.getUserId()));
                }
            } catch (NumberFormatException e) {
                req.setAttribute("notFound", true);
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/track.jsp").forward(req, resp);
    }
}
