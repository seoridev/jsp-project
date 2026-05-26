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
<%@ include file="../../common/header.jsp" %>
<main class="page-shell community-shell">
    <section class="cafe-top">
        <div class="section-title-row">
            <div>
                <p class="eyebrow">커뮤니티</p>
                <h1>카페 목록</h1>
                <p>카페명, 소개, 지역, 주제별로 동네 카페를 찾아보세요.</p>
            </div>
            <% if (loggedIn) { %>
                <a class="button btn-main" href="<%= contextPath %>/community/cafe/cafeCreate.jsp">카페 만들기</a>
            <% } %>
        </div>
    </section>

    <section class="cafe-box">
        <div class="cafe-section-title">검색 조건</div>
        <form class="cafe-filter-bar" action="<%= contextPath %>/community/cafe/cafeList.jsp" method="get">
            <input name="keyword" placeholder="카페명 또는 소개글" value="<%= escapeHtml(keyword) %>">
            <input name="region" placeholder="지역" value="<%= escapeHtml(region) %>">
            <input name="category" placeholder="주제" value="<%= escapeHtml(category) %>">
            <select name="sort">
                <option value="recent" <%= "recent".equals(sort) ? "selected" : "" %>>최신순</option>
                <option value="popular" <%= "popular".equals(sort) ? "selected" : "" %>>인기순</option>
            </select>
            <button class="btn-main btn-small" type="submit">검색</button>
        </form>
        <div class="cafe-section-title">
            <span>총 <%= cafes.size() %>개 카페</span>
            <a class="btn-text" href="<%= contextPath %>/community/communityHome.jsp">커뮤니티 홈</a>
        </div>
        <div class="cafe-directory-list">
            <% if (cafes.isEmpty()) { %>
                <p class="empty-cell">검색 결과가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : cafes) { %>
                <a class="cafe-directory-item" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <span class="cafe-initial"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></span>
                    <span class="cafe-list-copy">
                        <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                        <p><%= escapeHtml(cafe.getDescription()) %></p>
                        <span class="cafe-meta-line">
                            <span><%= escapeHtml(com.carrot.util.RegionFormatter.formatKoreanSigungu(cafe.getRegion())) %></span>
                            <span><%= escapeHtml(cafe.getCategory()) %></span>
                            <span>회원 <%= cafe.getMemberCount() %></span>
                            <span>글 <%= cafe.getPostCount() %></span>
                        </span>
                    </span>
                    <span class="btn-sub btn-small">방문</span>
                </a>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
