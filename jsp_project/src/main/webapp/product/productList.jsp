<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>

<%
	String type = request.getParameter("type");
	String keyword = request.getParameter("keyword");
	String categoryIdParam = request.getParameter("categoryId");
	Integer categoryId = null;

    // 추가됨: categoryId 파라미터를 숫자로 안전하게 변환
	if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
	    try {
	        categoryId = Integer.parseInt(categoryIdParam);
	    } catch (NumberFormatException e) {
	        categoryId = null;
	    }
	}

    ProductDAO dao = new ProductDAO();
    CategoryDAO categoryDao = new CategoryDAO();
    List<CategoryDTO> categoryList = categoryDao.selectAllCategories();
    String selectedCategoryName = null;

    // 추가됨: 존재하는 활성 카테고리일 때만 categoryId 필터 적용
    if (categoryId != null) {
        selectedCategoryName = categoryDao.selectCategoryName(categoryId);
        if (selectedCategoryName == null) {
            categoryId = null;
        }
    }

    // 추가됨: 카테고리와 검색어를 함께 적용해 상품 조회
    List<ProductDTO> list = dao.selectProductList(type, keyword, categoryId);
    String displayType = (type == null || type.trim().isEmpty()) ? "all" : type;
    // 추가됨: 잘못된 검색 type은 화면과 링크에서 전체 검색으로 처리
    if (!"title".equals(displayType) && !"content".equals(displayType) && !"all".equals(displayType)) {
        displayType = "all";
    }
    String displayKeyword = keyword == null ? "" : keyword.trim();
    String encodedKeyword = URLEncoder.encode(displayKeyword, "UTF-8");
    int productCount = list == null ? 0 : list.size();
    
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>물품 목록 | 동네 마켓</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>    
    /* 카테고리 필터 칩 스타일링 */
    .category-filter {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 24px;
    }
    .category-filter a {
        display: inline-flex;
        align-items: center;
        min-height: 34px;
        padding: 0 14px;
        border: 1px solid #ded6ca;
        border-radius: 999px;
        background: #fffaf3;
        color: #5f574f;
        font-size: 13px;
        font-weight: 700;
        transition: all 0.2s;
    }
    .category-filter a:hover {
        border-color: #ffb27a;
        color: #d95c00;
    }
    .category-filter a.active {
        border-color: #ff6f0f;
        background: #ff6f0f;
        color: #fff;
    }
    
    /* 검색바 레이아웃 보정 */
    .product-search-wrapper {
        margin-bottom: 32px;
    }
    .product-search-wrapper .inline-form {
        width: 100%;
        max-width: 600px;
    }
    .product-search-wrapper select {
        min-width: 100px;
    }
    .product-search-wrapper input[type="text"] {
        flex: 1;
        min-height: 38px;
        border: 1px solid #d7d0c5;
        border-radius: 8px;
        padding: 0 12px;
        background: #fffdf9;
        font-size: 14px;
    }
    .product-search-wrapper input[type="text"]:focus {
        outline: 3px solid rgba(255, 111, 15, 0.18);
        border-color: #ff6f0f;
    }
    .search-reset-link {
        font-size: 13px;
        color: #756b61;
        font-weight: 700;
        margin-left: 4px;
    }
    .search-reset-link:hover {
        color: #202124;
        text-decoration: underline;
    }
    
    /* 테이블 내 강조 스타일 */
    .price {
        font-weight: 800;
        color: #ff6f0f;
    }
    .region {
        color: #756b61;
    }
    
    /* 하단 글쓰기 버튼 영역 */
    .admin-actions.list-actions {
        margin-top: 24px;
    }
    
	.admin-list-meta {
	    display: flex;
	    align-items: center;
	    justify-content: flex-start;
	    gap: 8px;
	    margin: 8px 0 16px;
	    color: #6d645b;
	    font-size: 14px;
	    font-weight: 700;
	    
	    letter-spacing: -0.03em !important; 
	}
	
	.admin-list-meta strong {
	    color: #202124;
	    font-weight: 800;
	    letter-spacing: -0.04em !important; /* 숫자는 조금 더 촘촘하게 */
	}
	
	.admin-list-meta span {
	    font-weight: normal;
	    color: #756b61;
	    margin-left: 4px;
	    letter-spacing: -0.02em !important;
	}
