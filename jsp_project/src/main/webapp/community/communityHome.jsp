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
    <section class="cafe-top">
        <p class="eyebrow">동네마켓 커뮤니티</p>
        <h1>카페</h1>
        <p>지역과 관심사별 카페를 찾고, 게시판에서 이야기를 나눠보세요.</p>
    </section>

    <form class="cafe-search-bar" action="<%= contextPath %>/community/cafeList.jsp" method="get">
        <strong>카페 검색</strong>
        <input id="keyword" name="keyword" placeholder="카페명 또는 소개글 검색">
        <button class="btn-main btn-small" type="submit">검색</button>
    </form>

    <section class="cafe-portal-grid">
        <aside class="cafe-box">
            <div class="cafe-section-title">카페 카테고리</div>
            <nav class="cafe-category-list" aria-label="카페 카테고리">
                <a href="<%= contextPath %>/community/cafeList.jsp?category=동네소식">동네소식</a>
                <a href="<%= contextPath %>/community/cafeList.jsp?category=맛집">맛집</a>
                <a href="<%= contextPath %>/community/cafeList.jsp?category=반려동물">반려동물</a>
                <a href="<%= contextPath %>/community/cafeList.jsp?category=취미">취미</a>
                <a href="<%= contextPath %>/community/cafeList.jsp?category=육아">육아</a>
            </nav>
        </aside>

        <section class="cafe-box">
            <div class="cafe-section-title">
                <span>인기 카페</span>
                <a class="btn-text" href="<%= contextPath %>/community/cafeList.jsp?sort=popular">전체보기</a>
            </div>
            <div class="cafe-rank-list">
                <% int rank = 1; %>
                <% for (CafeDTO cafe : popularCafes) { %>
                    <a class="cafe-rank-item" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                        <span class="cafe-rank-number"><%= rank++ %></span>
                        <span class="cafe-list-copy">
                            <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
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

        <aside class="cafe-box cafe-info-box">
            <div class="cafe-section-title">커뮤니티 안내</div>
            <div class="cafe-box-body cafe-action-stack">
                <% if (loggedIn) { %>
                    <a class="button btn-main" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
                <% } else { %>
                    <a class="button btn-main" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 만들기</a>
                <% } %>
                <a class="button btn-sub" href="<%= contextPath %>/community/cafeList.jsp">카페 둘러보기</a>
                <p class="community-meta">카페 검색, 추천 카페, 최근 글을 게시판처럼 조밀하게 정리했습니다.</p>
            </div>
        </aside>
    </section>

    <section class="cafe-box">
        <div class="cafe-section-title">새 카페</div>
        <div class="cafe-directory-list">
            <% for (CafeDTO cafe : recentCafes) { %>
                <a class="cafe-directory-item" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <span class="cafe-initial"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></span>
                    <span class="cafe-list-copy">
                        <strong><%= escapeHtml(cafe.getCafeName()) %></strong>
                        <p><%= escapeHtml(cafe.getDescription()) %></p>
                        <span class="cafe-meta-line">
                            <span><%= escapeHtml(com.carrot.util.RegionFormatter.formatKoreanSigungu(cafe.getRegion())) %></span>
                            <span><%= escapeHtml(cafe.getCategory()) %></span>
                            <span>회원 <%= cafe.getMemberCount() %></span>
                        </span>
                    </span>
                    <span class="btn-sub btn-small">방문</span>
                </a>
            <% } %>
        </div>
    </section>

    <section class="cafe-box">
        <div class="cafe-section-title">최근 올라온 글</div>
        <table class="post-board-table">
            <colgroup>
                <col class="col-type">
                <col>
                <col class="col-author">
                <col class="col-count">
                <col class="col-count">
            </colgroup>
            <thead>
                <tr>
                    <th>구분</th>
                    <th>제목</th>
                    <th>카페</th>
                    <th>댓글</th>
                    <th>좋아요</th>
                </tr>
            </thead>
            <tbody>
                <% for (CafePostDTO post : recentPosts) { %>
                    <tr>
                        <td><span class="<%= "Y".equals(post.getIsNotice()) ? "notice-badge" : "board-badge is-normal" %>"><%= "Y".equals(post.getIsNotice()) ? "공지" : "일반" %></span></td>
                        <td class="post-title-cell"><a href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                        <td><%= escapeHtml(post.getCafeName()) %></td>
                        <td><%= post.getCommentCount() %></td>
                        <td><%= post.getLikeCount() %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
