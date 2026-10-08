package com.nexora.dao;

import com.nexora.model.InventoryItem;
import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class InventoryDAO {

    public List<InventoryItem> getInventory(boolean lowOnly) throws SQLException {
        String sql = "SELECT p.ProductID, p.ProductName, c.CategoryName, p.StockQty, p.LowStockLevel "
                + "FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID "
                + (lowOnly ? "WHERE p.StockQty <= p.LowStockLevel " : "")
                + "ORDER BY p.StockQty ASC, p.ProductName";
        List<InventoryItem> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new InventoryItem(rs.getInt("ProductID"), rs.getString("ProductName"),
                        rs.getString("CategoryName"), rs.getInt("StockQty"), rs.getInt("LowStockLevel")));
            }
        }
        return list;
    }

    // changeQty: + ගාණක් = restock, - ගාණක් = අඩු කිරීම. Stock 0 ට වඩා අඩු වෙන්න දෙන්නේ නෑ
    public boolean adjustStock(int productId, int changeQty, String reason, int userId)
            throws SQLException {
        String update = "UPDATE Products SET StockQty = StockQty + ? "
                + "WHERE ProductID = ? AND StockQty + ? >= 0";
        String log = "INSERT INTO StockLog (ProductID, ChangeQty, Reason, ChangedBy) VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);   // Stock update + log එක එකට වෙන්න ඕන

            try (PreparedStatement ps = con.prepareStatement(update)) {
                ps.setInt(1, changeQty);
                ps.setInt(2, productId);
                ps.setInt(3, changeQty);
                if (ps.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }
            try (PreparedStatement ps = con.prepareStatement(log)) {
                ps.setInt(1, productId);
                ps.setInt(2, changeQty);
                ps.setString(3, reason);
                ps.setInt(4, userId);
                ps.executeUpdate();
            }
            con.commit();
            return true;
        }
    }

    // {time, product, change, reason, user}
    public List<String[]> getRecentLogs(int limit) throws SQLException {
        String sql = "SELECT TOP (?) l.ChangedAt, p.ProductName, l.ChangeQty, l.Reason, u.FullName "
                + "FROM StockLog l JOIN Products p ON l.ProductID = p.ProductID "
                + "LEFT JOIN Users u ON l.ChangedBy = u.UserID "
                + "ORDER BY l.ChangedAt DESC, l.LogID DESC";
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{
                            rs.getTimestamp("ChangedAt").toString().substring(0, 16),
                            rs.getString("ProductName"),
                            String.valueOf(rs.getInt("ChangeQty")),
                            rs.getString("Reason"),
                            rs.getString("FullName") == null ? "-" : rs.getString("FullName")
                    });
                }
            }
        }
        return list;
    }
}
