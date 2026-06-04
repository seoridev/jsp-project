package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeDTO;

public class CafeDAO extends BaseDAO {
    public static class AdminCafeFilter {
        private String searchType;
        private String keyword;
        private String status;
        private String region;
        private int cafeCategoryId;

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

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getRegion() {
            return region;
        }

        public void setRegion(String region) {
            this.region = region;
        }

        public int getCafeCategoryId() {
            return cafeCategoryId;
        }

        public void setCafeCategoryId(int cafeCategoryId) {
            this.cafeCategoryId = cafeCategoryId;
        }
    }

    public int insertCafe(CafeDTO cafe) {
        String sql = "INSERT INTO cafe "
                + "(cafe_id, cafe_name, description, image_path, region, category, cafe_category_id, visibility, join_type, owner_id) "
                + "VALUES (?, ?, ?, ?, ?, (SELECT category_name FROM cafe_category WHERE cafe_category_id = ?), ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            int cafeId = nextVal(conn, "seq_cafe");
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, cafe.getCafeName());
                pstmt.setString(3, cafe.getDescription());
                pstmt.setString(4, cafe.getImagePath());
                pstmt.setString(5, cafe.getRegion());
                pstmt.setInt(6, cafe.getCafeCategoryId());
                pstmt.setInt(7, cafe.getCafeCategoryId());
                pstmt.setString(8, cafe.getVisibility());
                pstmt.setString(9, cafe.getJoinType());
                pstmt.setString(10, cafe.getOwnerId());
                return pstmt.executeUpdate() > 0 ? cafeId : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int createCafeWithOwnerAndDefaultBoards(CafeDTO cafe) {
        int cafeId = 0;

        try (Connection conn = getConnection()) {
            boolean originalAutoCommit = conn.getAutoCommit();

            try {
                conn.setAutoCommit(false);
                cafeId = nextVal(conn, "seq_cafe");

                if (!insertCafe(conn, cafeId, cafe)) {
                    throw new IllegalStateException("Cafe insert failed");
                }
                if (!insertCafeMember(conn, cafeId, cafe.getOwnerId(), "OWNER", "ACTIVE")) {
                    throw new IllegalStateException("Cafe owner insert failed");
                }
                if (!updateCafeMemberCount(conn, cafeId, 1)) {
                    throw new IllegalStateException("Cafe member count update failed");
                }
                if (!insertCafeBoard(conn, cafeId, "공지사항", "카페 소식과 운영 안내", "ALL", "MANAGER", "Y", 1)) {
                    throw new IllegalStateException("Notice board insert failed");
                }
                if (!insertCafeBoard(conn, cafeId, "자유게시판", "동네 이웃과 자유롭게 이야기해요", "ALL", "MEMBER", "N", 2)) {
                    throw new IllegalStateException("Free board insert failed");
                }

                conn.commit();
                return cafeId;
            } catch (Exception e) {
                try {
                    conn.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
                e.printStackTrace();
                return 0;
            } finally {
                try {
                    conn.setAutoCommit(originalAutoCommit);
                } catch (Exception autoCommitError) {
                    autoCommitError.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isDuplicateCafeName(String cafeName) {
        String sql = "SELECT COUNT(*) FROM cafe WHERE cafe_name = ?";
        boolean duplicate = false;

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, cafeName);
            try (ResultSet rs = pstmt.executeQuery()) {
                duplicate = rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
        return duplicate;
    }

    public CafeDTO selectCafeById(int cafeId) {
        String sql = "SELECT c.*, cc.category_name AS cafe_category_name, m.nickname AS owner_nickname "
                + "FROM cafe c "
                + "LEFT JOIN cafe_category cc ON c.cafe_category_id = cc.cafe_category_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE c.cafe_id = ? AND c.status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapCafe(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<CafeDTO> selectCafeList(String keyword, String region, String category, String sort, int limit) {
        Integer cafeCategoryId = findCafeCategoryIdByName(category);
        return selectCafeListByCategoryId(keyword, region, cafeCategoryId, sort, limit);
    }

    public List<CafeDTO> selectCafeListByCategoryId(String keyword, String region, Integer cafeCategoryId, String sort, int limit) {
        List<CafeDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT c.*, cc.category_name AS cafe_category_name, m.nickname AS owner_nickname "
                + "FROM cafe c "
                + "LEFT JOIN cafe_category cc ON c.cafe_category_id = cc.cafe_category_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE c.status = 'ACTIVE'");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(c.cafe_name) LIKE ? OR LOWER(DBMS_LOB.SUBSTR(c.description, 4000, 1)) LIKE ?)");
            String value = "%" + keyword.trim().toLowerCase() + "%";
            params.add(value);
            params.add(value);
        }
        if (region != null && !region.trim().isEmpty()) {
            sql.append(" AND c.region LIKE ?");
            params.add("%" + region.trim() + "%");
        }
        if (cafeCategoryId != null && cafeCategoryId > 0) {
            sql.append(" AND c.cafe_category_id = ?");
            params.add(cafeCategoryId);
        }

        if ("popular".equals(sort)) {
            sql.append(" ORDER BY c.member_count DESC, c.post_count DESC, c.created_at DESC");
        } else {
            sql.append(" ORDER BY c.created_at DESC");
        }
        sql.append(" FETCH FIRST ").append(Math.max(1, limit)).append(" ROWS ONLY");

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                } else {
                    pstmt.setString(i + 1, (String) param);
                }
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCafe(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Integer findCafeCategoryIdByName(String category) {
        if (category == null || category.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT cafe_category_id FROM cafe_category WHERE category_name = ? AND is_active = 'Y'";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, category.trim());
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cafe_category_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<CafeDTO> selectJoinedCafes(String memberId) {
        List<CafeDTO> list = new ArrayList<>();
        String sql = "SELECT c.*, cc.category_name AS cafe_category_name, m.nickname AS owner_nickname "
                + "FROM cafe_member cm "
                + "JOIN cafe c ON cm.cafe_id = c.cafe_id "
                + "LEFT JOIN cafe_category cc ON c.cafe_category_id = cc.cafe_category_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE cm.member_id = ? AND cm.status = 'ACTIVE' AND cm.role <> 'OWNER' AND c.status = 'ACTIVE' "
                + "ORDER BY cm.joined_at DESC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCafe(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafeDTO> selectOwnedCafes(String ownerId) {
        List<CafeDTO> list = new ArrayList<>();
        String sql = "SELECT c.*, cc.category_name AS cafe_category_name, m.nickname AS owner_nickname "
                + "FROM cafe c "
                + "LEFT JOIN cafe_category cc ON c.cafe_category_id = cc.cafe_category_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE c.owner_id = ? AND c.status = 'ACTIVE' "
                + "ORDER BY c.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ownerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCafe(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CafeDTO> selectAllCafesForAdmin() {
        return selectCafesForAdmin(new AdminCafeFilter(), 1, 1000);
    }

    public List<CafeDTO> selectCafesForAdmin(AdminCafeFilter filter, int page, int pageSize) {
        List<CafeDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT c.*, cc.category_name AS cafe_category_name, m.nickname AS owner_nickname "
                + "FROM cafe c "
                + "LEFT JOIN cafe_category cc ON c.cafe_category_id = cc.cafe_category_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE c.status <> 'DELETED' ");
        appendAdminCafeWhere(sql, params, filter);
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, pageSize);
        sql.append("ORDER BY c.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((safePage - 1) * safePageSize);
        params.add(safePageSize);

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);
            try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapCafe(rs));
            }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countCafesForAdmin(AdminCafeFilter filter) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM cafe c WHERE c.status <> 'DELETED' ");
        appendAdminCafeWhere(sql, params, filter);

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

    public boolean updateCafeStatus(int cafeId, String status) {
        if (!"ACTIVE".equals(status) && !"HIDDEN".equals(status)) {
            return false;
        }
        String sql = "UPDATE cafe SET status = ?, updated_at = SYSTIMESTAMP WHERE cafe_id = ? AND status <> 'DELETED'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, cafeId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCafeStatusByAdmin(int cafeId, String status, String adminId, String adminMemo) {
        if (!"ACTIVE".equals(status) && !"HIDDEN".equals(status)) {
            return false;
        }
        if (adminId == null || adminId.trim().isEmpty() || adminMemo == null || adminMemo.trim().isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            AdminCommunityActionLogDAO logDao = new AdminCommunityActionLogDAO();
            if (!logDao.hasLogTable(conn)) {
                conn.rollback();
                return false;
            }

            String currentStatus = null;
            String selectSql = "SELECT status FROM cafe WHERE cafe_id = ? AND status <> 'DELETED'";
            try (PreparedStatement pstmt = conn.prepareStatement(selectSql)) {
                pstmt.setInt(1, cafeId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        currentStatus = rs.getString("status");
                    }
                }
            }
            if (currentStatus == null || status.equals(currentStatus)) {
                conn.rollback();
                return false;
            }

            String updateSql = "UPDATE cafe SET status = ?, updated_at = SYSTIMESTAMP "
                    + "WHERE cafe_id = ? AND status <> 'DELETED'";
            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setString(1, status);
                pstmt.setInt(2, cafeId);
                if (pstmt.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            String actionType = "HIDDEN".equals(status) ? "HIDE_CAFE" : "RESTORE_CAFE";
            if (!logDao.insertLog(conn, adminId, "CAFE", cafeId, actionType, adminMemo)) {
                conn.rollback();
                return false;
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

    public boolean updateCafeSettings(CafeDTO cafe) {
        String sql = "UPDATE cafe SET description = ?, region = ?, "
                + "category = (SELECT category_name FROM cafe_category WHERE cafe_category_id = ?), "
                + "cafe_category_id = ?, visibility = ?, join_type = ?, "
                + "updated_at = SYSTIMESTAMP WHERE cafe_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, cafe.getDescription());
            pstmt.setString(2, cafe.getRegion());
            pstmt.setInt(3, cafe.getCafeCategoryId());
            pstmt.setInt(4, cafe.getCafeCategoryId());
            pstmt.setString(5, cafe.getVisibility());
            pstmt.setString(6, cafe.getJoinType());
            pstmt.setInt(7, cafe.getCafeId());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void increaseViewCount(int cafeId) {
        String sql = "UPDATE cafe SET view_count = view_count + 1 WHERE cafe_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean insertCafe(Connection conn, int cafeId, CafeDTO cafe) throws Exception {
        String sql = "INSERT INTO cafe "
                + "(cafe_id, cafe_name, description, image_path, region, category, cafe_category_id, visibility, join_type, owner_id) "
                + "VALUES (?, ?, ?, ?, ?, (SELECT category_name FROM cafe_category WHERE cafe_category_id = ?), ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, cafe.getCafeName());
            pstmt.setString(3, cafe.getDescription());
            pstmt.setString(4, cafe.getImagePath());
            pstmt.setString(5, cafe.getRegion());
            pstmt.setInt(6, cafe.getCafeCategoryId());
            pstmt.setInt(7, cafe.getCafeCategoryId());
            pstmt.setString(8, cafe.getVisibility());
            pstmt.setString(9, cafe.getJoinType());
            pstmt.setString(10, cafe.getOwnerId());
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean insertCafeMember(Connection conn, int cafeId, String memberId, String role, String status) throws Exception {
        String sql = "INSERT INTO cafe_member "
                + "(cafe_member_id, cafe_id, member_id, role, status) "
                + "VALUES (seq_cafe_member.NEXTVAL, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            pstmt.setString(3, role);
            pstmt.setString(4, status);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean insertCafeBoard(Connection conn, int cafeId, String boardName, String description,
            String readPermission, String writePermission, String isNotice, int displayOrder) throws Exception {
        String sql = "INSERT INTO cafe_board "
                + "(board_id, cafe_id, board_name, description, read_permission, write_permission, is_notice, display_order) "
                + "VALUES (seq_cafe_board.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, boardName);
            pstmt.setString(3, description);
            pstmt.setString(4, readPermission);
            pstmt.setString(5, writePermission);
            pstmt.setString(6, isNotice);
            pstmt.setInt(7, displayOrder);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean updateCafeMemberCount(Connection conn, int cafeId, int amount) throws Exception {
        String sql = "UPDATE cafe SET member_count = GREATEST(member_count + ?, 0) WHERE cafe_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, cafeId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private int nextVal(Connection conn, String sequenceName) throws Exception {
        try (PreparedStatement pstmt = conn.prepareStatement("SELECT " + sequenceName + ".NEXTVAL FROM dual");
             ResultSet rs = pstmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private void appendAdminCafeWhere(StringBuilder sql, List<Object> params, AdminCafeFilter filter) {
        String keyword = cleanText(filter == null ? null : filter.getKeyword());
        if (keyword != null) {
            String searchType = cleanOption(filter == null ? null : filter.getSearchType());
            String value = "%" + keyword.toLowerCase() + "%";
            if ("OWNER".equals(searchType)) {
                sql.append("AND LOWER(c.owner_id) LIKE ? ");
                params.add(value);
            } else {
                sql.append("AND LOWER(c.cafe_name) LIKE ? ");
                params.add(value);
            }
        }

        String status = cleanOption(filter == null ? null : filter.getStatus());
        if ("ACTIVE".equals(status) || "HIDDEN".equals(status)) {
            sql.append("AND c.status = ? ");
            params.add(status);
        }

        String region = cleanText(filter == null ? null : filter.getRegion());
        if (region != null) {
            sql.append("AND c.region LIKE ? ");
            params.add("%" + region + "%");
        }

        int cafeCategoryId = filter == null ? 0 : filter.getCafeCategoryId();
        if (cafeCategoryId > 0) {
            sql.append("AND c.cafe_category_id = ? ");
            params.add(cafeCategoryId);
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

    private String cleanText(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String cleanOption(String value) {
        String trimmed = cleanText(value);
        return trimmed == null || "ALL".equalsIgnoreCase(trimmed) ? null : trimmed.toUpperCase();
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

    private CafeDTO mapCafe(ResultSet rs) throws Exception {
        Timestamp lastActiveAt = rs.getTimestamp("last_active_at");
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        String categoryName = getOptionalString(rs, "cafe_category_name");
        if (categoryName == null || categoryName.trim().isEmpty()) {
            categoryName = rs.getString("category");
        }

        return CafeDTO.builder()
                .cafeId(rs.getInt("cafe_id"))
                .cafeName(rs.getString("cafe_name"))
                .description(rs.getString("description"))
                .imagePath(rs.getString("image_path"))
                .region(rs.getString("region"))
                .cafeCategoryId(rs.getInt("cafe_category_id"))
                .category(categoryName)
                .categoryName(categoryName)
                .visibility(rs.getString("visibility"))
                .joinType(rs.getString("join_type"))
                .ownerId(rs.getString("owner_id"))
                .status(rs.getString("status"))
                .memberCount(rs.getInt("member_count"))
                .postCount(rs.getInt("post_count"))
                .viewCount(rs.getInt("view_count"))
                .lastActiveAt(lastActiveAt == null ? null : lastActiveAt.toLocalDateTime())
                .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
                .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
                .ownerNickname(rs.getString("owner_nickname"))
                .build();
    }

    private String getOptionalString(ResultSet rs, String columnName) throws SQLException {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }
}
