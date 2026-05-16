package com.carrot.dao;

import com.carrot.dto.AdminDTO;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

//관리자 계정 조회와 로그인 검증을 맡는 DAO
public class AdminDAO extends BaseDAO {
    //입력한 비밀번호를 DB 값과 비교해서 로그인 가능 여부 확인
    public AdminDTO login(String loginId, String password) throws SQLException {
        AdminDTO admin = getAdminByLoginId(loginId);

        if (admin == null) {
            return null;
        }

        String savedPassword = admin.getPassword();
        String hashedPassword = sha256(password);

        //기존 평문 비밀번호 데이터도 로그인되도록 해시와 평문을 둘 다 비교
        if (!hashedPassword.equals(savedPassword) && !password.equals(savedPassword)) {
            return null;
        }

        return admin;
    }

    //아이디로 관리자 정보를 한 건만 조회
    public AdminDTO getAdminByLoginId(String loginId) throws SQLException {
        String sql = "SELECT login_id, password, name, created_at FROM admin WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
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
                //created_at 컬럼이 문제될 때도 로그인 자체는 막지 않음
                admin.setCreatedAt(rs.getTimestamp("created_at"));
            } catch (SQLException ignored) {
                admin.setCreatedAt(null);
            }
            return admin;
        } finally {
            close(rs, pstmt, conn);
        }
    }

    //DB에는 비밀번호를 SHA-256 문자열로 맞춰 저장하고 비교
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
