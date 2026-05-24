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
        return insertBoardAndReturnId(cafeId, boardName, description, readPermission, writePermission,
                isNotice, displayOrder) > 0;
    }

    public int insertBoardAndReturnId(int cafeId, String boardName, String description, String readPermission,
            String writePermission, String isNotice, int displayOrder) {
        String sequenceSql = "SELECT seq_cafe_board.NEXTVAL FROM dual";
        String insertSql = "INSERT INTO cafe_board "
                + "(board_id, cafe_id, board_name, description, read_permission, write_permission, is_notice, display_order) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
                PreparedStatement sequenceStmt = conn.prepareStatement(sequenceSql);
                PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
            int boardId = 0;
            try (ResultSet rs = sequenceStmt.executeQuery()) {
                if (rs.next()) {
                    boardId = rs.getInt(1);
                }
            }
            if (boardId <= 0) {
                return 0;
            }

            insertStmt.setInt(1, boardId);
            insertStmt.setInt(2, cafeId);
            insertStmt.setString(3, boardName);
            insertStmt.setString(4, description);
            insertStmt.setString(5, readPermission);
            insertStmt.setString(6, writePermission);
            insertStmt.setString(7, isNotice);
            insertStmt.setInt(8, displayOrder);
            return insertStmt.executeUpdate() > 0 ? boardId : 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int nextDisplayOrder(int cafeId) {
        String sql = "SELECT NVL(MAX(display_order), 0) + 1 FROM cafe_board WHERE cafe_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1;
    }

    public boolean moveBoard(int cafeId, int boardId, String direction) {
        boolean moveUp = "UP".equals(direction);
        boolean moveDown = "DOWN".equals(direction);
        if (!moveUp && !moveDown) {
            return false;
        }

        String currentSql = "SELECT display_order FROM cafe_board WHERE cafe_id = ? AND board_id = ? AND status = 'ACTIVE'";
        String targetSql = "SELECT board_id, display_order FROM cafe_board "
                + "WHERE cafe_id = ? AND status = 'ACTIVE' AND display_order " + (moveUp ? "<" : ">") + " ? "
                + "ORDER BY display_order " + (moveUp ? "DESC" : "ASC") + ", board_id " + (moveUp ? "DESC" : "ASC")
                + " FETCH FIRST 1 ROWS ONLY";
        String updateSql = "UPDATE cafe_board SET display_order = ?, updated_at = SYSTIMESTAMP "
                + "WHERE cafe_id = ? AND board_id = ? AND status = 'ACTIVE'";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            int currentOrder = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(currentSql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setInt(2, boardId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    currentOrder = rs.getInt("display_order");
                }
            }

            int targetBoardId = 0;
            int targetOrder = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(targetSql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setInt(2, currentOrder);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return true;
                    }
                    targetBoardId = rs.getInt("board_id");
                    targetOrder = rs.getInt("display_order");
                }
            }

            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setInt(1, targetOrder);
                pstmt.setInt(2, cafeId);
                pstmt.setInt(3, boardId);
                pstmt.executeUpdate();

                pstmt.setInt(1, currentOrder);
                pstmt.setInt(2, cafeId);
                pstmt.setInt(3, targetBoardId);
                pstmt.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeError) {
                    closeError.printStackTrace();
                }
            }
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
