package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeDTO;

public class CafeFavoriteDAO extends BaseDAO {

    public boolean existsFavorite(int cafeId, String memberId) {
        String sql = "SELECT 1 FROM cafe_favorite WHERE cafe_id = ? AND member_id = ?";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleFavorite(int cafeId, String memberId) {
        if (existsFavorite(cafeId, memberId)) {
            String sql = "DELETE FROM cafe_favorite WHERE cafe_id = ? AND member_id = ?";
            try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, cafeId);
                pstmt.setString(2, memberId);
                return pstmt.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        String sql = "INSERT INTO cafe_favorite (favorite_id, cafe_id, member_id) "
                + "VALUES (seq_cafe_favorite.NEXTVAL, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeId);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CafeDTO> selectFavoriteCafes(String memberId) {
        List<CafeDTO> cafes = new ArrayList<>();
        String sql = "SELECT c.*, m.nickname AS owner_nickname "
                + "FROM cafe_favorite cf "
                + "JOIN cafe c ON cf.cafe_id = c.cafe_id "
                + "LEFT JOIN member m ON c.owner_id = m.login_id "
                + "WHERE cf.member_id = ? AND c.status = 'ACTIVE' "
                + "ORDER BY cf.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    cafes.add(mapCafe(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cafes;
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
