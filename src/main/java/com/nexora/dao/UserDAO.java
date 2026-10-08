package com.nexora.dao;

import com.nexora.model.User;
import com.nexora.util.DBConnection;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class UserDAO {

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE Email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void registerUser(String fullName, String email, String password,
                             String phone, String address) throws SQLException {
        String sql = "INSERT INTO Users (FullName, Email, PasswordHash, Phone, Address, Role) "
                + "VALUES (?, ?, ?, ?, ?, 'Customer')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, hash(password));
            ps.setString(4, phone);
            ps.setString(5, address);
            ps.executeUpdate();
        }
    }

    public User login(String email, String password) throws SQLException {
        String sql = "SELECT UserID, FullName, Email, Role FROM Users "
                + "WHERE Email = ? AND PasswordHash = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, hash(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(rs.getInt("UserID"), rs.getString("FullName"),
                            rs.getString("Email"), rs.getString("Role"));
                }
                return null;
            }
        }
    }

    private String hash(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}