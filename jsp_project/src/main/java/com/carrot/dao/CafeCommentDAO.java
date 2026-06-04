package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeCommentDTO;

public class CafeCommentDAO extends BaseDAO {
    public static class AdminCommentFilter {
        private String searchType;
        private String keyword;
        private String cafeKeyword;
        private String postKeyword;
        private String writerId;
        private String status;
        private String dateFrom;
        private String dateTo;

        public String getSearchType() {
            return searchType;
        }

        public void setSearchType(String searchType) {
            this.searchType = searchType;
        }

        public String getKeyword() {
            return keyword;
        }

        public void setKeyword(String keyword) {
            this.keyword = keyword;
        }

        public String getCafeKeyword() {
            return cafeKeyword;
        }

        public void setCafeKeyword(String cafeKeyword) {
            this.cafeKeyword = cafeKeyword;
        }

        public String getPostKeyword() {
            return postKeyword;
        }

        public void setPostKeyword(String postKeyword) {
            this.postKeyword = postKeyword;
        }

        public String getWriterId() {
            return writerId;
        }

        public void setWriterId(String writerId) {
            this.writerId = writerId;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getDateFrom() {
            return dateFrom;
        }

        public void setDateFrom(String dateFrom) {
            this.dateFrom = dateFrom;
        }

        public String getDateTo() {
            return dateTo;
        }

        public void setDateTo(String dateTo) {
            this.dateTo = dateTo;
        }
    }

    public boolean insertComment(int postId, String writerId, String content) {
        String sql = "INSERT INTO cafe_comment (comment_id, post_id, writer_id, content) "
                + "VALUES (seq_cafe_comment.NEXTVAL, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, postId);
                pstmt.setString(2, writerId);
                pstmt.setString(3, content);
                boolean inserted = pstmt.executeUpdate() > 0;
                if (!inserted) {
                    conn.rollback();
                    return false;
                }
                updateCommentCount(conn, postId, 1);
                conn.commit();
                return true;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public List<CafeCommentDTO> selectCommentsByPostId(int postId) {
        List<CafeCommentDTO> list = new ArrayList<>();
        String sql = "SELECT cc.*, cp.cafe_id, m.nickname AS writer_nickname, cm.role AS writer_role "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "LEFT JOIN cafe_member cm ON cm.cafe_id = cp.cafe_id AND cm.member_id = cc.writer_id "
                + "AND cm.status = 'ACTIVE' "
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
        String sql = "SELECT cc.*, cp.cafe_id, m.nickname AS writer_nickname, cm.role AS writer_role "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "LEFT JOIN cafe_member cm ON cm.cafe_id = cp.cafe_id AND cm.member_id = cc.writer_id "
                + "AND cm.status = 'ACTIVE' "
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

    public List<CafeCommentDTO> selectCommentsByWriter(String writerId) {
        List<CafeCommentDTO> list = new ArrayList<>();
        String sql = "SELECT cc.*, cp.cafe_id, cp.title AS post_title, cb.board_name, c.cafe_name, "
                + "m.nickname AS writer_nickname, cm.role AS writer_role "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "JOIN cafe_board cb ON cp.board_id = cb.board_id "
                + "JOIN cafe c ON cp.cafe_id = c.cafe_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "LEFT JOIN cafe_member cm ON cm.cafe_id = cp.cafe_id AND cm.member_id = cc.writer_id "
                + "AND cm.status = 'ACTIVE' "
                + "WHERE cc.writer_id = ? AND cc.is_deleted = 'N' "
                + "AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE' "
                + "ORDER BY cc.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, writerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCommentWithPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countCommentsByWriterInCafe(int cafeId, String writerId) {
        String sql = "SELECT COUNT(*) FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "WHERE cp.cafe_id = ? AND cc.writer_id = ? AND cc.is_deleted = 'N' "
                + "AND cp.is_deleted = 'N' AND cp.is_hidden = 'N'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, writerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<CafeCommentDTO> selectCommentsForAdmin(AdminCommentFilter filter, int page, int pageSize) {
        List<CafeCommentDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT cc.*, cp.cafe_id, cp.title AS post_title, cb.board_name, c.cafe_name, "
                + "m.nickname AS writer_nickname, cm.role AS writer_role "
                + "FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "JOIN cafe_board cb ON cp.board_id = cb.board_id "
                + "JOIN cafe c ON cp.cafe_id = c.cafe_id "
                + "LEFT JOIN member m ON cc.writer_id = m.login_id "
                + "LEFT JOIN cafe_member cm ON cm.cafe_id = cp.cafe_id AND cm.member_id = cc.writer_id "
                + "AND cm.status = 'ACTIVE' WHERE 1 = 1 ");
        appendAdminCommentWhere(sql, params, filter);
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, pageSize);
        sql.append("ORDER BY cc.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((safePage - 1) * safePageSize);
        params.add(safePageSize);

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCommentWithPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countCommentsForAdmin(AdminCommentFilter filter) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM cafe_comment cc "
                + "JOIN cafe_post cp ON cc.post_id = cp.post_id "
                + "JOIN cafe_board cb ON cp.board_id = cb.board_id "
                + "JOIN cafe c ON cp.cafe_id = c.cafe_id "
                + "WHERE 1 = 1 ");
        appendAdminCommentWhere(sql, params, filter);

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean deleteComment(int commentId, String memberId, boolean manager) {
        CafeCommentDTO comment = selectCommentById(commentId);
        if (comment == null || "Y".equals(comment.getIsDeleted())
                || (!manager && (memberId == null || !memberId.equals(comment.getWriterId())))) {
            return false;
        }

        String sql = "UPDATE cafe_comment SET is_deleted = 'Y', updated_at = SYSTIMESTAMP "
                + "WHERE comment_id = ? AND is_deleted = 'N'";
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, commentId);
                boolean deleted = pstmt.executeUpdate() > 0;
                if (!deleted) {
                    conn.rollback();
                    return false;
                }
                updateCommentCount(conn, comment.getPostId(), -1);
                conn.commit();
                return true;
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public boolean updateCommentDeletedByAdmin(int commentId, boolean deleted) {
        CafeCommentDTO comment = selectCommentById(commentId);
        String targetDeleted = deleted ? "Y" : "N";
        if (comment == null || targetDeleted.equals(comment.getIsDeleted())) {
            return false;
        }

        String sql = "UPDATE cafe_comment SET is_deleted = ?, updated_at = SYSTIMESTAMP WHERE comment_id = ?";
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, targetDeleted);
                pstmt.setInt(2, commentId);
                if (pstmt.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }
            updateCommentCount(conn, comment.getPostId(), deleted ? -1 : 1);
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

    private void updateCommentCount(Connection conn, int postId, int amount) throws Exception {
        String sql = "UPDATE cafe_post SET comment_count = GREATEST(comment_count + ?, 0) WHERE post_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, postId);
            pstmt.executeUpdate();
        }
    }

