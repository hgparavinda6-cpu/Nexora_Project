package com.nexora.dao;

import com.nexora.model.CartItem;
import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class CartDAO {

    public List<CartItem> getCart(int userId) throws SQLException {
        String sql = "SELECT p.ProductID, p.ProductName, p.Price, p.StockQty, c.Quantity "
                + "FROM Cart c JOIN Products p ON c.ProductID = p.ProductID "
                + "WHERE c.UserID = ? ORDER BY c.AddedAt";
        List<CartItem> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CartItem(rs.getInt("ProductID"), rs.getString("ProductName"),
                            rs.getBigDecimal("Price"), rs.getInt("Quantity"), rs.getInt("StockQty")));
                }
            }
        }
        return list;
    }

    // Cart එකේ දැනටමත් තියෙනවා නම් quantity එක වැඩි කරනවා. Stock ඉක්මවන්න දෙන්නේ නෑ
    public boolean addToCart(int userId, int productId, int qty) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            int stock = getStock(con, productId);
            int current = getCartQty(con, userId, productId);
            if (qty <= 0 || current + qty > stock) return false;

            if (current > 0) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Cart SET Quantity = Quantity + ? WHERE UserID = ? AND ProductID = ?")) {
                    ps.setInt(1, qty);
                    ps.setInt(2, userId);
                    ps.setInt(3, productId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Cart (UserID, ProductID, Quantity) VALUES (?, ?, ?)")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, productId);
                    ps.setInt(3, qty);
                    ps.executeUpdate();
                }
            }
            return true;
        }
    }

    public boolean updateQuantity(int userId, int productId, int qty) throws SQLException {
        if (qty <= 0) {
            removeItem(userId, productId);
            return true;
        }
        try (Connection con = DBConnection.getConnection()) {
            if (qty > getStock(con, productId)) return false;
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Cart SET Quantity = ? WHERE UserID = ? AND ProductID = ?")) {
                ps.setInt(1, qty);
                ps.setInt(2, userId);
                ps.setInt(3, productId);
                ps.executeUpdate();
            }
            return true;
        }
    }

    public void removeItem(int userId, int productId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM Cart WHERE UserID = ? AND ProductID = ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }

    private int getStock(Connection con, int productId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT StockQty FROM Products WHERE ProductID = ?")) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int getCartQty(Connection con, int userId, int productId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT Quantity FROM Cart WHERE UserID = ? AND ProductID = ?")) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
