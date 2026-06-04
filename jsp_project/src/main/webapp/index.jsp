<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CategoryDAO" %>
<%@ page import="com.carrot.dto.CategoryDTO" %>
<%@ page import="java.util.List" %>
<%
    // 추가됨: 메인 카테고리 링크를 실제 활성 카테고리 기준으로 출력
    CategoryDAO categoryDao = new CategoryDAO();
    List<CategoryDTO> categoryList = categoryDao.selectAllCategories();
    String[] categoryMarkClasses = {"mark-red", "mark-yellow", "mark-brown", "mark-yellow", "mark-blue", "mark-green", "mark-orange", "mark-yellow"};
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=home-category-1">
</head>
<body>
<%@ include file="common/header.jsp" %>
<main class="home-search-page">
    <section class="home-search-shell" aria-labelledby="home-title">
        <h1 id="home-title">우리 동네 중고거래를 더 편하게 만나보세요</h1>

        <form class="home-main-search" action="<%= contextPath %>/product/productList.jsp" method="get">
            <label class="visually-hidden" for="home-search-type">검색 종류</label>
            <select id="home-search-type" name="type" aria-label="검색 종류">
                <option value="all">중고거래</option>
                <option value="title">제목</option>
                <option value="content">내용</option>
            </select>

            <span class="home-search-divider" aria-hidden="true"></span>

            <label class="visually-hidden" for="home-keyword">검색어</label>
            <input id="home-keyword" type="text" name="keyword" placeholder="검색어를 입력해주세요">

            <button type="submit" aria-label="검색">→</button>
        </form>

        <div class="home-keyword-row" aria-label="인기 검색어">
            <strong>인기 검색어</strong>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=에어컨">에어컨</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=노트북">노트북</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=원룸">원룸</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=자전거">자전거</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=책상">책상</a>
            <a href="<%= contextPath %>/product/productList.jsp?type=all&keyword=의자">의자</a>
        </div>

        <nav class="home-category-select" aria-label="카테고리 선택">
            <a href="<%= contextPath %>/product/productList.jsp">
                <span class="category-mark mark-orange">중</span>
                <strong>중고거래</strong>
            </a>
            <a href="<%= contextPath %>/community/communityHome.jsp">
                <span class="category-mark mark-green">커</span>
                <strong>동네마켓 커뮤니티</strong>
            </a>
            <%-- 추가됨: 활성 카테고리를 CATEGORY_ID 링크로 출력 --%>
            <% for (int i = 0; i < categoryList.size(); i++) {
                CategoryDTO category = categoryList.get(i);
                String markClass = categoryMarkClasses[i % categoryMarkClasses.length];
                String categoryName = category.getCategoryName();
                String markText = categoryName == null || categoryName.isEmpty() ? "?" : categoryName.substring(0, 1);
            %>
            <a href="<%= contextPath %>/product/productList.jsp?categoryId=<%= category.getCategoryId() %>">
                <span class="category-mark <%= markClass %>"><%= markText %></span>
                <strong><%= categoryName %></strong>
            </a>
            <% } %>
        </nav>
    </section>
</main>
<%@ include file="common/footer.jsp" %>
</body>
</html>
