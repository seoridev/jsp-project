package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CafeCategoryDTO;

public class CafeCategoryDAO extends BaseDAO {

    public List<CafeCategoryDTO> selectActiveCategories() {
        List<CafeCategoryDTO> categories = new ArrayList<>();
        String sql = "SELECT cafe_category_id, category_name, sort_order, is_active "
                + "FROM cafe_category "
                + "WHERE is_active = 'Y' "
                + "ORDER BY sort_order ASC, cafe_category_id ASC";

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

    public boolean existsActiveCategory(int cafeCategoryId) {
        String sql = "SELECT 1 FROM cafe_category WHERE cafe_category_id = ? AND is_active = 'Y'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeCategoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String selectCategoryName(int cafeCategoryId) {
        String sql = "SELECT category_name FROM cafe_category WHERE cafe_category_id = ? AND is_active = 'Y'";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cafeCategoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("category_name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private CafeCategoryDTO mapCategory(ResultSet rs) throws Exception {
        return CafeCategoryDTO.builder()
                .cafeCategoryId(rs.getInt("cafe_category_id"))
                .categoryName(rs.getString("category_name"))
                .sortOrder(rs.getInt("sort_order"))
                .isActive(rs.getString("is_active"))
                .build();
    }
}
