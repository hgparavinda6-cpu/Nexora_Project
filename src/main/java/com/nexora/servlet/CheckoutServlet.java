package com.nexora.servlet;

import com.nexora.dao.CartDAO;
import com.nexora.dao.OrderDAO;
import com.nexora.dao.PromotionDAO;
import com.nexora.model.CartItem;
import com.nexora.model.User;
import com.nexora.pattern.decorator.AddOnBuilder;
import com.nexora.pattern.strategy.DeliveryFeeFactory;
import com.nexora.pattern.strategy.PaymentContext;
import com.nexora.pattern.strategy.PaymentStrategyFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private User getCustomer(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("user");
        if (u instanceof User && "Customer".equals(((User) u).getRole())) return (User) u;
        return null;
    }

    // Checkout page එක පෙන්නනවා. Coupon එකක් තියෙනවා නම් ඒක ගණන් කරනවා
    private void render(HttpServletRequest req, HttpServletResponse resp, User user,
                        String address, String payment, String delivery,
                        boolean giftWrap, boolean insurance, String promoCode,
                        String forcedError)
            throws ServletException, IOException, SQLException {
        List<CartItem> items = new CartDAO().getCart(user.getUserId());
        if (items.isEmpty()) {
            resp.sendRedirect("cart");
            return;
        }
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem i : items) subtotal = subtotal.add(i.getSubtotal());

        BigDecimal discount = BigDecimal.ZERO;
        boolean promoApplied = false;
        String promoError = forcedError;
        if (promoCode != null && !promoCode.isEmpty() && promoError == null) {
            BigDecimal d = new PromotionDAO().findDiscount(promoCode, subtotal);
            if (d == null) {
                promoError = "This coupon is invalid, expired, disabled, or your order is below its minimum amount.";
            } else {
                discount = d;
                promoApplied = true;
            }
        }

        // Strategy pattern: තෝරපු delivery type එකට අදාළ fee එක
        String deliveryType = DeliveryFeeFactory.isSupported(delivery) ? delivery : "Standard";
        BigDecimal shippingFee = DeliveryFeeFactory.create(deliveryType).calculateFee(subtotal);

        // Decorator pattern: තෝරපු add-ons වල fee එක
        BigDecimal addOnFee = AddOnBuilder.feeOf(subtotal, giftWrap, insurance);
        String addOnDescription = AddOnBuilder.descriptionOf(subtotal, giftWrap, insurance);

        List<String> methods = PaymentStrategyFactory.getMethodNames();

        req.setAttribute("items", items);
        req.setAttribute("subtotal", subtotal);
        req.setAttribute("discount", discount);
        req.setAttribute("shippingFee", shippingFee);
        req.setAttribute("addOnFee", addOnFee);
        req.setAttribute("addOnDescription", addOnDescription);
        req.setAttribute("giftWrap", giftWrap);
        req.setAttribute("insurance", insurance);
        req.setAttribute("total", subtotal.subtract(discount).add(shippingFee).add(addOnFee));
        req.setAttribute("methods", methods);
        req.setAttribute("descriptions", PaymentStrategyFactory.getDescriptions());
        req.setAttribute("deliveryOptions", DeliveryFeeFactory.getAll());
        req.setAttribute("selectedDelivery", deliveryType);
        req.setAttribute("address", address == null ? "" : address);
        req.setAttribute("selectedPayment", payment == null ? methods.get(0) : payment);
        req.setAttribute("promoCode", promoCode == null ? "" : promoCode);
        req.setAttribute("promoApplied", promoApplied);
        req.setAttribute("promoError", promoError);
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
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
            render(req, resp, user, "", null, "Standard", false, false, "", null);
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
        String step = req.getParameter("step");
        String payment = req.getParameter("paymentMethod");
        String delivery = req.getParameter("deliveryType");
        if (!DeliveryFeeFactory.isSupported(delivery)) delivery = "Standard";
        boolean giftWrap = req.getParameter("giftWrap") != null;     // ටික් කළා නම් විතරයි parameter එක එන්නේ
        boolean insurance = req.getParameter("insurance") != null;
        String address = req.getParameter("address") == null ? "" : req.getParameter("address").trim();
        String promoCode = req.getParameter("promoCode") == null
                ? "" : req.getParameter("promoCode").trim().toUpperCase();

        try {
            // Delivery option / add-ons මාරු කළාම: ගාණ විතරක් අලුත් කරනවා
            if ("refresh".equals(step)) {
                render(req, resp, user, address, payment, delivery, giftWrap, insurance, promoCode, null);
                return;
            }

            // "Apply coupon" - order එක දාන්නේ නැහැ, ගාණ විතරක් අලුත් කරනවා
            if ("apply".equals(step)) {
                String err = promoCode.isEmpty() ? "Enter a coupon code first." : null;
                render(req, resp, user, address, payment, delivery, giftWrap, insurance, promoCode, err);
                return;
            }

            // "Place Order"
            if (address.isEmpty() || !PaymentStrategyFactory.isSupported(payment)) {
                render(req, resp, user, address, payment, delivery, giftWrap, insurance, promoCode, null);
                return;
            }
            int result = new OrderDAO().placeOrder(user.getUserId(), payment, address,
                    promoCode.isEmpty() ? null : promoCode, delivery, giftWrap, insurance);
            if (result == OrderDAO.EMPTY_CART) {
                resp.sendRedirect("cart");
            } else if (result == OrderDAO.NOT_ENOUGH_STOCK) {
                resp.sendRedirect("cart?error=stock");
            } else if (result == OrderDAO.INVALID_PROMO) {
                render(req, resp, user, address, payment, delivery, giftWrap, insurance, promoCode,
                        "This coupon is no longer valid. Remove it or try another one.");
            } else {
                // Strategy pattern: තෝරපු payment method එකට අදාළ strategy එකෙන් payment process කරනවා
                PaymentContext context = new PaymentContext();
                context.setPaymentStrategy(PaymentStrategyFactory.create(payment));
                System.out.println("[PAYMENT] " + context.checkout(result)
                        + " (" + delivery + " delivery, add-ons: "
                        + AddOnBuilder.descriptionOf(BigDecimal.ZERO, giftWrap, insurance) + ")");

                resp.sendRedirect("orders?placed=" + result);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}