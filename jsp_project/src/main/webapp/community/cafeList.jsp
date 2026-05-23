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
<main class="page-shell community-shell">
    <section class="community-section">
        <div class="detail-header community-list-header">
            <div>
                <p class="eyebrow">커뮤니티</p>
                <h1>카페 목록</h1>
                <p class="community-meta">지역, 주제, 활동량으로 동네 카페를 찾아보세요.</p>
            </div>
            <% if (loggedIn) { %>
                <a class="button btn-primary" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
            <% } %>
        </div>
        <form class="community-filter-bar" action="<%= contextPath %>/community/cafeList.jsp" method="get">
            <input name="keyword" placeholder="카페명 또는 소개글" value="<%= escapeHtml(keyword) %>">
            <input name="region" placeholder="지역" value="<%= escapeHtml(region) %>">
            <input name="category" placeholder="주제" value="<%= escapeHtml(category) %>">
            <select name="sort">
                <option value="recent" <%= "recent".equals(sort) ? "selected" : "" %>>최신순</option>
                <option value="popular" <%= "popular".equals(sort) ? "selected" : "" %>>인기순</option>
            </select>
            <button class="btn-primary" type="submit">검색</button>
        </form>
    </section>

    <section class="community-section">
        <div class="section-title-row">
            <h2>카페 <%= cafes.size() %>개</h2>
        </div>
        <div class="community-grid">
            <% if (cafes.isEmpty()) { %>
                <p class="empty-cell">검색 결과가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : cafes) { %>
                <a class="community-cafe-card" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <div class="community-card-cover cover-tone-<%= cafe.getCafeId() % 4 %>">
                        <span><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></span>
                    </div>
                    <div class="community-card-body">
                        <span class="community-badge"><%= escapeHtml(cafe.getCategory()) %></span>
                        <h3><%= escapeHtml(cafe.getCafeName()) %></h3>
                        <p><%= escapeHtml(cafe.getDescription()) %></p>
                        <div class="community-meta-row">
                            <span><%= escapeHtml(cafe.getRegion()) %></span>
                            <span>회원 <%= cafe.getMemberCount() %>명</span>
                            <span>글 <%= cafe.getPostCount() %>개</span>
                        </div>
                        <span class="community-card-cta">카페 보기</span>
                    </div>
                </a>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
