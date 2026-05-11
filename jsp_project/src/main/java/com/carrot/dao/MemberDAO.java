package com.carrot.dao;

import com.carrot.dto.MemberDTO;
import com.carrot.util.DBUtil;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MemberDAO {
    public static class MemberStats {
        private int totalCount;
        private int activeCount;
        private int stoppedCount;
        private int withdrawnCount;
        private int todayJoinCount;

        public int getTotalCount() {
            return totalCount;
        }

        public int getActiveCount() {
            return activeCount;
        }

        public int getStoppedCount() {
            return stoppedCount;
        }

        public int getWithdrawnCount() {
            return withdrawnCount;
        }

        public int getTodayJoinCount() {
            return todayJoinCount;
        }
    }

    public boolean insertMember(MemberDTO member) throws SQLException {
        String sql = "INSERT INTO member "
            + "(login_id, password, nickname, phone, region, status, created_at) "
            + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', SYSDATE)";

        try {
            return executeInsert(member, sql);
        } catch (SQLException e) {
            if (e.getErrorCode() == 904) {
                String simpleSql = "INSERT INTO member "
                    + "(login_id, password, nickname, phone, region) "
                    + "VALUES (?, ?, ?, ?, ?)";
                return executeInsert(member, simpleSql);
            }
            throw e;
        }
    }

    public MemberDTO login(String loginId, String password) throws SQLException {
        MemberDTO member = getMemberByLoginId(loginId);

        if (member == null) {
            return null;
        }

        String hashedPassword = sha256(password);
        String savedPassword = member.getPassword();

        if (!hashedPassword.equals(savedPassword) && !password.equals(savedPassword)) {
            return null;
        }

        if (member.getStatus() != null && !"ACTIVE".equalsIgnoreCase(member.getStatus())) {
            return null;
        }

        return member;
    }

    public boolean isDuplicateLoginId(String loginId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM member WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginId);
            rs = pstmt.executeQuery();

            return rs.next() && rs.getInt(1) > 0;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public MemberDTO getMemberByLoginId(String loginId) throws SQLException {
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member WHERE login_id = ?";

        try {
            return selectOne(sql, loginId);
        } catch (SQLException e) {
            if (e.getErrorCode() == 904) {
                String simpleSql = "SELECT login_id, password, nickname, phone, region "
                    + "FROM member WHERE login_id = ?";
                return selectOne(simpleSql, loginId);
            }
            throw e;
        }
    }

    public boolean updateMember(MemberDTO member) throws SQLException {
        String sql = "UPDATE member SET nickname = ?, phone = ?, region = ?, "
            + "profile_text = ?, updated_at = SYSDATE WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getNickname());
            setNullableString(pstmt, 2, member.getPhone());
            pstmt.setString(3, member.getRegion());
            setNullableString(pstmt, 4, member.getProfileText());
            pstmt.setString(5, member.getLoginId());
            return pstmt.executeUpdate() > 0;
        } finally {
            DBUtil.close(pstmt, conn);
        }
    }

    public boolean updateMemberStatus(String loginId, String status) throws SQLException {
        String sql = "UPDATE member SET status = ?, updated_at = SYSDATE WHERE login_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setString(2, loginId);
            return pstmt.executeUpdate() > 0;
        } finally {
            DBUtil.close(pstmt, conn);
        }
    }

    public List<MemberDTO> getAllMembers() throws SQLException {
        String sql = "SELECT login_id, password, nickname, phone, region, "
            + "profile_text, manner_score, status, created_at, updated_at "
            + "FROM member ORDER BY created_at DESC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<MemberDTO> members = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                throw e;
            }

            DBUtil.close(rs, pstmt, conn);
            conn = null;
            pstmt = null;
            rs = null;

            String simpleSql = "SELECT login_id, password, nickname, phone, region FROM member ORDER BY login_id";
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(simpleSql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public MemberStats getMemberStats() throws SQLException {
        String sql = "SELECT COUNT(*) AS total_count, "
            + "SUM(CASE WHEN status = 'ACTIVE' OR status IS NULL THEN 1 ELSE 0 END) AS active_count, "
            + "SUM(CASE WHEN status = 'STOPPED' THEN 1 ELSE 0 END) AS stopped_count, "
            + "SUM(CASE WHEN status = 'WITHDRAWN' THEN 1 ELSE 0 END) AS withdrawn_count, "
            + "SUM(CASE WHEN created_at >= TRUNC(SYSDATE) THEN 1 ELSE 0 END) AS today_join_count "
            + "FROM member";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            MemberStats stats = new MemberStats();
            if (rs.next()) {
                stats.totalCount = rs.getInt("total_count");
                stats.activeCount = rs.getInt("active_count");
                stats.stoppedCount = rs.getInt("stopped_count");
                stats.withdrawnCount = rs.getInt("withdrawn_count");
                stats.todayJoinCount = rs.getInt("today_join_count");
            }
            return stats;
        } catch (SQLException e) {
            if (e.getErrorCode() != 904) {
                throw e;
            }

            MemberStats stats = new MemberStats();
            List<MemberDTO> members = getAllMembers();
            stats.totalCount = members.size();
            for (MemberDTO member : members) {
                String status = member.getStatus();
                if ("STOPPED".equalsIgnoreCase(status)) {
                    stats.stoppedCount++;
                } else if ("WITHDRAWN".equalsIgnoreCase(status)) {
                    stats.withdrawnCount++;
                } else {
                    stats.activeCount++;
                }
            }
            return stats;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public int countMembers(String loginId, String nickname, String phone, String region, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM member");
        List<String> params = new ArrayList<>();
        appendMemberFilters(sql, params, loginId, nickname, phone, region, status);

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            bindStringParams(pstmt, params);
            rs = pstmt.executeQuery();

            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    public List<MemberDTO> searchMembers(String loginId, String nickname, String phone, String region,
            String status, int page, int pageSize) throws SQLException {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder(
            "SELECT login_id, password, nickname, phone, region, "
                + "profile_text, manner_score, status, created_at, updated_at FROM member"
        );
        List<String> params = new ArrayList<>();
        appendMemberFilters(sql, params, loginId, nickname, phone, region, status);
        sql.append(" ORDER BY created_at DESC NULLS LAST, login_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<MemberDTO> members = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            int paramIndex = bindStringParams(pstmt, params);
            pstmt.setInt(paramIndex++, offset);
            pstmt.setInt(paramIndex, safePageSize);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                members.add(mapMember(rs));
            }

            return members;
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    private boolean executeInsert(MemberDTO member, String sql) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getLoginId());
            pstmt.setString(2, sha256(member.getPassword()));
            pstmt.setString(3, member.getNickname());
            setNullableString(pstmt, 4, member.getPhone());
            pstmt.setString(5, member.getRegion());
            return pstmt.executeUpdate() > 0;
        } finally {
            DBUtil.close(pstmt, conn);
        }
    }

    private MemberDTO selectOne(String sql, String loginId) throws SQLException {
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

            return mapMember(rs);
        } finally {
            DBUtil.close(rs, pstmt, conn);
        }
    }

    private MemberDTO mapMember(ResultSet rs) throws SQLException {
        MemberDTO member = new MemberDTO();
        member.setLoginId(rs.getString("login_id"));
        member.setPassword(rs.getString("password"));
        member.setNickname(rs.getString("nickname"));
        member.setPhone(getOptionalString(rs, "phone"));
        member.setRegion(rs.getString("region"));
        member.setProfileText(getOptionalString(rs, "profile_text"));
        member.setMannerScore(getOptionalDouble(rs, "manner_score"));
        member.setStatus(getOptionalString(rs, "status"));
        member.setCreatedAt(getOptionalTimestamp(rs, "created_at"));
        member.setUpdatedAt(getOptionalTimestamp(rs, "updated_at"));
        return member;
    }

    private void appendMemberFilters(StringBuilder sql, List<String> params, String loginId,
            String nickname, String phone, String region, String status) {
        List<String> conditions = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            if ("ACTIVE".equalsIgnoreCase(status)) {
                conditions.add("(status = ? OR status IS NULL)");
            } else {
                conditions.add("status = ?");
            }
            params.add(status.trim().toUpperCase());
        }

        appendLikeFilter(conditions, params, "login_id", loginId);
        appendLikeFilter(conditions, params, "nickname", nickname);
        appendLikeFilter(conditions, params, "phone", phone);
        appendLikeFilter(conditions, params, "region", region);

        if (!conditions.isEmpty()) {
            sql.append(" WHERE ");
            for (int i = 0; i < conditions.size(); i++) {
                if (i > 0) {
                    sql.append(" AND ");
                }
                sql.append(conditions.get(i));
            }
        }
    }

    private void appendLikeFilter(List<String> conditions, List<String> params, String columnName, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        conditions.add("LOWER(" + columnName + ") LIKE ?");
        params.add("%" + value.trim().toLowerCase() + "%");
    }

    private int bindStringParams(PreparedStatement pstmt, List<String> params) throws SQLException {
        int index = 1;
        for (String param : params) {
            pstmt.setString(index++, param);
        }
        return index;
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
            throw new IllegalStateException("비밀번호 암호화 중 문제가 발생했습니다.", e);
        }
    }

    private void setNullableString(PreparedStatement pstmt, int index, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            pstmt.setNull(index, java.sql.Types.VARCHAR);
        } else {
            pstmt.setString(index, value.trim());
        }
    }

    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    private double getOptionalDouble(ResultSet rs, String columnName) {
        try {
            return rs.getDouble(columnName);
        } catch (SQLException e) {
            return 0;
        }
    }

    private java.sql.Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (SQLException e) {
            return null;
        }
    }
}
