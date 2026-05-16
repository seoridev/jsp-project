package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CategoryDTO;

// 상품 카테고리 조회와 관리 기능을 맡는 DAO
public class CategoryDAO extends BaseDAO {
    // 사용 중인 카테고리 목록 조회
    public List<CategoryDTO> selectAllCategories() {
        List<CategoryDTO> categories = new ArrayList<>();
        String sql = "SELECT category_id, category_name, is_active "
            + "FROM category WHERE is_active = 'Y' ORDER BY category_id ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                categories.add(mapCategory(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return categories;
    }

    // 카테고리 번호로 한 건 조회
    public CategoryDTO getCategoryById(int categoryId) {
        String sql = "SELECT category_id, category_name, is_active FROM category WHERE category_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapCategory(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ResultSet을 카테고리 DTO로 변환
    private CategoryDTO mapCategory(ResultSet rs) throws Exception {
        return CategoryDTO.builder()
            .categoryId(rs.getInt("category_id"))
            .categoryName(rs.getString("category_name"))
            .isActive(rs.getString("is_active"))
            .build();
    }
}
