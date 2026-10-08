package com.nexora.dao;

import com.nexora.model.Promotion;
import com.nexora.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class PromotionDAO {

    public static final int OK = 1;
    public static final int DUPLICATE = -1;

    private static final String COLS =
            "SELECT PromoID, Code, Title, DiscountType, DiscountValue, MinOrder, StartDate, EndDate, IsActive "
                    + "FROM Promotions ";

    private Promotion map(ResultSet rs) throws SQLException {
        return new Promotion(rs.getInt("PromoID"), rs.getString("Code"), rs.getString("Title"),
                rs.getString("DiscountType"), rs.getBigDecimal("DiscountValue"),
                rs.getBigDecimal("MinOrder"), rs.getDate("StartDate").toString(),
                rs.getDate("EndDate").toString(), rs.getBoolean("IsActive"));
    }

    private List<Promotion> list(String tail) throws SQLException {
        List<Promotion> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(COLS + tail);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<Promotion> getAll() throws SQLException {
        return list("ORDER BY PromoID DESC");
    }

    // Customers ට පේන්න ඕන, දැන් පාවිච්චි කරන්න පුළුවන් ඒවා
    public List<Promotion> getActiveNow() throws SQLException {
        return list("WHERE IsActive = 1 AND CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate "
                + "ORDER BY EndDate");
    }

    // Update කරද්දී discount type එක DB එකෙන් ගන්නවා (form එකේ hidden field එක විශ්වාස කරන්නේ නැහැ)
    public String getType(int id) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT DiscountType FROM Promotions WHERE PromoID = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    public int add(String code, String title, String type, BigDecimal value, BigDecimal minOrder,
                   String start, String end) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT 1 FROM Promotions WHERE Code = ?")) {
                ps.setString(1, code);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return DUPLICATE;
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO Promotions (Code, Title, DiscountType, DiscountValue, MinOrder, StartDate, EndDate) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                ps.setString(1, code);
                ps.setString(2, title);
                ps.setString(3, type);
                ps.setBigDecimal(4, value);
                ps.setBigDecimal(5, minOrder);
                ps.setDate(6, Date.valueOf(start));
                ps.setDate(7, Date.valueOf(end));
                ps.executeUpdate();
                return OK;
            }
        }
    }

    public boolean update(int id, String title, BigDecimal value, BigDecimal minOrder,
                          String start, String end, boolean active) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Promotions SET Title = ?, DiscountValue = ?, MinOrder = ?, "
                             + "StartDate = ?, EndDate = ?, IsActive = ? WHERE PromoID = ?")) {
            ps.setString(1, title);
            ps.setBigDecimal(2, value);
            ps.setBigDecimal(3, minOrder);
            ps.setDate(4, Date.valueOf(start));
            ps.setDate(5, Date.valueOf(end));
            ps.setBoolean(6, active);
            ps.setInt(7, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM Promotions WHERE PromoID = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // Part B වලට: coupon එක වලංගුනම් discount ගාණ දෙනවා, නැත්නම් null
    public BigDecimal findDiscount(String code, BigDecimal subtotal) throws SQLException {
        List<Promotion> found = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     COLS + "WHERE Code = ? AND IsActive = 1 AND MinOrder <= ? "
                             + "AND CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate")) {
            ps.setString(1, code.trim().toUpperCase());
            ps.setBigDecimal(2, subtotal);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) found.add(map(rs));
            }
        }
        if (found.isEmpty()) return null;
        Promotion p = found.get(0);
        BigDecimal discount = "Percent".equals(p.getType())
                ? subtotal.multiply(p.getValue()).divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP)
                : p.getValue();
        return discount.min(subtotal);
    }
}