package com.nexora.dao;

import com.nexora.model.Product;
import com.nexora.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class ProductDAO {

    public List<Product> getAllProducts() throws SQLException {
        String sql = "SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.StockQty, "
                + "c.CategoryName, p.ImageUrl "
                + "FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID "
                + "ORDER BY p.ProductID DESC";
        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    public Map<Integer, String> getCategories() throws SQLException {
        Map<Integer, String> map = new LinkedHashMap<>();
        String sql = "SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("CategoryID"), rs.getString("CategoryName"));
            }
        }
        return map;
    }

    // පරණ method එක - image නැතිව add කරනවා
    public void addProduct(String name, String description, BigDecimal price,
                           int stockQty, int categoryId) throws SQLException {
        addProduct(name, description, price, stockQty, categoryId, null);
    }

    // අලුත් method එක - imageUrl එක්ක
    public void addProduct(String name, String description, BigDecimal price,
                           int stockQty, int categoryId, String imageUrl) throws SQLException {
        String sql = "INSERT INTO Products (ProductName, Description, Price, StockQty, CategoryID, ImageUrl) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setBigDecimal(3, price);
            ps.setInt(4, stockQty);
            ps.setInt(5, categoryId);
            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                ps.setNull(6, Types.NVARCHAR);
            } else {
                ps.setString(6, imageUrl.trim());
            }
            ps.executeUpdate();
        }
    }

    // Edit Product + Update Stock (image වෙනස් කරන්නේ නැහැ)
    public void updateProduct(int productId, String name, BigDecimal price, int stockQty)
            throws SQLException {
        String sql = "UPDATE Products SET ProductName = ?, Price = ?, StockQty = ? WHERE ProductID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setBigDecimal(2, price);
            ps.setInt(3, stockQty);
            ps.setInt(4, productId);
            ps.executeUpdate();
        }
    }

    // update method එක - imageUrl එක්ක
    public void updateProduct(int productId, String name, BigDecimal price, int stockQty,
                              String imageUrl) throws SQLException {
        String sql = "UPDATE Products SET ProductName = ?, Price = ?, StockQty = ?, ImageUrl = ? "
                + "WHERE ProductID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setBigDecimal(2, price);
            ps.setInt(3, stockQty);
            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                ps.setNull(4, Types.NVARCHAR);
            } else {
                ps.setString(4, imageUrl.trim());
            }
            ps.setInt(5, productId);
            ps.executeUpdate();
        }
    }

    /** Order එකක තියෙන product එකක් delete කරන්න බැහැ. */
    public boolean isProductInOrders(int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM OrderItems WHERE ProductID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public void deleteProduct(int productId) throws SQLException {
        String sql = "DELETE FROM Products WHERE ProductID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    // Browse + Search (Guest / Customer)
    public List<Product> searchProducts(String keyword, int categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.StockQty, "
                        + "c.CategoryName, p.ImageUrl "
                        + "FROM Products p JOIN Categories c ON p.CategoryID = c.CategoryID WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.ProductName LIKE ? OR p.Description LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
        }
        if (categoryId > 0) {
            sql.append("AND p.CategoryID = ? ");
            params.add(categoryId);
        }
        sql.append("ORDER BY p.ProductName");

        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        }
        return list;
    }

    // ResultSet එකෙන් Product එකක් හදන common method එක
    private Product mapProduct(ResultSet rs) throws SQLException {
        return new Product(rs.getInt("ProductID"), rs.getString("ProductName"),
                rs.getString("Description"), rs.getBigDecimal("Price"),
                rs.getInt("StockQty"), rs.getString("CategoryName"),
                rs.getString("ImageUrl"));
    }
}