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
        return "판매중";
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
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <section class="admin-heading">
        <div>
            <p class="eyebrow">우리 동네 중고거래</p>
            <h1>상품 목록</h1>
        </div>
        <div class="admin-actions">
            <% if (loggedIn) { %>
                <a class="button primary" href="<%= contextPath %>/product/productWrite.jsp">상품 등록</a>
            <% } else { %>
                <a class="button primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 등록</a>
            <% } %>
        </div>
    </section>

    <form class="admin-filter" action="<%= contextPath %>/product/productList.jsp" method="get">
        <div class="field">
            <label for="type">검색 범위</label>
            <select id="type" name="type">
                <option value="all" <%= type == null || "all".equals(type) ? "selected" : "" %>>제목+내용</option>
                <option value="title" <%= "title".equals(type) ? "selected" : "" %>>제목</option>
                <option value="content" <%= "content".equals(type) ? "selected" : "" %>>내용</option>
            </select>
        </div>
        <div class="field">
            <label for="keyword">검색어</label>
            <input id="keyword" name="keyword" value="<%= escapeHtml(keyword) %>" placeholder="찾고 싶은 상품">
        </div>
        <div class="field">
            <label for="categoryId">카테고리</label>
            <select id="categoryId" name="categoryId">
                <option value="">전체</option>
                <% for (CategoryDTO category : categories) { %>
                    <option value="<%= category.getCategoryId() %>" <%= categoryId != null && categoryId == category.getCategoryId() ? "selected" : "" %>>
                        <%= escapeHtml(category.getCategoryName()) %>
                    </option>
                <% } %>
            </select>
        </div>
        <div class="field">
            <label for="region">지역</label>
            <input id="region" name="region" value="<%= escapeHtml(region) %>" placeholder="예: 강남구">
        </div>
        <button class="primary" type="submit">검색</button>
    </form>

    <div class="admin-list-meta">
        <span>총 <strong><%= products.size() %></strong>개 상품</span>
        <a class="table-link" href="<%= contextPath %>/product/productList.jsp">조건 초기화</a>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>상품명</th>
                    <th>가격</th>
                    <th>지역</th>
                    <th>카테고리</th>
                    <th>상태</th>
                    <th>조회수</th>
                </tr>
            </thead>
            <tbody>
                <% if (products.isEmpty()) { %>
                    <tr>
                        <td class="empty-cell" colspan="6">등록된 상품이 없습니다.</td>
                    </tr>
                <% } else {
                    for (ProductDTO product : products) {
                %>
                    <tr>
                        <td>
                            <a class="table-link" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>">
                                <%= escapeHtml(product.getTitle()) %>
                            </a>
                        </td>
                        <td><strong><%= priceFormat.format(product.getPrice()) %>원</strong></td>
                        <td><%= escapeHtml(product.getRegion()) %></td>
                        <td><%= escapeHtml(product.getCategoryName()) %></td>
                        <td><span class="status-badge"><%= productStatusText(product.getStatus()) %></span></td>
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
