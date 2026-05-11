package com.carrot.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBUtil {
    private static final String USER = "C##userjsp";
    private static final String PASSWORD = "123";
    private static ClassNotFoundException driverLoadError;
    private static final String[] URLS = {
        "jdbc:oracle:thin:@localhost:1521:xe",
        "jdbc:oracle:thin:@localhost:1521/XEPDB1"
    };

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            driverLoadError = e;
        }
    }

    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        if (driverLoadError != null) {
            throw new SQLException("Oracle JDBC 드라이버를 찾을 수 없습니다.", driverLoadError);
        }

        SQLException lastError = null;

        for (String url : URLS) {
            try {
                return DriverManager.getConnection(url, USER, PASSWORD);
            } catch (SQLException e) {
                lastError = e;
            }
        }

        throw lastError;
    }

    public static void close(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignored) {
            }
        }

        close(stmt, conn);
    }

    public static void close(Statement stmt, Connection conn) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignored) {
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
