package com.carrot.dao;

import com.carrot.dto.AdminDTO;
import com.carrot.util.DBUtil;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminDAO {
    public AdminDTO login(String loginId, String password) throws SQLException {
        AdminDTO admin = getAdminByLoginId(loginId);

        if (admin == null) {
            return null;
        }

        String savedPassword = admin.getPassword();
        String hashedPassword = sha256(password);

        if (!hashedPassword.equals(savedPassword) && !password.equals(savedPassword)) {
            return null;
        }

        return admin;
    }

    public AdminDTO getAdminByLoginId(String loginId) throws SQLException {
        String sql = "SELECT login_id, password, name, created_at FROM admin WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginId);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
                return null;
            }

            AdminDTO admin = new AdminDTO();
            admin.setLoginId(rs.getString("login_id"));
            admin.setPassword(rs.getString("password"));
            admin.setName(rs.getString("name"));
            try {
                admin.setCreatedAt(rs.getTimestamp("created_at"));
            } catch (SQLException ignored) {
                admin.setCreatedAt(null);
            }
            return admin;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (Exception e) {
            throw new IllegalStateException("비밀번호 확인 중 문제가 발생했습니다.", e);
        }
    }
}
