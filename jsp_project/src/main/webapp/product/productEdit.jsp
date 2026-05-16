<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dao.ProductImageDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
<%@ page import="com.carrot.dto.ProductImageDTO" %>
<%@ page import="java.util.List" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%!
    private long editProductId(String value) {
        try {
            return value == null ? 0 : Long.parseLong(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
%>
<%
    long productId = editProductId(request.getParameter("id"));
    ProductDAO productDAO = new ProductDAO();
    ProductDTO product = productId > 0 ? productDAO.selectProductById(productId) : null;
    String currentLoginId = (String) session.getAttribute("loginId");

    if (product == null || !currentLoginId.equals(product.getSellerId())) {
        response.sendRedirect(request.getContextPath() + "/product/productList.jsp?error=noPermission");
        return;
    }

    List<CategoryDTO> categories = new CategoryDAO().selectAllCategories();
    List<ProductImageDTO> images = new ProductImageDAO().selectImagesByProductId(productId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 수정 - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/product.css?v=external-ui-1">
</head>
<body class="product-page">
<%@ include file="../common/header.jsp" %>
<main class="product-form-container">
    <h2>물품 수정하기</h2>
    <form class="product-form" action="<%= contextPath %>/product/productEditProcess.jsp" method="post">
        <input type="hidden" name="productId" value="<%= product.getProductId() %>">

        <div class="product-form-group">
            <label for="categoryId">카테고리</label>
            <select id="categoryId" name="categoryId" required>
                <option value="">카테고리 선택</option>
                <% for (CategoryDTO category : categories) { %>
                    <option value="<%= category.getCategoryId() %>" <%= category.getCategoryId() == product.getCategoryId() ? "selected" : "" %>>
                        <%= escapeHtml(category.getCategoryName()) %>
                    </option>
                <% } %>
            </select>
        </div>

        <div class="product-form-group">
            <label for="title">상품명</label>
            <input type="text" id="title" name="title" maxlength="150" value="<%= escapeHtml(product.getTitle()) %>" required>
        </div>

        <% if (images != null && !images.isEmpty()) { %>
            <div class="product-form-group">
                <label>현재 상품 이미지</label>
                <div class="product-thumbnail-container">
                    <% for (ProductImageDTO image : images) {
                        boolean isMain = "Y".equals(image.getIsMain());
                    %>
                        <div class="product-thumb-wrapper <%= isMain ? "main-selected" : "" %>">
                            <div class="product-main-badge">대표</div>
                            <img src="<%= contextPath + image.getImagePath() + image.getSaveName() %>" alt="상품 이미지">
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>

        <div class="product-form-group">
            <label for="region">거래 지역</label>
            <input type="text" id="region" name="region" value="<%= escapeHtml(product.getRegion()) %>" required>
        </div>

        <div class="product-form-group product-price-input">
            <label for="price">판매 가격</label>
            <input type="number" id="price" name="price" min="0" value="<%= product.getPrice() %>" required>
        </div>

        <div class="product-form-group">
            <label for="content">상품 설명</label>
            <textarea id="content" name="content" required><%= escapeHtml(product.getContent()) %></textarea>
        </div>

        <div class="product-button-group">
            <button type="submit" class="product-btn product-btn-submit">수정 완료</button>
            <a href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>" class="product-btn product-btn-cancel">취소</a>
        </div>
    </form>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
