package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafePostDTO;

public class CafePostDAO extends BaseDAO {

    public int insertPost(CafePostDTO post) {
        String sql = "INSERT INTO cafe_post "
                + "(post_id, cafe_id, board_id, writer_id, title, content, is_notice) "
                + "VALUES (seq_cafe_post.NEXTVAL, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, post.getCafeId());
                pstmt.setInt(2, post.getBoardId());
                pstmt.setString(3, post.getWriterId());
                pstmt.setString(4, post.getTitle());
                pstmt.setString(5, post.getContent());
                pstmt.setString(6, post.getIsNotice() == null ? "N" : post.getIsNotice());
                int result = pstmt.executeUpdate();
                if (result > 0) {
                    updateCafePostCount(conn, post.getCafeId(), 1);
                    int postId = selectLastPostId(conn);
                    conn.commit();
                    return postId;
                }
                conn.rollback();
            }
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
        } finally {
            closeQuietly(conn);
        }
        return 0;
    }

    public List<CafePostDTO> selectPosts(int cafeId, int boardId, String keyword, int limit) {
        return selectPosts(cafeId, boardId, keyword, 1, limit);
    }

    public List<CafePostDTO> selectPosts(int cafeId, int boardId, String keyword, int page, int pageSize) {
        List<CafePostDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseSelect()
                + " WHERE cp.cafe_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' "
                + "AND c.status = 'ACTIVE'");
        params.add(cafeId);
        if (boardId > 0) {
            sql.append(" AND cp.board_id = ?");
            params.add(boardId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(cp.title) LIKE ? OR LOWER(DBMS_LOB.SUBSTR(cp.content, 4000, 1)) LIKE ?)");
            String value = "%" + keyword.trim().toLowerCase() + "%";
            params.add(value);
            params.add(value);
        }
        int safePage = Math.max(1, page);
        int safePageSize = (pageSize == 20) ? 20 : 10;
        int offset = (safePage - 1) * safePageSize;
        sql.append(" ORDER BY cp.is_notice DESC, cp.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(safePageSize);

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countPosts(int cafeId, int boardId, String keyword) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM cafe_post cp "
                + "JOIN cafe c ON cp.cafe_id = c.cafe_id "
                + "WHERE cp.cafe_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' "
                + "AND c.status = 'ACTIVE'");
        params.add(cafeId);
        if (boardId > 0) {
            sql.append(" AND cp.board_id = ?");
            params.add(boardId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(cp.title) LIKE ? OR LOWER(DBMS_LOB.SUBSTR(cp.content, 4000, 1)) LIKE ?)");
            String value = "%" + keyword.trim().toLowerCase() + "%";
            params.add(value);
            params.add(value);
        }

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

    public List<CafePostDTO> selectRecentPosts(int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE' "
                + "ORDER BY cp.created_at DESC FETCH FIRST " + Math.max(1, limit) + " ROWS ONLY";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapPost(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafePostDTO> selectPopularPosts(int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND cp.is_notice = 'N' "
                + "AND c.status = 'ACTIVE' "
                + "ORDER BY (cp.like_count * 3 + cp.comment_count * 2 + cp.view_count) DESC, "
                + "cp.created_at DESC FETCH FIRST " + Math.max(1, limit) + " ROWS ONLY";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapPost(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafePostDTO> selectSearchPosts(String keyword, int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) {
            return list;
        }

        String sql = baseSelect()
                + " WHERE cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE' "
                + "AND (LOWER(cp.title) LIKE ? OR LOWER(DBMS_LOB.SUBSTR(cp.content, 4000, 1)) LIKE ?) "
                + "ORDER BY cp.created_at DESC FETCH FIRST " + Math.max(1, limit) + " ROWS ONLY";
        String value = "%" + keyword.trim().toLowerCase() + "%";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, value);
            pstmt.setString(2, value);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafePostDTO> selectRecentPostsByCafeId(int cafeId, int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.cafe_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE' "
                + "ORDER BY cp.created_at DESC FETCH FIRST " + Math.max(1, limit) + " ROWS ONLY";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafePostDTO> selectPostsByWriter(String writerId) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.writer_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE' "
                + "ORDER BY cp.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, writerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPost(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countPostsByWriterInCafe(int cafeId, String writerId) {
        String sql = "SELECT COUNT(*) FROM cafe_post "
                + "WHERE cafe_id = ? AND writer_id = ? AND is_deleted = 'N' AND is_hidden = 'N'";

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

    public List<CafePostDTO> selectAllPostsForAdmin() {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.is_deleted = 'N' "
                + "ORDER BY cp.created_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapPost(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CafePostDTO selectPostById(int postId) {
        String sql = baseSelect()
                + " WHERE cp.post_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' AND c.status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapPost(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public CafePostDTO selectPostForDelete(int postId) {
        String sql = baseSelect() + " WHERE cp.post_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapPost(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePost(CafePostDTO post, String memberId, boolean manager) {
        CafePostDTO current = selectPostById(post.getPostId());
        if (current == null || (!manager && (memberId == null || !memberId.equals(current.getWriterId())))) {
            return false;
        }

        String isNotice = manager && "Y".equals(post.getIsNotice()) ? "Y" : current.getIsNotice();
        if (manager && !"Y".equals(post.getIsNotice())) {
            isNotice = "N";
        }

        String sql = "UPDATE cafe_post SET title = ?, content = ?, is_notice = ?, updated_at = SYSTIMESTAMP "
                + "WHERE post_id = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, post.getTitle());
            pstmt.setString(2, post.getContent());
            pstmt.setString(3, isNotice);
            pstmt.setInt(4, post.getPostId());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deletePost(int postId, String memberId, boolean manager) {
        CafePostDTO post = selectPostById(postId);
        if (post == null || (!manager && (memberId == null || !memberId.equals(post.getWriterId())))) {
            return false;
        }

        String sql = "UPDATE cafe_post SET is_deleted = 'Y', updated_at = SYSTIMESTAMP "
                + "WHERE post_id = ? AND is_deleted = 'N' AND is_hidden = 'N'";
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, postId);
                boolean deleted = pstmt.executeUpdate() > 0;
                if (!deleted) {
                    conn.rollback();
                    return false;
                }
                updateCafePostCount(conn, post.getCafeId(), -1);
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

    public boolean hidePostByAdmin(int postId) {
        CafePostDTO post = selectPostForDelete(postId);
        if (post == null || "Y".equals(post.getIsDeleted()) || "Y".equals(post.getIsHidden())) {
            return false;
        }

        String sql = "UPDATE cafe_post SET is_hidden = 'Y', updated_at = SYSTIMESTAMP "
                + "WHERE post_id = ? AND is_deleted = 'N' AND is_hidden = 'N'";
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, postId);
                boolean hidden = pstmt.executeUpdate() > 0;
                if (!hidden) {
                    conn.rollback();
                    return false;
                }
                updateCafePostCount(conn, post.getCafeId(), -1);
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

    public void increaseViewCount(int postId) {
        String sql = "UPDATE cafe_post SET view_count = view_count + 1 WHERE post_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String baseSelect() {
        return "SELECT cp.*, cb.board_name, c.cafe_name, m.nickname AS writer_nickname "
                + "FROM cafe_post cp "
                + "JOIN cafe_board cb ON cp.board_id = cb.board_id "
                + "JOIN cafe c ON cp.cafe_id = c.cafe_id "
                + "LEFT JOIN member m ON cp.writer_id = m.login_id";
    }

    private int selectLastPostId(Connection conn) throws Exception {
        try (PreparedStatement pstmt = conn.prepareStatement("SELECT seq_cafe_post.CURRVAL FROM dual");
             ResultSet rs = pstmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private void updateCafePostCount(Connection conn, int cafeId, int amount) throws Exception {
        String sql = "UPDATE cafe SET post_count = GREATEST(post_count + ?, 0), last_active_at = SYSTIMESTAMP WHERE cafe_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, cafeId);
            pstmt.executeUpdate();
        }
    }

    private void bindParams(PreparedStatement pstmt, List<?> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                pstmt.setInt(i + 1, (Integer) value);
            } else {
                pstmt.setString(i + 1, value == null ? null : value.toString());
            }
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

    private CafePostDTO mapPost(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        return CafePostDTO.builder()
                .postId(rs.getInt("post_id"))
                .cafeId(rs.getInt("cafe_id"))
                .boardId(rs.getInt("board_id"))
                .writerId(rs.getString("writer_id"))
                .title(rs.getString("title"))
                .content(rs.getString("content"))
                .viewCount(rs.getInt("view_count"))
                .likeCount(rs.getInt("like_count"))
                .commentCount(rs.getInt("comment_count"))
                .isNotice(rs.getString("is_notice"))
                .isHidden(rs.getString("is_hidden"))
                .isDeleted(rs.getString("is_deleted"))
                .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
                .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
                .writerNickname(rs.getString("writer_nickname"))
                .boardName(rs.getString("board_name"))
                .cafeName(rs.getString("cafe_name"))
                .build();
    }
}
