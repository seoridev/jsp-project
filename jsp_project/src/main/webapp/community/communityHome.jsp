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
    <title>커뮤니티 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell community-shell">
    <section class="community-hero">
        <div class="community-hero-copy">
            <p class="eyebrow">동네 커뮤니티</p>
            <h1>관심 카페를 찾고 이웃과 이야기를 나누세요.</h1>
            <p>지역과 주제별 카페를 둘러보고, 새 글과 활발한 대화에 바로 참여해보세요.</p>
            <form class="community-search" action="<%= contextPath %>/community/cafeList.jsp" method="get">
                <label class="visually-hidden" for="keyword">카페 검색</label>
                <input id="keyword" name="keyword" placeholder="카페명이나 소개글 검색">
                <button class="btn-primary" type="submit">검색</button>
            </form>
            <div class="community-hero-actions">
                <a class="button btn-secondary" href="<%= contextPath %>/community/cafeList.jsp">카페 둘러보기</a>
                <% if (loggedIn) { %>
                    <a class="button btn-primary" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
                <% } else { %>
                    <a class="button btn-primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 만들기</a>
                <% } %>
            </div>
        </div>
        <aside class="community-hero-side">
            <span class="community-badge">지금 인기</span>
            <% int heroCount = 0; %>
            <% for (CafeDTO cafe : popularCafes) { %>
                <% if (heroCount++ >= 3) { break; } %>
                <a class="community-stat-card" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                    <span><%= escapeHtml(cafe.getRegion()) %> · 회원 <%= cafe.getMemberCount() %>명</span>
                </a>
            <% } %>
        </aside>
    </section>

    <section class="community-section">
        <div class="section-title-row">
            <div>
                <p class="eyebrow">추천 카페</p>
                <h2>인기 카페</h2>
            </div>
            <a class="button btn-ghost" href="<%= contextPath %>/community/cafeList.jsp?sort=popular">전체 보기</a>
        </div>
        <div class="community-grid">
            <% for (CafeDTO cafe : popularCafes) { %>
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
                        <span class="community-card-cta">카페 입장</span>
                    </div>
                </a>
            <% } %>
        </div>
    </section>

    <section class="community-two-column">
        <div class="community-section">
            <div class="section-title-row">
                <h2>새 카페</h2>
            </div>
            <div class="community-grid compact">
                <% for (CafeDTO cafe : recentCafes) { %>
                    <a class="community-cafe-card" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                        <div class="community-card-cover cover-tone-<%= cafe.getCafeId() % 4 %>"></div>
                        <div class="community-card-body">
                            <span class="community-badge"><%= escapeHtml(cafe.getCategory()) %></span>
                            <h3><%= escapeHtml(cafe.getCafeName()) %></h3>
                            <div class="community-meta-row">
                                <span><%= escapeHtml(cafe.getRegion()) %></span>
                                <span>회원 <%= cafe.getMemberCount() %>명</span>
                            </div>
                        </div>
                    </a>
                <% } %>
            </div>
        </div>
        <div class="community-section">
            <div class="section-title-row">
                <h2>최근 글</h2>
            </div>
            <div class="post-feed-list">
                <% for (CafePostDTO post : recentPosts) { %>
                    <a class="post-feed-item" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                        <div class="post-title-row">
                            <strong><%= escapeHtml(post.getTitle()) %></strong>
                        </div>
                        <div class="post-meta">
                            <span><%= escapeHtml(post.getCafeName()) %></span>
                            <span>댓글 <%= post.getCommentCount() %>개</span>
                        </div>
                    </a>
                <% } %>
            </div>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
