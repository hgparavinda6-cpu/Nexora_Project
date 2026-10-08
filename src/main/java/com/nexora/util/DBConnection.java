package com.nexora.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DBConnection {

    // 1) private static instance
    private static final DBConnection INSTANCE = new DBConnection();

    private final String url =
            "jdbc:sqlserver://localhost:1433;databaseName=ESHOPPING;encrypt=true;trustServerCertificate=true";
    private final String user = "sa";
    private final String password = "udara123";

    // 2) private constructor
    private DBConnection() {
        try {

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("JDBC driver not found", e);
        }
    }

    // 3) public static getInstance -
    public static DBConnection getInstance() {
        return INSTANCE;
    }

    // Connection
    public Connection openConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }


    public static Connection getConnection() throws SQLException {
        return getInstance().openConnection();
    }

    public static void main(String[] args) {

        System.out.println("Same instance? " + (getInstance() == getInstance()));
        try (Connection con = getConnection()) {
            System.out.println("Connected to ESHOPPING!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}