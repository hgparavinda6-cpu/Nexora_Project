package com.nexora.dao;

import com.nexora.model.Feedback;
import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class FeedbackDAO {

    public static final int OK = 1;
    public static final int NOT_ELIGIBLE = 0;   // Delivered order එකක නැති බඩුවක්
    public static final int DUPLICATE = -1;     // කලින්ම feedback දාලා

    // Product එක මකලා නම් Order එකේ තියෙන නම පෙන්නනවා
    private static final String BASE =
            "SELECT f.FeedbackID, u.FullName, f.ProductID, "
                    + "COALESCE(p.ProductName, "
                    + "(SELECT TOP 1 oi.ProductName FROM OrderItems oi WHERE oi.ProductID = f.ProductID), "
                    + "'(removed product)') AS ProductName, "
                    + "f.OrderID, f.Rating, f.Comment, f.CreatedAt "
                    + "FROM Feedback f JOIN Users u ON u.UserID = f.UserID "
                    + "LEFT JOIN Products p ON p.ProductID = f.ProductID ";

    // ---------------------------------------------------------- CUSTOMER

    // Review කරන්න පුළුවන් බඩු: Delivered order වල තියෙන, තාම feedback නොදාපු ඒවා
    // {productId, productName, orderId}
    public List<String[]> getReviewable(int userId) throws SQLException {
        String sql = "SELECT oi.ProductID, oi.ProductName, MAX(o.OrderID) AS OrderID "
                + "FROM OrderItems oi JOIN Orders o ON o.OrderID = oi.OrderID "
                + "WHERE o.UserID = ? AND o.Status = 'Delivered' "
                + "AND NOT EXISTS (SELECT 1 FROM Feedback f WHERE f.UserID = ? AND f.ProductID = oi.ProductID) "
                + "GROUP BY oi.ProductID, oi.ProductName ORDER BY oi.ProductName";
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2),
                            String.valueOf(rs.getInt(3))});
                }
            }
        }
        return list;
    }

    // CREATE
    public int create(int userId, int productId, int rating, String comment) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            Integer orderId = null;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT MAX(o.OrderID) FROM OrderItems oi JOIN Orders o ON o.OrderID = oi.OrderID "
                            + "WHERE o.UserID = ? AND o.Status = 'Delivered' AND oi.ProductID = ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int v = rs.getInt(1);
                        if (!rs.wasNull()) orderId = v;
                    }
                }
            }
            if (orderId == null) return NOT_ELIGIBLE;

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO Feedback (UserID, ProductID, OrderID, Rating, Comment) VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                ps.setInt(3, orderId);
                ps.setInt(4, rating);
                ps.setString(5, comment);
                ps.executeUpdate();
                return OK;
            } catch (SQLException e) {
                if (e.getErrorCode() == 2627 || e.getErrorCode() == 2601) return DUPLICATE;
                throw e;
            }
        }
    }

    // READ: තමන්ගේ feedback
    public List<Feedback> getByUser(int userId) throws SQLException {
        List<Feedback> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     BASE + "WHERE f.UserID = ? ORDER BY f.FeedbackID DESC")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public Feedback getOne(int feedbackId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     BASE + "WHERE f.FeedbackID = ? AND f.UserID = ?")) {
            ps.setInt(1, feedbackId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    // UPDATE
    public boolean update(int feedbackId, int userId, int rating, String comment) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Feedback SET Rating = ?, Comment = ? WHERE FeedbackID = ? AND UserID = ?")) {
            ps.setInt(1, rating);
            ps.setString(2, comment);
            ps.setInt(3, feedbackId);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // DELETE (customer ගේ තමන්ගේ එක)
    public boolean delete(int feedbackId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM Feedback WHERE FeedbackID = ? AND UserID = ?")) {
            ps.setInt(1, feedbackId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------- SUPPORT OFFICER
    public List<Feedback> getAll() throws SQLException {
        List<Feedback> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(BASE + "ORDER BY f.FeedbackID DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public boolean deleteAny(int feedbackId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM Feedback WHERE FeedbackID = ?")) {
            ps.setInt(1, feedbackId);
            return ps.executeUpdate() > 0;
        }
    }

    // ------------------------------------------------------------ helper
    private Feedback map(ResultSet rs) throws SQLException {
        int oid = rs.getInt("OrderID");
        Integer orderId = rs.wasNull() ? null : oid;
        return new Feedback(rs.getInt("FeedbackID"), rs.getString("FullName"),
                rs.getInt("ProductID"), rs.getString("ProductName"), orderId,
                rs.getInt("Rating"), rs.getString("Comment"),
                rs.getTimestamp("CreatedAt").toString().substring(0, 16));
    }
}