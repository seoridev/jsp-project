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

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post.getCafeId());
            pstmt.setInt(2, post.getBoardId());
            pstmt.setString(3, post.getWriterId());
            pstmt.setString(4, post.getTitle());
            pstmt.setString(5, post.getContent());
            pstmt.setString(6, post.getIsNotice() == null ? "N" : post.getIsNotice());
            int result = pstmt.executeUpdate();
            if (result > 0) {
                updateCafePostCount(conn, post.getCafeId(), 1);
                return selectLastPostId(conn);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<CafePostDTO> selectPosts(int cafeId, int boardId, String keyword, int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        List<String> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseSelect()
                + " WHERE cp.cafe_id = ? AND cp.board_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N'");
        params.add(String.valueOf(cafeId));
        params.add(String.valueOf(boardId));

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(cp.title) LIKE ? OR LOWER(cp.content) LIKE ?)");
            String value = "%" + keyword.trim().toLowerCase() + "%";
            params.add(value);
            params.add(value);
        }
        sql.append(" ORDER BY cp.is_notice DESC, cp.created_at DESC FETCH FIRST ")
                .append(Math.max(1, limit)).append(" ROWS ONLY");

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

    public List<CafePostDTO> selectRecentPosts(int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.is_deleted = 'N' AND cp.is_hidden = 'N' "
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

    public List<CafePostDTO> selectRecentPostsByCafeId(int cafeId, int limit) {
        List<CafePostDTO> list = new ArrayList<>();
        String sql = baseSelect()
                + " WHERE cp.cafe_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N' "
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

    public CafePostDTO selectPostById(int postId) {
        String sql = baseSelect()
                + " WHERE cp.post_id = ? AND cp.is_deleted = 'N' AND cp.is_hidden = 'N'";

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

    public boolean deletePost(int postId, String memberId, boolean manager) {
        CafePostDTO post = selectPostById(postId);
        if (post == null || (!manager && (memberId == null || !memberId.equals(post.getWriterId())))) {
            return false;
        }

        String sql = "UPDATE cafe_post SET is_deleted = 'Y', updated_at = SYSTIMESTAMP WHERE post_id = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            boolean deleted = pstmt.executeUpdate() > 0;
            if (deleted) {
                updateCafePostCount(conn, post.getCafeId(), -1);
            }
            return deleted;
        } catch (Exception e) {
            e.printStackTrace();
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

    private void bindParams(PreparedStatement pstmt, List<String> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            pstmt.setString(i + 1, params.get(i));
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
