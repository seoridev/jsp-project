package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.FavoriteDTO;
import com.carrot.dto.ProductDTO;

// 관심 상품 등록, 해제, 목록 조회 DAO
public class FavoriteDAO extends BaseDAO {

    public boolean isFavorite(String memberId, long productId) {
        String sql = "SELECT COUNT(*) FROM favorite WHERE member_id = ? AND product_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setLong(2, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean insertFavorite(String memberId, long productId) {
        String sql = "INSERT INTO favorite (favorite_id, member_id, product_id, created_at) "
            + "VALUES (seq_favorite.NEXTVAL, ?, ?, SYSTIMESTAMP)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setLong(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteFavorite(String memberId, long productId) {
        String sql = "DELETE FROM favorite WHERE member_id = ? AND product_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setLong(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public String toggleFavorite(String memberId, long productId) {
        if (isFavorite(memberId, productId)) {
            return deleteFavorite(memberId, productId) ? "delete" : "fail";
        }

        return insertFavorite(memberId, productId) ? "insert" : "fail";
    }

    public int countFavoritesByMemberId(String memberId) {
        String sql = "SELECT COUNT(*) FROM favorite f "
            + "JOIN product p ON f.product_id = p.product_id "
            + "WHERE f.member_id = ? AND p.is_deleted = 'N' AND NVL(p.status, 'SALE') <> 'HIDDEN'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countFavoritesByProductId(long productId) {
        String sql = "SELECT COUNT(*) FROM favorite WHERE product_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<ProductDTO> getFavoriteProductsByMemberId(String memberId) {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.content, p.price, "
            + "p.region, p.status, p.view_count, p.is_deleted, p.created_at, p.updated_at, "
            + "c.category_name, m.nickname AS seller_nickname, "
            + "(SELECT pi.image_path || pi.save_name FROM product_image pi "
            + "WHERE pi.product_id = p.product_id "
            + "ORDER BY CASE WHEN pi.is_main = 'Y' THEN 0 ELSE 1 END, pi.image_id ASC "
            + "FETCH FIRST 1 ROWS ONLY) AS main_image_path "
            + "FROM favorite f "
            + "JOIN product p ON f.product_id = p.product_id "
            + "LEFT JOIN category c ON p.category_id = c.category_id "
            + "LEFT JOIN member m ON p.seller_id = m.login_id "
            + "WHERE f.member_id = ? AND p.is_deleted = 'N' AND NVL(p.status, 'SALE') <> 'HIDDEN' "
            + "ORDER BY f.created_at DESC, f.favorite_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    private ProductDTO mapProduct(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");
        Timestamp updatedAt = getOptionalTimestamp(rs, "updated_at");

        return ProductDTO.builder()
            .productId(rs.getInt("product_id"))
            .sellerId(rs.getString("seller_id"))
            .categoryId(rs.getInt("category_id"))
            .title(rs.getString("title"))
            .content(rs.getString("content"))
            .price(rs.getInt("price"))
            .region(rs.getString("region"))
            .status(rs.getString("status"))
            .viewCount(rs.getInt("view_count"))
            .isDeleted(rs.getString("is_deleted"))
            .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
            .updatedAt(updatedAt == null ? null : updatedAt.toLocalDateTime())
            .categoryName(getOptionalString(rs, "category_name"))
            .sellerNickname(getOptionalString(rs, "seller_nickname"))
            .mainImagePath(getOptionalString(rs, "main_image_path"))
            .build();
    }

    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (Exception e) {
            return null;
        }
    }

    private Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (Exception e) {
            return null;
        }
    }
}
