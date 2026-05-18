package DAO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import DTO.ProductImageDTO;

public class ProductImageDAO extends BaseDAO{

	// 이미지 등록
	public int insertProductImage(ProductImageDTO image) {
		String sql = "INSERT INTO PRODUCT_IMAGE (IMAGE_ID, PRODUCT_ID, ORIGIN_NAME, SAVE_NAME, IMAGE_PATH, IS_MAIN, CREATED_AT) "
				+ "VALUES (SEQ_IMAGE.NEXTVAL, ?, ?, ?, ?, ?, SYSTIMESTAMP)";
		int result = 0;
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setLong(1, image.getProductId());
			pstmt.setString(2, image.getOriginName());
			pstmt.setString(3, image.getSaveName());
			pstmt.setString(4, image.getImagePath());
			pstmt.setString(5, image.getIsMain());

			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	// 이미지 삭제
	public int deleteImagesByProductId(long productId) {
	    String sql = "DELETE FROM PRODUCT_IMAGE WHERE PRODUCT_ID = ?";
	    
		int result = 0;
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        pstmt.setLong(1, productId);
	        
			result = pstmt.executeUpdate();
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
		
		return result;
	}
	
	// 이미지 가져오기
	public List<ProductImageDTO> selectImagesByProductId(long productId) {
	    List<ProductImageDTO> list = new ArrayList<>();
	    String sql = "SELECT * FROM PRODUCT_IMAGE WHERE PRODUCT_ID = ? ORDER BY IS_MAIN DESC, IMAGE_ID ASC";
	    
	    try (Connection conn = getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        pstmt.setLong(1, productId);
	        try (ResultSet rs = pstmt.executeQuery()) {
	            while (rs.next()) {
	                ProductImageDTO img = ProductImageDTO.builder()
	                    .imageId(rs.getInt("IMAGE_ID"))
	                    .productId(rs.getInt("PRODUCT_ID"))
	                    .originName(rs.getString("ORIGIN_NAME"))
	                    .saveName(rs.getString("SAVE_NAME"))
	                    .imagePath(rs.getString("IMAGE_PATH"))
	                    .isMain(rs.getString("IS_MAIN"))
	                    .build();
	                list.add(img);
	            }
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return list;
	}
	
	
}