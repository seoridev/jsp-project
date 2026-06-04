package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CafePostLikeDAO extends BaseDAO {

    public boolean existsLike(int postId, String memberId) {
        String sql = "SELECT 1 FROM cafe_post_like WHERE post_id = ? AND member_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleLike(int postId, String memberId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            boolean exists = existsLike(conn, postId, memberId);
            if (exists) {
                if (!deleteLike(conn, postId, memberId)) {
                    conn.rollback();
                    return false;
                }
                updateLikeCount(conn, postId, -1);
            } else {
                if (!insertLike(conn, postId, memberId)) {
                    conn.rollback();
                    return false;
                }
                updateLikeCount(conn, postId, 1);
            }
            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public int countLike(int postId) {
        String sql = "SELECT COUNT(*) FROM cafe_post_like WHERE post_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countLikesByMemberInCafe(int cafeId, String memberId) {
        String sql = "SELECT COUNT(*) FROM cafe_post_like cpl "
                + "JOIN cafe_post cp ON cpl.post_id = cp.post_id "
                + "WHERE cp.cafe_id = ? AND cpl.member_id = ? "
                + "AND cp.is_deleted = 'N' AND cp.is_hidden = 'N'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private boolean existsLike(Connection conn, int postId, String memberId) throws Exception {
        String sql = "SELECT 1 FROM cafe_post_like WHERE post_id = ? AND member_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean insertLike(Connection conn, int postId, String memberId) throws Exception {
        String sql = "INSERT INTO cafe_post_like (like_id, post_id, member_id) "
                + "VALUES (seq_cafe_post_like.NEXTVAL, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean deleteLike(Connection conn, int postId, String memberId) throws Exception {
        String sql = "DELETE FROM cafe_post_like WHERE post_id = ? AND member_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private void updateLikeCount(Connection conn, int postId, int amount) throws Exception {
        String sql = "UPDATE cafe_post SET like_count = GREATEST(like_count + ?, 0) WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception ignored) {
            }
        }
    }
}