    private void appendAdminCommentWhere(StringBuilder sql, List<Object> params, AdminCommentFilter filter) {
        String keyword = clean(filter == null ? null : filter.getKeyword());
        if (keyword != null) {
            String searchType = cleanUpper(filter == null ? null : filter.getSearchType());
            String value = "%" + keyword.toLowerCase() + "%";
            if ("WRITER".equals(searchType)) {
                sql.append("AND LOWER(cc.writer_id) LIKE ? ");
                params.add(value);
            } else if ("POST".equals(searchType)) {
                sql.append("AND LOWER(cp.title) LIKE ? ");
                params.add(value);
            } else if ("CAFE".equals(searchType)) {
                sql.append("AND LOWER(c.cafe_name) LIKE ? ");
                params.add(value);
            } else {
                sql.append("AND LOWER(cc.content) LIKE ? ");
                params.add(value);
            }
        }

        String cafeKeyword = clean(filter == null ? null : filter.getCafeKeyword());
        if (cafeKeyword != null) {
            sql.append("AND (LOWER(c.cafe_name) LIKE ? OR TO_CHAR(c.cafe_id) = ?) ");
            params.add("%" + cafeKeyword.toLowerCase() + "%");
            params.add(cafeKeyword);
        }

        String postKeyword = clean(filter == null ? null : filter.getPostKeyword());
        if (postKeyword != null) {
            sql.append("AND (LOWER(cp.title) LIKE ? OR TO_CHAR(cp.post_id) = ?) ");
            params.add("%" + postKeyword.toLowerCase() + "%");
            params.add(postKeyword);
        }

        String writerId = clean(filter == null ? null : filter.getWriterId());
        if (writerId != null) {
            sql.append("AND LOWER(cc.writer_id) LIKE ? ");
            params.add("%" + writerId.toLowerCase() + "%");
        }

        String status = cleanUpper(filter == null ? null : filter.getStatus());
        if ("VISIBLE".equals(status)) {
            sql.append("AND cc.is_deleted = 'N' ");
        } else if ("HIDDEN".equals(status)) {
            sql.append("AND cc.is_deleted = 'Y' ");
        }

        String dateFrom = clean(filter == null ? null : filter.getDateFrom());
        if (dateFrom != null) {
            sql.append("AND cc.created_at >= TO_TIMESTAMP(?, 'YYYY-MM-DD') ");
            params.add(dateFrom);
        }

        String dateTo = clean(filter == null ? null : filter.getDateTo());
        if (dateTo != null) {
            sql.append("AND cc.created_at < TO_TIMESTAMP(?, 'YYYY-MM-DD') + INTERVAL '1' DAY ");
            params.add(dateTo);
        }
    }

    private void bindParams(PreparedStatement pstmt, List<?> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof Integer) {
                pstmt.setInt(i + 1, (Integer) param);
            } else {
                pstmt.setString(i + 1, String.valueOf(param));
            }
        }
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() || "ALL".equalsIgnoreCase(trimmed) ? null : trimmed;
    }

    private String cleanUpper(String value) {
        String cleaned = clean(value);
        return cleaned == null ? null : cleaned.toUpperCase();
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
                .writerRole(rs.getString("writer_role"))
                .build();
    }

    private CafeCommentDTO mapCommentWithPost(ResultSet rs) throws Exception {
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
                .writerRole(rs.getString("writer_role"))
                .postTitle(rs.getString("post_title"))
                .cafeName(rs.getString("cafe_name"))
                .boardName(rs.getString("board_name"))
                .build();
    }
}
