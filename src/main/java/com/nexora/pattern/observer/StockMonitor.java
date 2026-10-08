package com.nexora.pattern.observer;

import com.nexora.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


public class StockMonitor {

    private static final LowStockSubject SUBJECT = new LowStockSubject();

    static {
        SUBJECT.addObserver(new AdminAlertObserver());
        SUBJECT.addObserver(new LogObserver());
    }

    public static void check(String productName, int stockQty, int lowLevel) {
        SUBJECT.checkStock(productName, stockQty, lowLevel);
    }

    public static void checkProduct(int productId) {
        String sql = "SELECT ProductName, StockQty, LowStockLevel FROM Products WHERE ProductID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    check(rs.getString("ProductName"), rs.getInt("StockQty"),
                            rs.getInt("LowStockLevel"));
                }
            }
        } catch (Exception e) {

            e.printStackTrace();
        }
    }
}