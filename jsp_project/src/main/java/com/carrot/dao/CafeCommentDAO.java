package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeCommentDTO;

public class CafeCommentDAO extends BaseDAO {

    public boolean insertComment(int postId, String writerId, String content) {
        String sql = "INSERT INTO cafe_comment (comment_id, post_id, writer_id, content) "
                + "VALUES (seq_cafe_comment.NEXTVAL, ?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, writerId);
            pstmt.setString(3, content);
            boolean inserted = pstmt.executeUpdate() > 0;
            if (inserted) {
                updateCommentCount(conn, postId, 1);
            }
            return inserted;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CafeCommentDTO> selectCommentsByPostId(int postId) {
        List<CafeCommentDTO> list = new ArrayList<>();
        String sql = "SELECT cc.*, cp.cafe_id, m.nickname AS writer_nickname "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "WHERE cc.post_id = ? AND cc.is_deleted = 'N' "
                + "ORDER BY cc.created_at ASC, cc.comment_id ASC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapComment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CafeCommentDTO selectCommentById(int commentId) {
        String sql = "SELECT cc.*, cp.cafe_id, m.nickname AS writer_nickname "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "WHERE cc.comment_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, commentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapComment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteComment(int commentId, String memberId, boolean manager) {
        CafeCommentDTO comment = selectCommentById(commentId);
        if (comment == null || "Y".equals(comment.getIsDeleted())
                || (!manager && (memberId == null || !memberId.equals(comment.getWriterId())))) {
            return false;
        }

        String sql = "UPDATE cafe_comment SET is_deleted = 'Y', updated_at = SYSTIMESTAMP WHERE comment_id = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, commentId);
            boolean deleted = pstmt.executeUpdate() > 0;
            if (deleted) {
                updateCommentCount(conn, comment.getPostId(), -1);
            }
            return deleted;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updateCommentCount(Connection conn, int postId, int amount) throws Exception {
        String sql = "UPDATE cafe_post SET comment_count = GREATEST(comment_count + ?, 0) WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    private CafeCommentDTO mapComment(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        return CafeCommentDTO.builder()
                .commentId(rs.getInt("comment_id"))
                .postId(rs.getInt("post_id"))
                .cafeId(rs.getInt("cafe_id"))
                .writerId(rs.getString("writer_id"))
                .content(rs.getString("content"))
                .isDeleted(rs.getString("is_deleted"))
                .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
                .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
                .writerNickname(rs.getString("writer_nickname"))
                .build();
    }
}
