<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dao.ProductDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="com.carrot.dto.ProductDTO" %>
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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 수정 - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>상품 수정</h1>
        <p>상품 정보는 작성자 본인만 수정할 수 있습니다.</p>

        <form class="form-grid" action="<%= contextPath %>/product/productEditProcess.jsp" method="post">
            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
            <div class="field">
                <label for="categoryId">카테고리</label>
                <select id="categoryId" name="categoryId" required>
                    <% for (CategoryDTO category : categories) { %>
                        <option value="<%= category.getCategoryId() %>" <%= category.getCategoryId() == product.getCategoryId() ? "selected" : "" %>>
                            <%= escapeHtml(category.getCategoryName()) %>
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="field">
                <label for="title">상품명</label>
                <input id="title" name="title" maxlength="150" value="<%= escapeHtml(product.getTitle()) %>" required>
            </div>
            <div class="field">
                <label for="region">거래 지역</label>
                <input id="region" name="region" value="<%= escapeHtml(product.getRegion()) %>" required>
            </div>
            <div class="field">
                <label for="price">판매 가격</label>
                <input id="price" name="price" type="number" min="0" value="<%= product.getPrice() %>" required>
            </div>
            <div class="field">
                <label for="content">상품 설명</label>
                <textarea id="content" name="content" rows="8" required><%= escapeHtml(product.getContent()) %></textarea>
            </div>
            <div class="form-actions">
                <button class="primary" type="submit">수정하기</button>
                <a class="button" href="<%= contextPath %>/product/productDetail.jsp?id=<%= product.getProductId() %>">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
