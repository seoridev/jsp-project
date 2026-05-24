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
<title>중고거래 마켓 - 물품 목록</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
<style>
    body { font-family: sans-serif; background: #f4f4f4; padding: 20px; }
    .container { max-width: 900px; margin: auto; background: white; padding: 20px; border-radius: 8px; }
    
    .search-bar {
        margin-bottom: 20px;
        display: flex;
        justify-content: flex-start;
        gap: 10px;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
    }
    .search-bar select, .search-bar input {
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }
    .search-bar input[type="text"] { width: 250px; }
    .btn-search {
        background: #666;
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-search:hover { background: #444; }
    /* 추가됨: 상품 목록 카테고리 필터 표시 */
    .list-summary {
        margin: 0 0 12px;
        color: #555;
        font-size: 14px;
        font-weight: 700;
    }
    .category-filter {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 16px;
    }
    .category-filter a {
        padding: 7px 12px;
        border: 1px solid #ddd;
        border-radius: 16px;
        color: #555;
        text-decoration: none;
        font-size: 13px;
        background: #fff;
    }
    .category-filter a.active {
        border-color: #ff5a5f;
        background: #ff5a5f;
        color: #fff;
        font-weight: 700;
    }
    
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 12px; border-bottom: 1px solid #ddd; text-align: left; }
    th { background: #f8f9fa; }
    .price { font-weight: bold; color: #ff5a5f; }
    .region { color: #666; font-size: 0.9em; }
    .button-container {
    margin-top: 30px;
    display: flex;
    justify-content: flex-end; /* 오른쪽 정렬 */
	}
	
	.btn-write {
	    display: inline-block;
	    background-color: #ff5a5f; /* 강조 포인트 색상 */
	    color: white;
	    padding: 12px 24px;
	    border-radius: 30px; /* 둥근 버튼 */
	    text-decoration: none;
	    font-weight: bold;
	    font-size: 16px;
	    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
	    transition: background-color 0.3s, transform 0.2s;
	}
	
	.btn-write:hover {
	    background-color: #e0484d;
	    transform: translateY(-2px); /* 살짝 떠오르는 효과 */
	    color: white;
	}
	
	.btn-write .icon {
	    margin-right: 5px;
	    font-size: 18px;
	    vertical-align: middle;
	}
</style>
</head>
<body>
<%@ include file="../common/header.jsp" %>
	<div class="container">
		<h2>🥕 중고거래 물품 목록</h2>

		<%-- 추가됨: 현재 목록 기준과 상품 개수 표시 --%>
		<p class="list-summary">
			<%= selectedCategoryName != null ? selectedCategoryName : "전체" %> 상품 <%= productCount %>개
			<% if (!displayKeyword.isEmpty()) { %>
				<span> / 검색어: <%= displayKeyword %></span>
			<% } %>
		</p>

		<%-- 추가됨: 목록 화면에서도 CATEGORY_ID 기준 카테고리 필터 제공 --%>
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

		<div class="search-bar">
			<form action="productList.jsp" method="get"
				style="display: flex; gap: 10px; width: 100%;">
				<%-- 추가됨: 검색 시 선택된 카테고리 유지 --%>
				<% if (categoryId != null) { %>
				<input type="hidden" name="categoryId" value="<%= categoryId %>">
				<% } %>
				<select name="type">
					<option value="title" <%= "title".equals(displayType) ? "selected" : "" %>>제목</option>
					<option value="content"
						<%= "content".equals(displayType) ? "selected" : "" %>>내용</option>
					<option value="all" <%= "all".equals(displayType) ? "selected" : "" %>>제목+내용</option>
				</select> <input type="text" name="keyword"
					value="<%= displayKeyword %>">
				<button type="submit" class="btn-search">검색</button>

				<% if(!displayKeyword.isEmpty() || categoryId != null) { %>
				<a href="productList.jsp"
					style="text-decoration: none; font-size: 12px; color: #999; align-self: center;">초기화</a>
				<% } %>
			</form>
		</div>

		<table>
			<thead>
				<tr>
					<th>제목</th>
					<th>가격</th>
					<th>지역</th>
					<th>조회수</th>
				</tr>
			</thead>
			<tbody>
				<%
	                if (list == null || list.isEmpty()) {
	            %>
				<tr>
					<td colspan="5" style="text-align: center;">등록된 물품이 없습니다.</td>
				</tr>
				<%
	                } else {
	                    for (ProductDTO p : list) {
	            %>
				<tr>
					<td><a href="productDetail.jsp?id=<%= p.getProductId() %>"><%= p.getTitle() %></a>
					</td>
					<td class="price"><%= df.format(p.getPrice()) %>원</td>
					<td class="region"><%= p.getRegion() %></td>
					<td><%= p.getViewCount() %></td>
				</tr>
				<%
	                    }
	                } 
	            %>
			</tbody>
		</table>
		<div class="button-container">
			<a href="productWrite.jsp" class="btn-write"> <span class="icon">+</span>
				물품 등록하기
			</a>
		</div>
	</div>
	<%@ include file="../common/footer.jsp" %>
</body>
</html>
