<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%
    String keyword = request.getParameter("keyword");
    String region = request.getParameter("region");
    String category = request.getParameter("category");
    String sort = request.getParameter("sort") == null ? "recent" : request.getParameter("sort");
    List<CafeDTO> cafes = new CafeDAO().selectCafeList(keyword, region, category, sort, 100);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카페 목록 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p class="eyebrow">커뮤니티</p>
                <h1>카페 목록</h1>
            </div>
            <% if (loggedIn) { %>
                <a class="button primary" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
            <% } %>
        </div>
        <form class="form-grid" action="<%= contextPath %>/community/cafeList.jsp" method="get">
            <div class="inline-check" style="grid-template-columns: minmax(0,1fr) minmax(0,1fr) minmax(0,1fr) 110px;">
                <input name="keyword" placeholder="카페명/소개" value="<%= escapeHtml(keyword) %>">
                <input name="region" placeholder="지역" value="<%= escapeHtml(region) %>">
                <input name="category" placeholder="주제" value="<%= escapeHtml(category) %>">
                <button class="primary" type="submit">검색</button>
            </div>
            <select name="sort" onchange="this.form.submit()">
                <option value="recent" <%= "recent".equals(sort) ? "selected" : "" %>>최신순</option>
                <option value="popular" <%= "popular".equals(sort) ? "selected" : "" %>>인기순</option>
            </select>
        </form>
    </section>

    <section class="detail-panel">
        <p class="community-meta">총 <%= cafes.size() %>개 카페</p>
        <div class="community-grid">
            <% if (cafes.isEmpty()) { %>
                <p class="empty-cell">검색 결과가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : cafes) { %>
                <a class="community-card" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <h3><%= escapeHtml(cafe.getCafeName()) %></h3>
                    <p><%= escapeHtml(cafe.getDescription()) %></p>
                    <p class="community-meta"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></p>
                    <p class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %></p>
                </a>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
