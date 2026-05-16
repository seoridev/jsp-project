package com.carrot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.carrot.dto.ProductDTO;

// 상품 등록, 조회, 수정, 삭제 상태 처리를 맡는 DAO
public class ProductDAO extends BaseDAO {
    // ===== 회원 상품 화면 기능 =====

    // 상품 등록 후 생성된 상품 번호 반환
    public int insertProduct(ProductDTO product) {
        String sequenceSql = "SELECT seq_product.NEXTVAL FROM dual";
        String insertSql = "INSERT INTO product "
            + "(product_id, seller_id, category_id, title, content, price, region, status, view_count, is_deleted, created_at) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, 'SALE', 0, 'N', SYSTIMESTAMP)";

        try (Connection conn = getConnection()) {
            int productId = nextProductId(conn, sequenceSql);

            try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
                pstmt.setInt(1, productId);
                pstmt.setString(2, product.getSellerId());
                pstmt.setInt(3, product.getCategoryId());
                pstmt.setString(4, product.getTitle());
                pstmt.setString(5, product.getContent());
                pstmt.setInt(6, product.getPrice());
                pstmt.setString(7, product.getRegion());

                if (pstmt.executeUpdate() > 0) {
                    product.setProductId(productId);
                    return productId;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // 상품 목록 조회
    public List<ProductDTO> selectProductList(String type, String keyword) {
        return searchProducts(type, keyword, null, null);
    }

    // 검색어, 카테고리, 지역 조건으로 상품 조회
    public List<ProductDTO> searchProducts(String type, String keyword, Integer categoryId, String region) {
        List<ProductDTO> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.content, p.price, "
                + "p.region, p.status, p.view_count, p.is_deleted, p.created_at, p.updated_at, "
                + "c.category_name, m.nickname AS seller_nickname, "
                + "(SELECT pi.image_path || pi.save_name FROM product_image pi "
                + "WHERE pi.product_id = p.product_id "
                + "ORDER BY CASE WHEN pi.is_main = 'Y' THEN 0 ELSE 1 END, pi.image_id ASC "
                + "FETCH FIRST 1 ROWS ONLY) AS main_image_path "
                + "FROM product p "
                + "LEFT JOIN category c ON p.category_id = c.category_id "
                + "LEFT JOIN member m ON p.seller_id = m.login_id "
                + "WHERE p.is_deleted = 'N' AND NVL(p.status, 'SALE') <> 'HIDDEN'"
        );
        List<Object> params = new ArrayList<>();

        appendKeywordFilter(sql, params, type, keyword);
        appendCategoryFilter(sql, params, categoryId);
        appendRegionFilter(sql, params, region);
        sql.append(" ORDER BY p.created_at DESC NULLS LAST, p.product_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            bindParams(pstmt, params);

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

    // 상품 번호로 상세 정보 조회
    public ProductDTO selectProductById(long productId) {
        String sql = "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.content, p.price, "
            + "p.region, p.status, p.view_count, p.is_deleted, p.created_at, p.updated_at, "
            + "c.category_name, m.nickname AS seller_nickname, NULL AS main_image_path "
            + "FROM product p "
            + "LEFT JOIN category c ON p.category_id = c.category_id "
            + "LEFT JOIN member m ON p.seller_id = m.login_id "
            + "WHERE p.product_id = ? AND p.is_deleted = 'N'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 상품 수정
    public boolean updateProduct(ProductDTO product, String sellerId) {
        String sql = "UPDATE product SET category_id = ?, title = ?, content = ?, price = ?, "
            + "region = ?, updated_at = SYSTIMESTAMP "
            + "WHERE product_id = ? AND seller_id = ? AND is_deleted = 'N'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, product.getCategoryId());
            pstmt.setString(2, product.getTitle());
            pstmt.setString(3, product.getContent());
            pstmt.setInt(4, product.getPrice());
            pstmt.setString(5, product.getRegion());
            pstmt.setInt(6, product.getProductId());
            pstmt.setString(7, sellerId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 기존 외부 JSP 호환용 상품 수정
    public int updateProduct(ProductDTO product) {
        return updateProduct(product, product.getSellerId()) ? 1 : 0;
    }

    // 상품 삭제 상태 처리
    public boolean softDeleteProduct(long productId, String sellerId) {
        String sql = "UPDATE product SET is_deleted = 'Y', updated_at = SYSTIMESTAMP "
            + "WHERE product_id = ? AND seller_id = ? AND is_deleted = 'N'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);
            pstmt.setString(2, sellerId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 기존 외부 JSP 호환용 삭제 처리
    public int deleteProduct(long productId) {
        String sql = "UPDATE product SET is_deleted = 'Y', updated_at = SYSTIMESTAMP "
            + "WHERE product_id = ? AND is_deleted = 'N'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // 상품 조회수 증가
    public boolean increaseViewCount(long productId) {
        String sql = "UPDATE product SET view_count = NVL(view_count, 0) + 1 "
            + "WHERE product_id = ? AND is_deleted = 'N'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 특정 판매자가 등록한 상품 목록 조회
    public List<ProductDTO> getProductsBySellerId(String sellerId) {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.content, p.price, "
            + "p.region, p.status, p.view_count, p.is_deleted, p.created_at, p.updated_at, "
            + "c.category_name, NULL AS seller_nickname, NULL AS main_image_path "
            + "FROM product p LEFT JOIN category c ON p.category_id = c.category_id "
            + "WHERE p.seller_id = ? AND p.is_deleted = 'N' "
            + "ORDER BY p.created_at DESC NULLS LAST, p.product_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sellerId);

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

    // ===== 관리자 상품 화면 기능 =====

    // 관리자용 전체 상품 목록 조회
    public List<ProductDTO> getAllProductsForAdmin() {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.content, p.price, "
            + "p.region, p.status, p.view_count, p.is_deleted, p.created_at, p.updated_at, "
            + "c.category_name, m.nickname AS seller_nickname, NULL AS main_image_path "
            + "FROM product p "
            + "LEFT JOIN category c ON p.category_id = c.category_id "
            + "LEFT JOIN member m ON p.seller_id = m.login_id "
            + "ORDER BY p.created_at DESC NULLS LAST, p.product_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                products.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return products;
    }

    // 관리자 신고 처리 등에 사용할 상품 숨김 처리
    public boolean hideProduct(long productId) {
        String sql = "UPDATE product SET status = 'HIDDEN', updated_at = SYSTIMESTAMP WHERE product_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, productId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===== 공통 조회/매핑 =====

    // 상품 시퀀스 번호를 먼저 확보해서 이미지 저장과 같은 요청 흐름에서 재사용
    private int nextProductId(Connection conn, String sequenceSql) throws Exception {
        try (PreparedStatement pstmt = conn.prepareStatement(sequenceSql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        throw new IllegalStateException("상품 번호를 생성하지 못했습니다.");
    }

    // 검색어 조건 추가
    private void appendKeywordFilter(StringBuilder sql, List<Object> params, String type, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return;
        }

        String searchType = type == null ? "all" : type;
        String searchKeyword = "%" + keyword.trim().toLowerCase() + "%";

        if ("title".equals(searchType)) {
            sql.append(" AND LOWER(p.title) LIKE ?");
            params.add(searchKeyword);
        } else if ("content".equals(searchType)) {
            sql.append(" AND LOWER(p.content) LIKE ?");
            params.add(searchKeyword);
        } else {
            sql.append(" AND (LOWER(p.title) LIKE ? OR LOWER(p.content) LIKE ?)");
            params.add(searchKeyword);
            params.add(searchKeyword);
        }
    }

    // 카테고리 조건 추가
    private void appendCategoryFilter(StringBuilder sql, List<Object> params, Integer categoryId) {
        if (categoryId == null || categoryId <= 0) {
            return;
        }

        sql.append(" AND p.category_id = ?");
        params.add(categoryId);
    }

    // 지역 조건 추가
    private void appendRegionFilter(StringBuilder sql, List<Object> params, String region) {
        if (region == null || region.trim().isEmpty()) {
            return;
        }

        sql.append(" AND LOWER(p.region) LIKE ?");
        params.add("%" + region.trim().toLowerCase() + "%");
    }

    // PreparedStatement 파라미터 바인딩
    private void bindParams(PreparedStatement pstmt, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof Integer) {
                pstmt.setInt(i + 1, (Integer) param);
            } else {
                pstmt.setString(i + 1, String.valueOf(param));
            }
        }
    }

    // ResultSet을 상품 DTO로 변환
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

    // 선택 문자 컬럼 조회
    private String getOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (Exception e) {
            return null;
        }
    }

    // 선택 날짜 컬럼 조회
    private Timestamp getOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (Exception e) {
            return null;
        }
    }
}
