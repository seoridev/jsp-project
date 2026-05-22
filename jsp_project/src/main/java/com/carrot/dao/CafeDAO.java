package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeDTO;

public class CafeDAO extends BaseDAO {

    public int insertCafe(CafeDTO cafe) {
        String sql = "INSERT INTO cafe "
                + "(cafe_id, cafe_name, description, image_path, region, category, visibility, join_type, owner_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            int cafeId = nextVal(conn, "seq_cafe");
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, cafe.getCafeName());
                pstmt.setString(3, cafe.getDescription());
                pstmt.setString(4, cafe.getImagePath());
                pstmt.setString(5, cafe.getRegion());
                pstmt.setString(6, cafe.getCategory());
                pstmt.setString(7, cafe.getVisibility());
                pstmt.setString(8, cafe.getJoinType());
                pstmt.setString(9, cafe.getOwnerId());
                return pstmt.executeUpdate() > 0 ? cafeId : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean isDuplicateCafeName(String cafeName) {
        String sql = "SELECT COUNT(*) FROM cafe WHERE cafe_name = ? AND status <> 'DELETED'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, cafeName);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    public CafeDTO selectCafeById(int cafeId) {
        String sql = "SELECT c.*, m.nickname AS owner_nickname "
                + "FROM cafe c LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE c.cafe_id = ? AND c.status <> 'DELETED'";

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
        List<CafeDTO> list = new ArrayList<>();
        List<String> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT c.*, m.nickname AS owner_nickname "
                + "FROM cafe c LEFT JOIN member m ON c.owner_id = m.login_id "
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
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND c.category = ?");
            params.add(category.trim());
        }

        if ("popular".equals(sort)) {
            sql.append(" ORDER BY c.member_count DESC, c.post_count DESC, c.created_at DESC");
        } else {
            sql.append(" ORDER BY c.created_at DESC");
        }
        sql.append(" FETCH FIRST ").append(Math.max(1, limit)).append(" ROWS ONLY");

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pstmt.setString(i + 1, params.get(i));
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

    public void increaseViewCount(int cafeId) {
        String sql = "UPDATE cafe SET view_count = view_count + 1 WHERE cafe_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int nextVal(Connection conn, String sequenceName) throws Exception {
        try (PreparedStatement pstmt = conn.prepareStatement("SELECT " + sequenceName + ".NEXTVAL FROM dual");
             ResultSet rs = pstmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private CafeDTO mapCafe(ResultSet rs) throws Exception {
        Timestamp lastActiveAt = rs.getTimestamp("last_active_at");
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = rs.getTimestamp("updated_at");

        return CafeDTO.builder()
                .cafeId(rs.getInt("cafe_id"))
                .cafeName(rs.getString("cafe_name"))
                .description(rs.getString("description"))
                .imagePath(rs.getString("image_path"))
                .region(rs.getString("region"))
                .category(rs.getString("category"))
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
}
