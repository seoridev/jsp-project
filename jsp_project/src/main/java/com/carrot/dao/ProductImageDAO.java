package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ProductImageDTO;

// 상품 이미지 등록과 조회를 맡는 DAO
public class ProductImageDAO extends BaseDAO {
    // 상품 이미지 정보 저장
    public boolean insertProductImage(ProductImageDTO image) {
        String sql = "INSERT INTO product_image "
            + "(image_id, product_id, origin_name, save_name, image_path, is_main, created_at) "
            + "VALUES (seq_image.NEXTVAL, ?, ?, ?, ?, ?, SYSTIMESTAMP)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, image.getProductId());
            pstmt.setString(2, image.getOriginName());
            pstmt.setString(3, image.getSaveName());
            pstmt.setString(4, image.getImagePath());
            pstmt.setString(5, image.getIsMain());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 상품 번호에 해당하는 이미지 목록 조회
    public List<ProductImageDTO> selectImagesByProductId(long productId) {
        List<ProductImageDTO> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, origin_name, save_name, image_path, is_main, created_at "
            + "FROM product_image WHERE product_id = ? ORDER BY is_main DESC, image_id ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    images.add(mapImage(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return images;
    }

    // 대표 이미지 한 건 조회
    public ProductImageDTO getMainImageByProductId(long productId) {
        String sql = "SELECT image_id, product_id, origin_name, save_name, image_path, is_main, created_at "
            + "FROM product_image WHERE product_id = ? "
            + "ORDER BY CASE WHEN is_main = 'Y' THEN 0 ELSE 1 END, image_id ASC FETCH FIRST 1 ROWS ONLY";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapImage(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 상품 이미지 정보 삭제
    public boolean deleteImagesByProductId(long productId) {
        String sql = "DELETE FROM product_image WHERE product_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);
            return pstmt.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ResultSet을 이미지 DTO로 변환
    private ProductImageDTO mapImage(ResultSet rs) throws Exception {
        Timestamp createdAt = rs.getTimestamp("created_at");

        return ProductImageDTO.builder()
            .imageId(rs.getInt("image_id"))
            .productId(rs.getInt("product_id"))
            .originName(rs.getString("origin_name"))
            .saveName(rs.getString("save_name"))
            .imagePath(rs.getString("image_path"))
            .isMain(rs.getString("is_main"))
            .createdAt(createdAt == null ? null : createdAt.toLocalDateTime())
            .build();
    }
}
