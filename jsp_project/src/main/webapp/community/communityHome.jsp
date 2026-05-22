<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%
    CafeDAO cafeDao = new CafeDAO();
    CafePostDAO postDao = new CafePostDAO();
    List<CafeDTO> popularCafes = cafeDao.selectCafeList(null, null, null, "popular", 6);
    List<CafeDTO> recentCafes = cafeDao.selectCafeList(null, null, null, "recent", 6);
    List<CafePostDTO> recentPosts = postDao.selectRecentPosts(8);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동네마켓 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p class="eyebrow">동네마켓 커뮤니티</p>
                <h1>동네 이웃과 카페에서 이야기해요</h1>
            </div>
            <div class="form-actions">
                <a class="button" href="<%= contextPath %>/community/cafeList.jsp">카페 둘러보기</a>
                <% if (loggedIn) { %>
                    <a class="button primary" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
                <% } else { %>
                    <a class="button primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 만들기</a>
                <% } %>
            </div>
        </div>
        <form class="home-main-search" action="<%= contextPath %>/community/cafeList.jsp" method="get">
            <label class="visually-hidden" for="keyword">카페 검색</label>
            <input id="keyword" name="keyword" placeholder="카페명, 소개글을 검색하세요">
            <button type="submit">검색</button>
        </form>
    </section>

    <section class="detail-panel">
        <h2>인기 카페</h2>
        <div class="community-grid">
            <% for (CafeDTO cafe : popularCafes) { %>
                <a class="community-card" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <h3><%= escapeHtml(cafe.getCafeName()) %></h3>
                    <p class="community-meta"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></p>
                    <p class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %></p>
                </a>
            <% } %>
        </div>
    </section>

    <section class="home-layout" style="align-items:start;">
        <div class="detail-panel">
            <h2>새 카페</h2>
            <div class="community-list">
                <% for (CafeDTO cafe : recentCafes) { %>
                    <a class="community-row" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                        <span><strong><%= escapeHtml(cafe.getCafeName()) %></strong><br><small class="community-meta"><%= escapeHtml(cafe.getRegion()) %></small></span>
                        <span class="status-badge"><%= escapeHtml(cafe.getCategory()) %></span>
                    </a>
                <% } %>
            </div>
        </div>
        <div class="detail-panel">
            <h2>최근 글</h2>
            <div class="community-list">
                <% for (CafePostDTO post : recentPosts) { %>
                    <a class="community-row" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                        <span><strong><%= escapeHtml(post.getTitle()) %></strong><br><small class="community-meta"><%= escapeHtml(post.getCafeName()) %> · 댓글 <%= post.getCommentCount() %></small></span>
                    </a>
                <% } %>
            </div>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
