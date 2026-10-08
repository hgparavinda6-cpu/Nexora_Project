package com.nexora.dao;

import com.nexora.model.Delivery;
import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class DeliveryDAO {

    private static final String BASE =
            "SELECT d.DeliveryID, d.OrderID, cu.FullName AS Customer, cu.Phone, o.DeliveryAddress, "
                    + "(SELECT STRING_AGG(oi.ProductName + ' x' + CAST(oi.Quantity AS NVARCHAR(10)), ', ') "
                    + " FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS Items, "
                    + "o.TotalAmount, o.PaymentMethod, d.Status, d.Notes, "
                    + "st.FullName + ' (ID: ' + CAST(st.UserID AS NVARCHAR(10)) + ')' AS Staff, d.UpdatedAt "
                    + "FROM Deliveries d JOIN Orders o ON d.OrderID = o.OrderID "
                    + "JOIN Users cu ON o.UserID = cu.UserID JOIN Users st ON d.StaffID = st.UserID ";

    // Delivery Staff ට දැන් තියෙන Status එකෙන් ඊළඟට යන්න පුළුවන් ඒවා
    public static List<String> nextStatuses(String current) {
        switch (current) {
            case "Assigned":             return Collections.singletonList("Out for Delivery");
            case "Out for Delivery":     return Arrays.asList("Delivered", "Customer Unavailable", "Delayed");
            case "Customer Unavailable":
            case "Delayed":              return Collections.singletonList("Out for Delivery");
            default:                     return Collections.emptyList();
        }
    }

    private static String nv(String s) { return s == null ? "" : s; }

    private Delivery map(ResultSet rs) throws SQLException {
        return new Delivery(rs.getInt("DeliveryID"), rs.getInt("OrderID"),
                rs.getString("Customer"), nv(rs.getString("Phone")),
                rs.getString("DeliveryAddress"), nv(rs.getString("Items")),
                rs.getBigDecimal("TotalAmount"), rs.getString("PaymentMethod"),
                rs.getString("Status"), nv(rs.getString("Notes")), rs.getString("Staff"),
                rs.getTimestamp("UpdatedAt").toString().substring(0, 16));
    }

    private List<Delivery> query(String tail, Object... params) throws SQLException {
        List<Delivery> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(BASE + tail)) {
            for (int i = 0; i < params.length; i++) ps.setObject(i + 1, params[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ------------------------------------------------------------------ READ
    public List<Delivery> getByStaff(int staffId, boolean activeOnly) throws SQLException {
        return query("WHERE d.StaffID = ? AND o.Status <> 'Cancelled' "
                + (activeOnly ? "AND d.Status <> 'Delivered' " : "")
                + "ORDER BY d.DeliveryID DESC", staffId);
    }

    public List<Delivery> getAll() throws SQLException {
        return query("ORDER BY d.DeliveryID DESC");
    }

    public Delivery getByOrder(int orderId, int userId) throws SQLException {
        List<Delivery> list = query("WHERE d.OrderID = ? AND o.UserID = ?", orderId, userId);
        return list.isEmpty() ? null : list.get(0);
    }

    // {orderId, customer, address, total}
    public List<String[]> getUnassignedOrders() throws SQLException {
        String sql = "SELECT o.OrderID, u.FullName, o.DeliveryAddress, o.TotalAmount "
                + "FROM Orders o JOIN Users u ON o.UserID = u.UserID "
                + "WHERE o.Status = 'Processing' "
                + "AND NOT EXISTS (SELECT 1 FROM Deliveries d WHERE d.OrderID = o.OrderID) "
                + "ORDER BY o.OrderID";
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2),
                        rs.getString(3), rs.getBigDecimal(4).toString()});
            }
        }
        return list;
    }

    // {userId, name}
    public List<String[]> getDeliveryStaff() throws SQLException {
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT UserID, FullName FROM Users WHERE Role = 'DeliveryStaff' ORDER BY FullName");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2)});
            }
        }
        return list;
    }

    // Customer ගේ Track page එකට: {lat, lng, time}. නැත්නම් null
    public String[] getLocation(int orderId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT d.CurrentLat, d.CurrentLng, d.LocationUpdatedAt "
                             + "FROM Deliveries d JOIN Orders o ON d.OrderID = o.OrderID "
                             + "WHERE d.OrderID = ? AND o.UserID = ? AND d.CurrentLat IS NOT NULL")) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new String[]{rs.getBigDecimal(1).toPlainString(),
                        rs.getBigDecimal(2).toPlainString(),
                        rs.getTimestamp(3).toString().substring(0, 19)};
            }
        }
    }

    // ---------------------------------------------------------------- CREATE
    // Processing order එකකට, තාම assign නොකරපු නම් විතරයි
    public boolean assign(int orderId, int staffId) throws SQLException {
        String sql = "INSERT INTO Deliveries (OrderID, StaffID) SELECT ?, ? "
                + "WHERE EXISTS (SELECT 1 FROM Orders WHERE OrderID = ? AND Status = 'Processing') "
                + "AND NOT EXISTS (SELECT 1 FROM Deliveries WHERE OrderID = ?) "
                + "AND EXISTS (SELECT 1 FROM Users WHERE UserID = ? AND Role = 'DeliveryStaff')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, staffId);
            ps.setInt(3, orderId);
            ps.setInt(4, orderId);
            ps.setInt(5, staffId);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------- UPDATE
    // Delivery Staff Status update. Order Status එකත් ඒ එක්කම වෙනස් වෙනවා
    public boolean updateStatus(int deliveryId, int staffId, String newStatus, String notes)
            throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String current, orderStatus;
                int orderId;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT d.Status, d.OrderID, o.Status AS OrderStatus "
                                + "FROM Deliveries d WITH (UPDLOCK) JOIN Orders o ON d.OrderID = o.OrderID "
                                + "WHERE d.DeliveryID = ? AND d.StaffID = ?")) {
                    ps.setInt(1, deliveryId);
                    ps.setInt(2, staffId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        current = rs.getString("Status");
                        orderId = rs.getInt("OrderID");
                        orderStatus = rs.getString("OrderStatus");
                    }
                }
                if ("Cancelled".equals(orderStatus) || !nextStatuses(current).contains(newStatus)) {
                    con.rollback();
                    return false;
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Deliveries SET Status = ?, Notes = ?, UpdatedAt = GETDATE(), "
                                + "DeliveredAt = CASE WHEN ? = 'Delivered' THEN GETDATE() ELSE DeliveredAt END "
                                + "WHERE DeliveryID = ?")) {
                    ps.setString(1, newStatus);
                    ps.setString(2, notes);
                    ps.setString(3, newStatus);
                    ps.setInt(4, deliveryId);
                    ps.executeUpdate();
                }

                String newOrderStatus = "Out for Delivery".equals(newStatus) ? "Shipped"
                        : "Delivered".equals(newStatus) ? "Delivered" : null;
                if (newOrderStatus != null) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE Orders SET Status = ? WHERE OrderID = ?")) {
                        ps.setString(1, newOrderStatus);
                        ps.setInt(2, orderId);
                        ps.executeUpdate();
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

    // Delivery Staff ගේ දැන් ඉන්න තැන (Out for Delivery නම් විතරයි)
    public boolean updateLocation(int deliveryId, int staffId, double lat, double lng)
            throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Deliveries SET CurrentLat = ?, CurrentLng = ?, LocationUpdatedAt = GETDATE() "
                             + "WHERE DeliveryID = ? AND StaffID = ? AND Status = 'Out for Delivery'")) {
            ps.setDouble(1, lat);
            ps.setDouble(2, lng);
            ps.setInt(3, deliveryId);
            ps.setInt(4, staffId);
            return ps.executeUpdate() > 0;
        }
    }

    // Customer: Pending / Processing order එකක address එක update කරන්න
    public boolean updateAddress(int orderId, int userId, String address) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Orders SET DeliveryAddress = ? "
                             + "WHERE OrderID = ? AND UserID = ? AND Status IN ('Pending', 'Processing')")) {
            ps.setString(1, address);
            ps.setInt(2, orderId);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // Admin: වෙන Staff කෙනෙක්ට මාරු කරනවා (Delivered නැති ඒවාට විතරයි)
    public boolean reassign(int orderId, int newStaffId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String status;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT d.Status FROM Deliveries d WITH (UPDLOCK) "
                                + "JOIN Orders o ON d.OrderID = o.OrderID "
                                + "WHERE d.OrderID = ? AND o.Status IN ('Processing', 'Shipped')")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        status = rs.getString(1);
                    }
                }
                if ("Delivered".equals(status)) {
                    con.rollback();
                    return false;
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM Users WHERE UserID = ? AND Role = 'DeliveryStaff'")) {
                    ps.setInt(1, newStaffId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                    }
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Deliveries SET StaffID = ?, Status = 'Assigned', Notes = NULL, "
                                + "CurrentLat = NULL, CurrentLng = NULL, LocationUpdatedAt = NULL, "
                                + "UpdatedAt = GETDATE() WHERE OrderID = ?")) {
                    ps.setInt(1, newStaffId);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Orders SET Status = 'Processing' WHERE OrderID = ? AND Status = 'Shipped'")) {
                    ps.setInt(1, orderId);
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

    // Admin: delivery note එක edit කරනවා
    public boolean updateNote(int orderId, String note) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Deliveries SET Notes = ?, UpdatedAt = GETDATE() WHERE OrderID = ?")) {
            ps.setString(1, note);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------------------- DELETE
    // Admin: delivery record එක ඉවත් කරනවා. Delivered නැති එකක් නම් Shipped order එක ආපහු Processing වෙනවා
    public boolean deleteDelivery(int orderId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String status;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT Status FROM Deliveries WITH (UPDLOCK) WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        status = rs.getString(1);
                    }
                }
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM Deliveries WHERE OrderID = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                if (!"Delivered".equals(status)) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE Orders SET Status = 'Processing' WHERE OrderID = ? AND Status = 'Shipped'")) {
                        ps.setInt(1, orderId);
                        ps.executeUpdate();
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
}