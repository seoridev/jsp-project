package com.carrot.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.carrot.dto.AdminDTO;

// 관리자 계정 조회와 로그인 검증
public class AdminDAO extends BaseDAO {
    // 관리자 로그인
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

    // 관리자 아이디로 조회
    public AdminDTO getAdminByLoginId(String loginId) {
        String sql = "SELECT login_id, password, name, created_at FROM admin WHERE login_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, loginId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                AdminDTO admin = AdminDTO.builder()
                    .loginId(rs.getString("login_id"))
                    .password(rs.getString("password"))
                    .name(rs.getString("name"))
                    .build();

                try {
                    admin.setCreatedAt(rs.getTimestamp("created_at"));
                } catch (SQLException ignored) {
                    admin.setCreatedAt(null);
                }

                return admin;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 비밀번호 해시 처리
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
