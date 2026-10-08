package com.nexora.dao;

import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class CategoryDAO {

    // {id, name, productCount}
    public List<String[]> getAll() throws SQLException {
        String sql = "SELECT c.CategoryID, c.CategoryName, COUNT(p.ProductID) AS Cnt "
                + "FROM Categories c LEFT JOIN Products p ON c.CategoryID = p.CategoryID "
                + "GROUP BY c.CategoryID, c.CategoryName ORDER BY c.CategoryName";
        List<String[]> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{
                        String.valueOf(rs.getInt("CategoryID")),
                        rs.getString("CategoryName"),
                        String.valueOf(rs.getInt("Cnt"))});
            }
        }
        return list;
    }

    public void add(String name) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO Categories (CategoryName) VALUES (?)")) {
            ps.setString(1, name);
            ps.executeUpdate();
        }
    }

    public void rename(int id, String name) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Categories SET CategoryName = ? WHERE CategoryID = ?")) {
            ps.setString(1, name);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    // Products තියෙන category එකක් මකන්න දෙන්නේ නෑ
    public boolean delete(int id) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM Products WHERE CategoryID = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) return false;
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM Categories WHERE CategoryID = ?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            return true;
        }
    }
}
