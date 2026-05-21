package com.carrot.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ProductDTO;

public class ProductDAO extends BaseDAO{
	// 상품 등록
	public int insertProduct(ProductDTO product) {
		String sql = "INSERT INTO PRODUCT (PRODUCT_ID, SELLER_ID, CATEGORY_ID, TITLE, CONTENT, PRICE, REGION, STATUS, VIEW_COUNT, IS_DELETED, CREATED_AT) "
				+ "VALUES (SEQ_PRODUCT.NEXTVAL, ?, ?, ?, ?, ?, ?, 'SALE', 0, 'N', SYSTIMESTAMP)";

		int result = 0;

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, product.getSellerId());
			pstmt.setLong(2, product.getCategoryId());
			pstmt.setString(3, product.getTitle());
			pstmt.setString(4, product.getContent());
			pstmt.setLong(5, product.getPrice());
			pstmt.setString(6, product.getRegion());

			result = pstmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	// 상품 수정
	public int updateProduct(ProductDTO product) {
	    String sql = "UPDATE PRODUCT SET CATEGORY_ID = ?, TITLE = ?, CONTENT = ?, PRICE = ?, REGION = ? WHERE PRODUCT_ID = ?";
	    
		int result = 0;
	    
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        
	        pstmt.setLong(1, product.getCategoryId());
	        pstmt.setString(2, product.getTitle());
	        pstmt.setString(3, product.getContent());
	        pstmt.setLong(4, product.getPrice());
	        pstmt.setString(5, product.getRegion());
	        pstmt.setLong(6, product.getProductId());
	        
	        result = pstmt.executeUpdate();
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    
	    return result;
	}
	
	// 상품 삭제
	public int deleteProduct(long productId) {
		String sql = "DELETE FROM PRODUCT WHERE PRODUCT_ID = ?";
		int result = 0;

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setLong(1, productId);
			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	// 상품 검색
	public List<ProductDTO> selectProductList(String type, String keyword) {
	    List<ProductDTO> list = new ArrayList<>();
	    
	    StringBuilder sql = new StringBuilder("SELECT * FROM PRODUCT WHERE IS_DELETED = 'N'");
	    
	    // 검색 조건이 있을 경우 쿼리 추가
		if (keyword != null && !keyword.trim().isEmpty()) {
			sql.append(switch (type) {
			case "title" -> " AND TITLE LIKE ?";
			case "content" -> " AND CONTENT LIKE ?";
			case "all" -> " AND (TITLE LIKE ? OR CONTENT LIKE ?)";
			default -> "";
			});
	    }
	    sql.append(" ORDER BY CREATED_AT DESC");

	    try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
	        if (keyword != null && !keyword.trim().isEmpty()) {
	            String searchKeyword = "%" + keyword + "%";
	            pstmt.setString(1, searchKeyword);
	            if ("all".equals(type)) {
	                pstmt.setString(2, searchKeyword);
	            }
	        }

	        try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					ProductDTO product = ProductDTO.builder()
							.productId(rs.getInt("PRODUCT_ID"))
							.sellerId(rs.getString("SELLER_ID"))
							.categoryId(rs.getInt("CATEGORY_ID"))
							.title(rs.getString("TITLE"))
							.content(rs.getString("CONTENT"))
							.price(rs.getInt("PRICE"))
							.region(rs.getString("REGION"))
							.status(rs.getString("STATUS"))
							.viewCount(rs.getInt("VIEW_COUNT"))
							.isDeleted(rs.getString("IS_DELETED"))
							.createdAt(rs.getTimestamp("CREATED_AT").toLocalDateTime())
							.build();

					list.add(product);
				}
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return list;
	}
	
	// ID로 상품 조회
	public ProductDTO selectProductById(int id) {
		String sql = "SELECT * FROM PRODUCT WHERE PRODUCT_ID = ?";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return ProductDTO.builder()
							.productId(rs.getInt("PRODUCT_ID"))
							.sellerId(rs.getString("SELLER_ID"))
							.categoryId(rs.getInt("CATEGORY_ID"))
							.title(rs.getString("TITLE"))
							.content(rs.getString("CONTENT"))
							.price(rs.getInt("PRICE"))
							.region(rs.getString("REGION"))
							.status(rs.getString("STATUS"))
							.viewCount(rs.getInt("VIEW_COUNT"))
							.createdAt(rs.getTimestamp("CREATED_AT").toLocalDateTime())
							.build();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	// 마지막 상품 ID 가져오기
	public int selectLastProductId() {
	    String sql = "SELECT SEQ_PRODUCT.CURRVAL FROM DUAL";
	    try (Connection conn = getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql);
	         ResultSet rs = pstmt.executeQuery()) {
	        if (rs.next()) return rs.getInt(1);
	    } catch (Exception e) { e.printStackTrace(); }
	    return 0;
	}
	
	
	
}