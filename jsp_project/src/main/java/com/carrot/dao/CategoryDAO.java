package com.carrot.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.CategoryDTO;

public class CategoryDAO extends BaseDAO{

	// 카테고리 조회
	public List<CategoryDTO> selectAllCategories() {
	    List<CategoryDTO> list = new ArrayList<>();
	    
	    String sql = "SELECT * FROM CATEGORY WHERE IS_ACTIVE = 'Y' ORDER BY CATEGORY_ID ASC";
	    
		try (Connection conn = getConnection();
				PreparedStatement pstmt = conn.prepareStatement(sql);
				ResultSet rs = pstmt.executeQuery()) {
			
	        while(rs.next()) {
	            CategoryDTO dto = CategoryDTO.builder()
	            .categoryId(rs.getInt("CATEGORY_ID"))
	            .categoryName(rs.getString("CATEGORY_NAME"))
	            .isActive(rs.getString("IS_ACTIVE"))
	            .build();
	            list.add(dto);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return list;
	}
	
	// 카테고리 이름 조회
	// 추가됨: 정상 메서드명으로 카테고리 이름 조회
	public String selectCategoryName(int id) {
	    String sql = "SELECT CATEGORY_NAME FROM CATEGORY WHERE IS_ACTIVE = 'Y' AND CATEGORY_ID = ?";

	    try (Connection conn = getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {

	        pstmt.setInt(1, id);

	        try (ResultSet rs = pstmt.executeQuery()) {
	            if (rs.next()) {
	                return rs.getString("CATEGORY_NAME");
	            }
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return null;
	}
	
	// 추가됨: 기존 오타 메서드는 호환용으로 유지하고 새 메서드에 위임
	public String selectCategorieName(int id) {
	    return selectCategoryName(id);
	}

}
