package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminCommunityActionLogDAO extends BaseDAO {

    public boolean hasLogTable() {
        try (Connection conn = getConnection()) {
            return hasLogTable(conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasLogTable(Connection conn) throws Exception {
        String sql = "SELECT COUNT(*) FROM user_tables WHERE table_name = 'ADMIN_COMMUNITY_ACTION_LOG'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public boolean insertLog(Connection conn, String adminId, String targetType, int targetId,
            String actionType, String adminMemo) throws Exception {
        if (!hasLogTable(conn) || isBlank(adminId) || isBlank(targetType) || isBlank(actionType)
                || isBlank(adminMemo)) {
            return false;
        }

        String memo = adminMemo.trim();
        if (memo.length() > 1000) {
            memo = memo.substring(0, 1000);
        }

        String sql = "INSERT INTO admin_community_action_log "
                + "(log_id, admin_id, target_type, target_id, action_type, admin_memo, created_at) "
                + "VALUES (seq_admin_community_action_log.NEXTVAL, ?, ?, ?, ?, ?, SYSTIMESTAMP)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, adminId);
            pstmt.setString(2, targetType);
            pstmt.setInt(3, targetId);
            pstmt.setString(4, actionType);
            pstmt.setString(5, memo);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
