package com.evoting.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database connection utility. Manages JDBC connections to MySQL.
 * In production, replace with a connection pool (HikariCP, DBCP).
 */
public class DBUtil {

    private static String URL;
    private static String USERNAME;
    private static String PASSWORD;

    static {
        try {
            Properties props = new Properties();
            InputStream is = DBUtil.class.getClassLoader().getResourceAsStream("app.properties");
            if (is != null) {
                props.load(is);
                URL = props.getProperty("db.url");
                USERNAME = props.getProperty("db.username");
                PASSWORD = props.getProperty("db.password");
                String driver = props.getProperty("db.driver");
                Class.forName(driver);
            } else {
                // Fallback defaults
                URL = "jdbc:mysql://localhost:3306/e_voting?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
                USERNAME = "root";
                PASSWORD = "root";
                Class.forName("com.mysql.cj.jdbc.Driver");
            }
        } catch (ClassNotFoundException | IOException e) {
            throw new RuntimeException("Failed to initialize database connection", e);
        }
    }

    /**
     * Get a new database connection.
     * Caller is responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /**
     * Quietly close a connection (null-safe).
     */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable resource : resources) {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception e) {
                    // Silently ignore close errors
                }
            }
        }
    }
}
