<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.carrot.dao.CafeCategoryDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dto.CafeCategoryDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.carrot.util.RegionFormatter" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%
    // 검색 조건과 즐겨찾기 여부를 함께 조회
    String keyword = request.getParameter("keyword");
    String region = request.getParameter("region");
    int cafeCategoryId = ParamParser.parseInt(request.getParameter("cafeCategoryId"));
    String sort = request.getParameter("sort") == null ? "recent" : request.getParameter("sort");
    String currentLoginId = (String) session.getAttribute("loginId");
    List<CafeCategoryDTO> cafeCategories = new CafeCategoryDAO().selectActiveCategories();
    List<CafeDTO> cafes = new CafeDAO().selectCafeList(keyword, region, cafeCategoryId > 0 ? cafeCategoryId : null, sort, 100);
    Set<Integer> favoriteCafeIds = new HashSet<>();
    if (currentLoginId != null) {
        for (CafeDTO favoriteCafe : new CafeFavoriteDAO().selectFavoriteCafes(currentLoginId)) {
            favoriteCafeIds.add(favoriteCafe.getCafeId());
        }
    }
    String cafeListReturn = request.getRequestURI().substring(request.getContextPath().length());
    String cafeListQuery = request.getQueryString();
    if (cafeListQuery != null) {
        cafeListReturn += "?" + cafeListQuery;
    }
    String cafeListRedirect = URLEncoder.encode(cafeListReturn, "UTF-8");
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
            <select name="cafeCategoryId">
                <option value="">전체 주제</option>
                <% for (CafeCategoryDTO category : cafeCategories) { %>
                    <option value="<%= category.getCafeCategoryId() %>" <%= category.getCafeCategoryId() == cafeCategoryId ? "selected" : "" %>><%= escapeHtml(category.getCategoryName()) %></option>
                <% } %>
            </select>
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
                <div class="cafe-directory-item">
                    <a class="cafe-list-main" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                        <span class="cafe-initial"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></span>
                        <span class="cafe-list-copy">
                            <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                            <p><%= escapeHtml(cafe.getDescription()) %></p>
                            <span class="cafe-meta-line">
                                <span><%= escapeHtml(RegionFormatter.formatKoreanSigungu(cafe.getRegion())) %></span>
                                <span><%= escapeHtml(cafe.getCategory()) %></span>
                                <span>회원 <%= cafe.getMemberCount() %></span>
                                <span>글 <%= cafe.getPostCount() %></span>
                            </span>
                        </span>
                        <span class="btn-sub btn-small">방문</span>
                    </a>
                    <% if (currentLoginId != null) { %>
                        <form class="cafe-list-favorite-form" action="<%= contextPath %>/community/cafe/cafeFavoriteProcess.jsp" method="post">
                            <input type="hidden" name="cafeId" value="<%= cafe.getCafeId() %>">
                            <input type="hidden" name="redirect" value="<%= escapeHtml(cafeListReturn) %>">
                            <% boolean favoriteCafe = favoriteCafeIds.contains(cafe.getCafeId()); %>
                            <button class="cafe-favorite-toggle <%= favoriteCafe ? "is-active" : "" %>" type="submit" aria-label="<%= favoriteCafe ? "remove favorite" : "add favorite" %>"><%= favoriteCafe ? "&#9733;" : "&#9734;" %></button>
                        </form>
                    <% } else { %>
                        <a class="cafe-favorite-toggle" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeListRedirect %>" aria-label="login to add favorite">&#9734;</a>
                    <% } %>
                </div>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
