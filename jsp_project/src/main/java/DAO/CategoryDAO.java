package DAO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import DTO.CategoryDTO;

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
	
}