</style>
</head>
<%@ include file="../common/header.jsp" %>

    <div class="admin-shell">
        
        <div class="admin-heading">
            <div>
                <h1 style="font-weight: 900; color: #202124;">🥕 중고거래 물품 목록</h1>
                <p class="admin-list-meta" style="margin-top: 8px; margin-bottom: 0;">
                    현재 카테고리: <strong><%= selectedCategoryName != null ? selectedCategoryName : "전체" %></strong>
                    (총 <strong><%= productCount %></strong>개 관련 상품)
                    <% if (!displayKeyword.isEmpty()) { %>
                        <span style="font-weight: normal; color: #756b61; margin-left: 6px;">/ 검색어: "<%= displayKeyword %>"</span>
                    <% } %>
                </p>
            </div>
        </div>

        <div class="category-filter">
            <a class="<%= categoryId == null ? "active" : "" %>"
               href="productList.jsp<%= !displayKeyword.isEmpty() ? "?type=" + displayType + "&keyword=" + encodedKeyword : "" %>">전체</a>
            <% for (CategoryDTO category : categoryList) {
                String categoryUrl = "productList.jsp?categoryId=" + category.getCategoryId();
                if (!displayKeyword.isEmpty()) {
                    categoryUrl += "&type=" + displayType + "&keyword=" + encodedKeyword;
                }
            %>
                <a class="<%= categoryId != null && categoryId == category.getCategoryId() ? "active" : "" %>"
                   href="<%= categoryUrl %>"><%= category.getCategoryName() %></a>
            <% } %>
        </div>

        <div class="product-search-wrapper">
            <form action="productList.jsp" method="get" class="inline-form">
                <% if (categoryId != null) { %>
                <input type="hidden" name="categoryId" value="<%= categoryId %>">
                <% } %>
                <select name="type">
                    <option value="all" <%= "all".equals(displayType) ? "selected" : "" %>>제목+내용</option>
                    <option value="title" <%= "title".equals(displayType) ? "selected" : "" %>>제목</option>
                    <option value="content" <%= "content".equals(displayType) ? "selected" : "" %>>내용</option>
                </select> 
                <input type="text" name="keyword" value="<%= displayKeyword %>" placeholder="필요한 물품을 검색해보세요.">
                <button type="submit" class="primary">검색</button>

                <% if(!displayKeyword.isEmpty() || categoryId != null) { %>
                <a href="productList.jsp" class="search-reset-link">초기화</a>
                <% } %>
            </form>
        </div>

        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th style="width: auto;">제목</th>
                        <th style="width: 160px;">가격</th>
                        <th style="width: 160px;">지역</th>
                        <th style="width: 100px;">조회수</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (list == null || list.isEmpty()) { %>
                    <tr>
                        <td colspan="4" class="empty-cell">등록된 물품이 없습니다. 첫 물품의 주인공이 되어보세요!</td>
                    </tr>
                    <% } else {
                        for (ProductDTO p : list) {
                    %>
                    <tr>
                        <td>
                            <a href="productDetail.jsp?id=<%= p.getProductId() %>" class="table-link"><%= p.getTitle() %></a>
                        </td>
                        <td class="price"><%= df.format(p.getPrice()) %>원</td>
                        <td class="region"><%= p.getRegion() %></td>
                        <td><span class="status-badge"><%= p.getViewCount() %></span></td>
                    </tr>
                    <% 
                        }
                    } 
                    %>
                </tbody>
            </table>
        </div>
        
        <div class="admin-actions list-actions">
            <a href="productWrite.jsp" class="button primary" style="min-height: 46px; padding: 0 24px; border-radius: 999px; font-size: 15px;">
                <span style="margin-right: 6px; font-size: 18px; font-weight: 900;">+</span> 물품 등록하기
            </a>
        </div>
        
    </div>

<%@ include file="../common/footer.jsp" %>
</body>
</html>
