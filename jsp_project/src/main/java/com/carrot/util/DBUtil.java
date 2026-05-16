package com.carrot.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

//DB 연결과 리소스 정리를 한곳에서 처리하는 유틸 클래스
public class DBUtil {
    private static final String USER = "C##userjsp";
    private static final String PASSWORD = "123";
    private static ClassNotFoundException driverLoadError;
    //Oracle XE 설치 방식에 따라 SID 또는 서비스 이름이 달라서 둘 다 시도
    private static final String[] URLS = {
        "jdbc:oracle:thin:@localhost:1521:xe",
        "jdbc:oracle:thin:@localhost:1521/XEPDB1"
    };

    static {
        try {
            //앱 시작 시 드라이버를 미리 확인해 두고, 연결 시점에 명확한 오류로 전달
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            driverLoadError = e;
        }
    }

    private DBUtil() {
    }

    //등록된 Oracle URL을 순서대로 시도해서 연결 가능한 DB를 찾음
    public static Connection getConnection() throws SQLException {
        if (driverLoadError != null) {
            throw new SQLException("Oracle JDBC 드라이버를 찾을 수 없습니다.", driverLoadError);
        }

        SQLException lastError = null;

        for (String url : URLS) {
            try {
                return DriverManager.getConnection(url, USER, PASSWORD);
            } catch (SQLException e) {
                //첫 URL이 실패해도 다음 후보를 계속 시도하기 위해 마지막 오류만 보관
                lastError = e;
            }
        }

        throw lastError;
    }

    //ResultSet까지 쓰는 조회 작업에서 한 번에 닫기 위한 헬퍼
    public static void close(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignored) {
            }
        }

        close(stmt, conn);
    }

    //닫기 실패는 원래 예외를 덮지 않도록 무시
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
