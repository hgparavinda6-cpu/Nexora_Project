package com.nexora.dao;

import com.nexora.model.Order;
import com.nexora.model.OrderItem;
import com.nexora.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import com.nexora.pattern.observer.StockMonitor;
import com.nexora.pattern.strategy.DeliveryFeeFactory;
import com.nexora.pattern.decorator.AddOnBuilder;   // DECORATOR

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class OrderDAO {

    public static final int EMPTY_CART = -1;
    public static final int NOT_ENOUGH_STOCK = -2;
    public static final int NOT_EDITABLE = -3;
    public static final int BAD_PRODUCT = -4;
    public static final int INVALID_PROMO = -5;
    public static final int EDIT_OK = 1;

    private static class Line {
        int productId; String name; BigDecimal price; int qty;
        Line(int productId, String name, BigDecimal price, int qty) {
            this.productId = productId; this.name = name; this.price = price; this.qty = qty;
        }
    }

    // ---------------------------------------------------------------- CREATE
    public int placeOrder(int userId, String paymentMethod, String address) throws SQLException {
        return placeOrder(userId, paymentMethod, address, null);
    }

    public int placeOrder(int userId, String paymentMethod, String address, String promoCode)
            throws SQLException {
        return placeOrder(userId, paymentMethod, address, promoCode, "Standard");
    }

    public int placeOrder(int userId, String paymentMethod, String address, String promoCode,
                          String deliveryType) throws SQLException {
        return placeOrder(userId, paymentMethod, address, promoCode, deliveryType, false, false);
    }

    // Cart -> Order. Order id එක return කරනවා, නැත්නම් negative error code එකක්.
    // promoCode එකක් දීලා තියෙනවා නම් server එකේදී ආයෙත් validate කරලා discount එක දානවා
    // deliveryType: Standard / Express (Strategy pattern එකෙන් fee එක ගණන් කරනවා)
    // giftWrap / insurance: add-ons (Decorator pattern එකෙන් fee එක ගණන් කරනවා)
    public int placeOrder(int userId, String paymentMethod, String address, String promoCode,
                          String deliveryType, boolean giftWrap, boolean insurance)
            throws SQLException {
        String cartSql = "SELECT c.ProductID, p.ProductName, p.Price, p.StockQty, c.Quantity "
                + "FROM Cart c JOIN Products p WITH (UPDLOCK, ROWLOCK) "
                + "ON c.ProductID = p.ProductID WHERE c.UserID = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                List<Line> lines = new ArrayList<>();
                BigDecimal subtotal = BigDecimal.ZERO;

                try (PreparedStatement ps = con.prepareStatement(cartSql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int qty = rs.getInt("Quantity");
                            if (qty > rs.getInt("StockQty")) {
                                con.rollback();
                                return NOT_ENOUGH_STOCK;
                            }
                            Line l = new Line(rs.getInt("ProductID"), rs.getString("ProductName"),
                                    rs.getBigDecimal("Price"), qty);
                            lines.add(l);
                            subtotal = subtotal.add(l.price.multiply(BigDecimal.valueOf(qty)));
                        }
                    }
                }
                if (lines.isEmpty()) {
                    con.rollback();
                    return EMPTY_CART;
                }

                // Coupon එක
                String promo = (promoCode == null || promoCode.trim().isEmpty())
                        ? null : promoCode.trim().toUpperCase();
                BigDecimal discount = BigDecimal.ZERO;
                if (promo != null) {
                    BigDecimal d = new PromotionDAO().findDiscount(promo, subtotal);
                    if (d == null) {
                        con.rollback();
                        return INVALID_PROMO;
                    }
                    discount = d;
                }

                // Strategy pattern: delivery fee එක server එකේදී ගණන් කරනවා
                BigDecimal shippingFee = DeliveryFeeFactory.create(deliveryType).calculateFee(subtotal);

                // DECORATOR pattern: add-ons වල fee එක සහ විස්තරය
                BigDecimal addOnFee = AddOnBuilder.feeOf(subtotal, giftWrap, insurance);
                String addOns = AddOnBuilder.descriptionOf(subtotal, giftWrap, insurance);

                BigDecimal payable = subtotal.subtract(discount).add(shippingFee).add(addOnFee);

                int orderId;
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Orders (UserID, TotalAmount, PaymentMethod, DeliveryAddress, "
                                + "PromoCode, DiscountAmount, DeliveryType, ShippingFee, AddOns, AddOnFee) "
                                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, userId);
                    ps.setBigDecimal(2, payable);
                    ps.setString(3, paymentMethod);
                    ps.setString(4, address);
                    ps.setString(5, promo);
                    ps.setBigDecimal(6, discount);
                    ps.setString(7, deliveryType == null ? "Standard" : deliveryType);
                    ps.setBigDecimal(8, shippingFee);
                    ps.setString(9, addOns);
                    ps.setBigDecimal(10, addOnFee);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        orderId = keys.getInt(1);
                    }
                }

                try (PreparedStatement item = con.prepareStatement(
                        "INSERT INTO OrderItems (OrderID, ProductID, ProductName, UnitPrice, Quantity) "
                                + "VALUES (?, ?, ?, ?, ?)");
                     PreparedStatement stock = con.prepareStatement(
                             "UPDATE Products SET StockQty = StockQty - ? WHERE ProductID = ?");
                     PreparedStatement log = con.prepareStatement(
                             "INSERT INTO StockLog (ProductID, ChangeQty, Reason, ChangedBy) VALUES (?, ?, ?, ?)")) {
                    for (Line l : lines) {
                        item.setInt(1, orderId);
                        item.setInt(2, l.productId);
                        item.setString(3, l.name);
                        item.setBigDecimal(4, l.price);
                        item.setInt(5, l.qty);
                        item.executeUpdate();

                        stock.setInt(1, l.qty);
                        stock.setInt(2, l.productId);
                        stock.executeUpdate();

                        log.setInt(1, l.productId);
                        log.setInt(2, -l.qty);
                        log.setString(3, "Order #" + orderId);
                        log.setInt(4, userId);
                        log.executeUpdate();
                    }
                }

                try (PreparedStatement ps = con.prepareStatement("DELETE FROM Cart WHERE UserID = ?")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }

                con.commit();

                // Observer pattern: order එක සාර්ථකයි, දැන් හැම product එකකම stock එක පරීක්ෂා කරනවා
                for (Line l : lines) {
                    StockMonitor.checkProduct(l.productId);
                }

                return orderId;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    // ------------------------------------------------------------------ READ
    public List<Order> getOrdersByUser(int userId) throws SQLException {
        String sql = "SELECT OrderID, TotalAmount, Status, PaymentMethod, DeliveryAddress, CreatedAt "
                + "FROM Orders WHERE UserID = ? ORDER BY OrderID DESC";
        List<Order> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapOrder(rs));
            }
        }
        return list;
    }

    // Customer ගේ තමන්ගේ order එක විතරයි ගන්න පුළුවන්
    public Order getOrder(int orderId, int userId) throws SQLException {
        String sql = "SELECT OrderID, TotalAmount, Status, PaymentMethod, DeliveryAddress, CreatedAt "
                + "FROM Orders WHERE OrderID = ? AND UserID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Order o = mapOrder(rs);
                o.setItems(getItems(con, orderId));
                return o;
            }
        }
    }

    // Coupon එකක් පාවිච්චි කරලා තියෙනවා නම්: {code, discountAmount}. නැත්නම් null
    public String[] getDiscountInfo(int orderId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT PromoCode, DiscountAmount FROM Orders "
                             + "WHERE OrderID = ? AND UserID = ? AND PromoCode IS NOT NULL")) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new String[]{rs.getString(1), rs.getBigDecimal(2).toPlainString()};
            }
        }
    }

    // "Add product" dropdown එකට: {id, name, price, stock}
    public List<String[]> getAvailableProducts() throws SQLException {
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT ProductID, ProductName, Price, StockQty FROM Products "
                             + "WHERE StockQty > 0 ORDER BY ProductName");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2),
                        rs.getBigDecimal(3).toPlainString(), String.valueOf(rs.getInt(4))});
            }
        }
        return list;
    }

    // ---------------------------------------------------------------- UPDATE
    // Customer ගේ phone number එක (Delivery Staff ට පේන්නේ මේක)
    public boolean updatePhone(int userId, String phone) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("UPDATE Users SET Phone = ? WHERE UserID = ?")) {
            ps.setString(1, phone);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // Pending order එකක බඩු/quantity edit කරනවා.
    // wanted: productId -> අලුත් quantity (0 = ඉවත් කරන්න). addProductId/addQty = අලුතින් එකතු කරන්න.
    public int editOrder(int orderId, int userId, Map<Integer, Integer> wanted,
                         int addProductId, int addQty) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Pending ද කියලා බලනවා (තමන්ගේ order එකද කියලත්) + coupon, shipping fee, add-on fee
                String promo;
                BigDecimal shippingFee;
                BigDecimal addOnFee;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT Status, PromoCode, ShippingFee, AddOnFee FROM Orders WITH (UPDLOCK) "
                                + "WHERE OrderID = ? AND UserID = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !"Pending".equals(rs.getString(1))) {
                            con.rollback();
                            return NOT_EDITABLE;
                        }
                        promo = rs.getString(2);
                        shippingFee = rs.getBigDecimal(3);
                        addOnFee = rs.getBigDecimal(4);
                    }
                }

                // 2. දැන් order එකේ තියෙන බඩු
                Map<Integer, Integer> current = new LinkedHashMap<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT ProductID, Quantity FROM OrderItems WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) current.put(rs.getInt(1), rs.getInt(2));
                    }
                }

                // 3. අලුත් quantities
                Map<Integer, Integer> target = new LinkedHashMap<>();
                for (Map.Entry<Integer, Integer> e : current.entrySet()) {
                    Integer q = wanted.get(e.getKey());
                    target.put(e.getKey(), q == null ? e.getValue() : q);
                }
                if (addProductId > 0 && addQty > 0) target.merge(addProductId, addQty, Integer::sum);
                target.values().removeIf(q -> q <= 0);
                if (target.isEmpty()) {
                    con.rollback();
                    return EMPTY_CART;      // හැම බඩුවම ඉවත් කරන්න බෑ
                }

                // 4. හැම product එකකම වෙනස (delta) ගණන් කරලා stock සහ order item යාවත්කාලීන කරනවා
                Set<Integer> all = new LinkedHashSet<>(current.keySet());
                all.addAll(target.keySet());
                for (int pid : all) {
                    int oldQty = current.getOrDefault(pid, 0);
                    int newQty = target.getOrDefault(pid, 0);
                    int delta = newQty - oldQty;
                    if (delta == 0) continue;

                    boolean exists = false;
                    String name = null;
                    BigDecimal price = null;
                    int stockQty = 0;
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT ProductName, Price, StockQty FROM Products WITH (UPDLOCK, ROWLOCK) "
                                    + "WHERE ProductID = ?")) {
                        ps.setInt(1, pid);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                exists = true;
                                name = rs.getString(1);
                                price = rs.getBigDecimal(2);
                                stockQty = rs.getInt(3);
                            }
                        }
                    }
                    if (!exists && delta > 0) {          // නැති product එකක් එකතු කරන්න/වැඩි කරන්න බෑ
                        con.rollback();
                        return BAD_PRODUCT;
                    }
                    if (exists && delta > 0 && stockQty < delta) {
                        con.rollback();
                        return NOT_ENOUGH_STOCK;
                    }

                    if (exists) {
                        try (PreparedStatement ps = con.prepareStatement(
                                "UPDATE Products SET StockQty = StockQty - ? WHERE ProductID = ?")) {
                            ps.setInt(1, delta);
                            ps.setInt(2, pid);
                            ps.executeUpdate();
                        }
                        try (PreparedStatement ps = con.prepareStatement(
                                "INSERT INTO StockLog (ProductID, ChangeQty, Reason, ChangedBy) VALUES (?, ?, ?, ?)")) {
                            ps.setInt(1, pid);
                            ps.setInt(2, -delta);
                            ps.setString(3, "Order #" + orderId + " edited");
                            ps.setInt(4, userId);
                            ps.executeUpdate();
                        }
                    }

                    if (oldQty == 0) {
                        try (PreparedStatement ps = con.prepareStatement(
                                "INSERT INTO OrderItems (OrderID, ProductID, ProductName, UnitPrice, Quantity) "
                                        + "VALUES (?, ?, ?, ?, ?)")) {
                            ps.setInt(1, orderId);
                            ps.setInt(2, pid);
                            ps.setString(3, name);
                            ps.setBigDecimal(4, price);
                            ps.setInt(5, newQty);
                            ps.executeUpdate();
                        }
                    } else if (newQty == 0) {
                        try (PreparedStatement ps = con.prepareStatement(
                                "DELETE FROM OrderItems WHERE OrderID = ? AND ProductID = ?")) {
                            ps.setInt(1, orderId);
                            ps.setInt(2, pid);
                            ps.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement ps = con.prepareStatement(
                                "UPDATE OrderItems SET Quantity = ? WHERE OrderID = ? AND ProductID = ?")) {
                            ps.setInt(1, newQty);
                            ps.setInt(2, orderId);
                            ps.setInt(3, pid);
                            ps.executeUpdate();
                        }
                    }
                }

                // 5. අලුත් Subtotal, Coupon එක ආයෙත් ගණන් කරනවා, අලුත් Total එක (shipping + add-on fee එක්ක)
                BigDecimal subtotal;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COALESCE(SUM(UnitPrice * Quantity), 0) FROM OrderItems WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        subtotal = rs.getBigDecimal(1);
                    }
                }
                BigDecimal discount = BigDecimal.ZERO;
                if (promo != null) {
                    BigDecimal d = new PromotionDAO().findDiscount(promo, subtotal);
                    if (d != null) discount = d;
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Orders SET TotalAmount = ?, DiscountAmount = ? WHERE OrderID = ?")) {
                    ps.setBigDecimal(1, subtotal.subtract(discount).add(shippingFee).add(addOnFee));
                    ps.setBigDecimal(2, discount);
                    ps.setInt(3, orderId);
                    ps.executeUpdate();
                }

                con.commit();
                return EDIT_OK;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    // Pending order එකක් විතරයි Cancel කරන්න පුළුවන්. Stock ආපහු එකතු වෙනවා
    public boolean cancelOrder(int orderId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT Status FROM Orders WITH (UPDLOCK) WHERE OrderID = ? AND UserID = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !"Pending".equals(rs.getString(1))) {
                            con.rollback();
                            return false;
                        }
                    }
                }

                List<int[]> items = new ArrayList<>();   // {productId, qty}
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT ProductID, Quantity FROM OrderItems WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) items.add(new int[]{rs.getInt(1), rs.getInt(2)});
                    }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Orders SET Status = 'Cancelled' WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }

                try (PreparedStatement stock = con.prepareStatement(
                        "UPDATE Products SET StockQty = StockQty + ? WHERE ProductID = ?");
                     PreparedStatement log = con.prepareStatement(
                             "INSERT INTO StockLog (ProductID, ChangeQty, Reason, ChangedBy) VALUES (?, ?, ?, ?)")) {
                    for (int[] it : items) {
                        stock.setInt(1, it[1]);
                        stock.setInt(2, it[0]);
                        if (stock.executeUpdate() > 0) {   // Product එක මැකිලා නැත්නම් විතරයි
                            log.setInt(1, it[0]);
                            log.setInt(2, it[1]);
                            log.setString(3, "Order #" + orderId + " cancelled");
                            log.setInt(4, userId);
                            log.executeUpdate();
                        }
                    }
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    // ---------------------------------------------------------------- DELETE
    // Customer ට තමන්ගේ ඕනෑම order එකක් මකන්න පුළුවන්.
    // Pending/Processing order එකක් නම් stock ආපහු එකතු කරනවා.
    public boolean deleteOrder(int orderId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String status;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT Status FROM Orders WITH (UPDLOCK) WHERE OrderID = ? AND UserID = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        status = rs.getString(1);
                    }
                }

                // Stock තාම order එකට වෙන් වෙලා තියෙන්නේ Pending / Processing වලට විතරයි
                if ("Pending".equals(status) || "Processing".equals(status)) {
                    List<int[]> items = new ArrayList<>();   // {productId, qty}
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT ProductID, Quantity FROM OrderItems WHERE OrderID = ?")) {
                        ps.setInt(1, orderId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) items.add(new int[]{rs.getInt(1), rs.getInt(2)});
                        }
                    }
                    try (PreparedStatement stock = con.prepareStatement(
                            "UPDATE Products SET StockQty = StockQty + ? WHERE ProductID = ?");
                         PreparedStatement log = con.prepareStatement(
                                 "INSERT INTO StockLog (ProductID, ChangeQty, Reason, ChangedBy) VALUES (?, ?, ?, ?)")) {
                        for (int[] it : items) {
                            stock.setInt(1, it[1]);
                            stock.setInt(2, it[0]);
                            if (stock.executeUpdate() > 0) {
                                log.setInt(1, it[0]);
                                log.setInt(2, it[1]);
                                log.setString(3, "Order #" + orderId + " deleted");
                                log.setInt(4, userId);
                                log.executeUpdate();
                            }
                        }
                    }
                }

                try (PreparedStatement ps = con.prepareStatement("DELETE FROM Deliveries WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM OrderItems WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM Orders WHERE OrderID = ? AND UserID = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    // --------------------------------------------------------------- helpers
    private List<OrderItem> getItems(Connection con, int orderId) throws SQLException {
        List<OrderItem> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT ProductID, ProductName, UnitPrice, Quantity FROM OrderItems WHERE OrderID = ?")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new OrderItem(rs.getInt("ProductID"), rs.getString("ProductName"),
                            rs.getBigDecimal("UnitPrice"), rs.getInt("Quantity")));
                }
            }
        }
        return list;
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        return new Order(rs.getInt("OrderID"), rs.getBigDecimal("TotalAmount"),
                rs.getString("Status"), rs.getString("PaymentMethod"),
                rs.getString("DeliveryAddress"),
                rs.getTimestamp("CreatedAt").toString().substring(0, 16));
    }
}