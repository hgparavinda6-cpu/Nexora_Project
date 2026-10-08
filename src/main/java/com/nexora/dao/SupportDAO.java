package com.nexora.dao;

import com.nexora.model.SupportTicket;
import com.nexora.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve"})
public class SupportDAO {

    private static final String BASE =
            "SELECT t.TicketID, t.UserID, u.FullName, t.OrderID, t.Subject, t.Message, "
                    + "t.Status, t.Reply, t.CreatedAt, t.UpdatedAt "
                    + "FROM SupportTickets t JOIN Users u ON u.UserID = t.UserID ";

    // ---------------------------------------------------------- CUSTOMER

    // CREATE: orderId එකක් දීලා තියෙනවා නම් ඒක තමන්ගේ order එකක්ද බලනවා
    public boolean create(int userId, Integer orderId, String subject, String message)
            throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            if (orderId != null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM Orders WHERE OrderID = ? AND UserID = ?")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) return false;
                    }
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO SupportTickets (UserID, OrderID, Subject, Message) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, userId);
                if (orderId == null) ps.setNull(2, Types.INTEGER); else ps.setInt(2, orderId);
                ps.setString(3, subject);
                ps.setString(4, message);
                ps.executeUpdate();
                return true;
            }
        }
    }

    // READ: තමන්ගේ tickets
    public List<SupportTicket> getByUser(int userId) throws SQLException {
        List<SupportTicket> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     BASE + "WHERE t.UserID = ? ORDER BY t.TicketID DESC")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // READ: එක ticket එකක් (තමන්ගේ එකද බලනවා)
    public SupportTicket getOne(int ticketId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     BASE + "WHERE t.TicketID = ? AND t.UserID = ?")) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    // UPDATE: Open ticket එකක් විතරයි customer ට edit කරන්න පුළුවන්
    public boolean update(int ticketId, int userId, String subject, String message)
            throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE SupportTickets SET Subject = ?, Message = ?, UpdatedAt = SYSDATETIME() "
                             + "WHERE TicketID = ? AND UserID = ? AND Status = 'Open'")) {
            ps.setString(1, subject);
            ps.setString(2, message);
            ps.setInt(3, ticketId);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // DELETE: තමන්ගේ ticket එක මකනවා
    public boolean deleteByUser(int ticketId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM SupportTickets WHERE TicketID = ? AND UserID = ?")) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ---------------------------------------------------- SUPPORT OFFICER

    // status = null හෝ "" නම් හැම ticket එකම
    public List<SupportTicket> getAll(String status) throws SQLException {
        boolean all = status == null || status.isEmpty();
        List<SupportTicket> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     BASE + (all ? "" : "WHERE t.Status = ? ") + "ORDER BY t.TicketID DESC")) {
            if (!all) ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public SupportTicket getById(int ticketId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(BASE + "WHERE t.TicketID = ?")) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    // Reply එකක් දානවා + status වෙනස් කරනවා
    public boolean reply(int ticketId, int officerId, String reply, String status)
            throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE SupportTickets SET Reply = ?, RepliedBy = ?, Status = ?, "
                             + "UpdatedAt = SYSDATETIME() WHERE TicketID = ?")) {
            ps.setString(1, reply);
            ps.setInt(2, officerId);
            ps.setString(3, status);
            ps.setInt(4, ticketId);
            return ps.executeUpdate() > 0;
        }
    }

    // Resolved ticket එකක් විතරයි Officer ට මකන්න පුළුවන්
    public boolean deleteResolved(int ticketId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM SupportTickets WHERE TicketID = ? AND Status = 'Resolved'")) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        }
    }

    // ------------------------------------------------------------ helper
    private SupportTicket map(ResultSet rs) throws SQLException {
        int oid = rs.getInt("OrderID");
        Integer orderId = rs.wasNull() ? null : oid;
        return new SupportTicket(rs.getInt("TicketID"), rs.getInt("UserID"),
                rs.getString("FullName"), orderId, rs.getString("Subject"),
                rs.getString("Message"), rs.getString("Status"), rs.getString("Reply"),
                rs.getTimestamp("CreatedAt").toString().substring(0, 16),
                rs.getTimestamp("UpdatedAt").toString().substring(0, 16));
    }
}
