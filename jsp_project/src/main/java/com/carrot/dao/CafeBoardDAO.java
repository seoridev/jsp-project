package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeBoardDTO;

public class CafeBoardDAO extends BaseDAO {

    public void insertDefaultBoards(int cafeId) {
        insertBoard(cafeId, "공지사항", "카페 소식과 운영 안내", "ALL", "MANAGER", "Y", 1);
        insertBoard(cafeId, "자유게시판", "동네 이웃과 자유롭게 이야기해요", "ALL", "MEMBER", "N", 2);
    }

    public boolean insertBoard(int cafeId, String boardName, String description, String readPermission,
            String writePermission, String isNotice, int displayOrder) {
        String sql = "INSERT INTO cafe_board "
                + "(board_id, cafe_id, board_name, description, read_permission, write_permission, is_notice, display_order) "
                + "VALUES (seq_cafe_board.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, boardName);
            pstmt.setString(3, description);
            pstmt.setString(4, readPermission);
            pstmt.setString(5, writePermission);
            pstmt.setString(6, isNotice);
            pstmt.setInt(7, displayOrder);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CafeBoardDTO> selectBoardsByCafeId(int cafeId) {
        List<CafeBoardDTO> list = new ArrayList<>();
        String sql = "SELECT cb.*, "
                + "(SELECT COUNT(*) FROM cafe_post cp WHERE cp.board_id = cb.board_id AND cp.is_deleted = 'N' AND cp.is_hidden = 'N') AS post_count "
                + "FROM cafe_board cb WHERE cb.cafe_id = ? AND cb.status = 'ACTIVE' "
                + "ORDER BY cb.display_order ASC, cb.board_id ASC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBoard(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CafeBoardDTO selectBoardById(int boardId) {
        String sql = "SELECT cb.*, "
                + "(SELECT COUNT(*) FROM cafe_post cp WHERE cp.board_id = cb.board_id AND cp.is_deleted = 'N' AND cp.is_hidden = 'N') AS post_count "
                + "FROM cafe_board cb WHERE cb.board_id = ? AND cb.status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, boardId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapBoard(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateBoard(CafeBoardDTO board) {
        String sql = "UPDATE cafe_board SET board_name = ?, description = ?, read_permission = ?, "
                + "write_permission = ?, is_notice = ?, display_order = ?, updated_at = SYSTIMESTAMP "
                + "WHERE board_id = ? AND cafe_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, board.getBoardName());
            pstmt.setString(2, board.getDescription());
            pstmt.setString(3, board.getReadPermission());
            pstmt.setString(4, board.getWritePermission());
            pstmt.setString(5, board.getIsNotice());
            pstmt.setInt(6, board.getDisplayOrder());
            pstmt.setInt(7, board.getBoardId());
            pstmt.setInt(8, board.getCafeId());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hideBoard(int boardId, int cafeId) {
        String sql = "UPDATE cafe_board SET status = 'HIDDEN', updated_at = SYSTIMESTAMP "
                + "WHERE board_id = ? AND cafe_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, boardId);
            pstmt.setInt(2, cafeId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasActivePosts(int boardId) {
        String sql = "SELECT 1 FROM cafe_post WHERE board_id = ? AND is_deleted = 'N' AND is_hidden = 'N' FETCH FIRST 1 ROWS ONLY";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, boardId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    private CafeBoardDTO mapBoard(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        return CafeBoardDTO.builder()
                .boardId(rs.getInt("board_id"))
                .cafeId(rs.getInt("cafe_id"))
                .boardName(rs.getString("board_name"))
                .description(rs.getString("description"))
                .readPermission(rs.getString("read_permission"))
                .writePermission(rs.getString("write_permission"))
                .isNotice(rs.getString("is_notice"))
                .isAdminOnly(rs.getString("is_admin_only"))
                .displayOrder(rs.getInt("display_order"))
                .status(rs.getString("status"))
                .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
                .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
                .postCount(rs.getInt("post_count"))
                .build();
    }
}
