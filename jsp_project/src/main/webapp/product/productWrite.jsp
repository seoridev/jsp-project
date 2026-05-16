<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="java.util.List" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    CategoryDAO categoryDAO = new CategoryDAO();
    List<CategoryDTO> categories = categoryDAO.selectAllCategories();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 등록 - 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>상품 등록</h1>
        <p>판매할 상품 정보를 입력해 주세요.</p>

        <form class="form-grid" action="<%= contextPath %>/product/productWriteProcess.jsp" method="post" enctype="multipart/form-data">
            <div class="field">
                <label for="categoryId">카테고리</label>
                <select id="categoryId" name="categoryId" required>
                    <option value="">카테고리 선택</option>
                    <% for (CategoryDTO category : categories) { %>
                        <option value="<%= category.getCategoryId() %>"><%= escapeHtml(category.getCategoryName()) %></option>
                    <% } %>
                </select>
            </div>
            <div class="field">
                <label for="title">상품명</label>
                <input id="title" name="title" maxlength="150" required>
            </div>
            <div class="field">
                <label for="region">거래 지역</label>
                <input id="region" name="region" value="<%= escapeHtml(loginRegion) %>" required>
            </div>
            <div class="field">
                <label for="price">판매 가격</label>
                <input id="price" name="price" type="number" min="0" required>
            </div>
            <div class="field">
                <label for="content">상품 설명</label>
                <textarea id="content" name="content" rows="8" required></textarea>
            </div>
            <div class="field">
                <label>상품 이미지</label>
                <input type="file" name="image_0" accept="image/*">
                <input type="file" name="image_1" accept="image/*">
                <input type="file" name="image_2" accept="image/*">
                <input type="file" name="image_3" accept="image/*">
                <input type="file" name="image_4" accept="image/*">
                <small>첫 번째 이미지를 대표 이미지로 사용합니다.</small>
            </div>
            <input type="hidden" name="mainImageIndex" value="0">
            <div class="form-actions">
                <button class="primary" type="submit">등록하기</button>
                <a class="button" href="<%= contextPath %>/product/productList.jsp">목록으로</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
