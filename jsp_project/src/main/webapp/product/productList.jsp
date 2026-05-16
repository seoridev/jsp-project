<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%!
    private Integer parseCategoryId(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String productStatusText(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) {
            return "예약중";
        }
        if ("SOLD".equalsIgnoreCase(status)) {
            return "거래완료";
        }
        if ("HIDDEN".equalsIgnoreCase(status)) {
            return "숨김";
        }
        return "판매중";
    }

    private String productStatusClass(String status) {
        if ("RESERVED".equalsIgnoreCase(status)) {
            return "product-status-reserved";
        }
        if ("SOLD".equalsIgnoreCase(status)) {
            return "product-status-sold";
        }
        if ("HIDDEN".equalsIgnoreCase(status)) {
            return "product-status-hidden";
        }
        return "product-status-sale";
    }
%>
<%
    String type = request.getParameter("type");
    String keyword = request.getParameter("keyword");
    String region = request.getParameter("region");
    Integer categoryId = parseCategoryId(request.getParameter("categoryId"));

    ProductDAO productDAO = new ProductDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    List<ProductDTO> products = productDAO.searchProducts(type, keyword, categoryId, region);
    List<CategoryDTO> categories = categoryDAO.selectAllCategories();
    DecimalFormat priceFormat = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 목록 - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/product.css?v=external-ui-1">
</head>
<body class="product-page">
<%@ include file="../common/header.jsp" %>
<main class="product-container">
    <div class="product-title-row">
        <h2>중고거래 물품 목록</h2>
        <% if (loggedIn) { %>
            <a class="product-btn-write" href="<%= contextPath %>/product/productWrite.jsp">+ 물품 등록하기</a>
        <% } else { %>
            <a class="product-btn-write" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 등록</a>
        <% } %>
    </div>

    <div class="product-search-bar">
        <form class="product-search-form" action="<%= contextPath %>/product/productList.jsp" method="get">
            <select name="type" aria-label="검색 범위">
                <option value="all" <%= type == null || "all".equals(type) ? "selected" : "" %>>제목+내용</option>
                <option value="title" <%= "title".equals(type) ? "selected" : "" %>>제목</option>
                <option value="content" <%= "content".equals(type) ? "selected" : "" %>>내용</option>
            </select>
            <input type="text" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="검색어">
            <select name="categoryId" aria-label="카테고리">
                <option value="">전체 카테고리</option>
                <% for (CategoryDTO category : categories) { %>
                    <option value="<%= category.getCategoryId() %>" <%= categoryId != null && categoryId == category.getCategoryId() ? "selected" : "" %>>
                        <%= escapeHtml(category.getCategoryName()) %>
                    </option>
                <% } %>
            </select>
            <input type="text" name="region" value="<%= escapeHtml(region) %>" placeholder="지역">
            <button type="submit" class="product-btn-search">검색</button>
            <a class="product-reset-link" href="<%= contextPath %>/product/productList.jsp">초기화</a>
        </form>
    </div>

    <div class="product-list-meta">
        <span>총 <strong><%= products.size() %></strong>개 상품</span>
    </div>

    <div class="product-table-wrap">
        <table class="product-table">
            <thead>
                <tr>
                    <th>제목</th>
                    <th>가격</th>
                    <th>지역</th>
                    <th>카테고리</th>
                    <th>상태</th>
                    <th>조회수</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr>
                        <td class="product-empty" colspan="6">등록된 물품이 없습니다.</td>
                    </tr>
                <% } else {
                    for (ProductDTO product : products) {
                %>
                    <tr>
                        <td>
                            <a href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>">
                                <%= escapeHtml(product.getTitle()) %>
                            </a>
                        </td>
                        <td class="product-price"><%= priceFormat.format(product.getPrice()) %>원</td>
                        <td class="product-region"><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= escapeHtml(product.getCategoryName()) %></td>
                        <td>
                            <span class="product-status-badge <%= productStatusClass(product.getStatus()) %>">
                                <%= productStatusText(product.getStatus()) %>
                            </span>
                        </td>
                        <td><%= product.getViewCount() %></td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
