package com.nexora.dao;

import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class AdminOrderDAO {

    // දැන් තියෙන Status එකෙන් ඊළඟට යන්න පුළුවන් Status ටික
    public static List<String> nextStatuses(String current) {
        switch (current) {
            case "Pending":    return Arrays.asList("Processing", "Cancelled");
            case "Processing": return Collections.singletonList("Cancelled");
            default:           return Collections.emptyList();
        }

    }

    // {id, customer, date, total, payment, status, address, items}
    public List<String[]> getAllOrders(String statusFilter) throws SQLException {
        String sql = "SELECT o.OrderID, u.FullName, o.CreatedAt, o.TotalAmount, o.PaymentMethod, "
                + "o.Status, o.DeliveryAddress, "
                + "(SELECT STRING_AGG(oi.ProductName + ' x' + CAST(oi.Quantity AS NVARCHAR(10)), ', ') "
                + " FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS Items "
                + "FROM Orders o JOIN Users u ON o.UserID = u.UserID "
                + (statusFilter != null ? "WHERE o.Status = ? " : "")
                + "ORDER BY o.OrderID DESC";
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (statusFilter != null) ps.setString(1, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{
                            String.valueOf(rs.getInt("OrderID")),
                            rs.getString("FullName"),
                            rs.getTimestamp("CreatedAt").toString().substring(0, 16),
                            rs.getBigDecimal("TotalAmount").toString(),
                            rs.getString("PaymentMethod"),
                            rs.getString("Status"),
                            rs.getString("DeliveryAddress"),
                            rs.getString("Items") == null ? "" : rs.getString("Items")
                    });
                }
            }
        }
        return list;
    }

    public boolean updateStatus(int orderId, String newStatus, int adminId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String current;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT Status FROM Orders WITH (UPDLOCK) WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        current = rs.getString(1);
                    }
                }
                if (!nextStatuses(current).contains(newStatus)) {
                    con.rollback();
                    return false;
                }

                // Cancel කරනවා නම් Stock ආපහු එකතු කරනවා
                if ("Cancelled".equals(newStatus)) {
                    List<int[]> items = new ArrayList<>();
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
                                log.setString(3, "Order #" + orderId + " cancelled by admin");
                                log.setInt(4, adminId);
                                log.executeUpdate();
                            }
                        }
                    }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Orders SET Status = ? WHERE OrderID = ?")) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, orderId);
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
}
