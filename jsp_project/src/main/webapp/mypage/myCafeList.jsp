<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeDAO cafeDao = new CafeDAO();
    List<CafeDTO> joinedCafes = cafeDao.selectJoinedCafes(currentLoginId);
    List<CafeDTO> ownedCafes = cafeDao.selectOwnedCafes(currentLoginId);
    List<CafeDTO> favoriteCafes = new CafeFavoriteDAO().selectFavoriteCafes(currentLoginId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 카페 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-community-1">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">내 커뮤니티 활동</p>
            <h1>내 카페</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a class="button primary" href="<%= contextPath %>/community/cafeCreate.jsp">카페 만들기</a>
        </div>
    </div>

    <section class="admin-summary">
        <a href="#joined"><span>가입한 카페</span><strong><%= joinedCafes.size() %></strong></a>
        <a href="#owned"><span>만든 카페</span><strong><%= ownedCafes.size() %></strong></a>
        <a href="#favorite"><span>즐겨찾기</span><strong><%= favoriteCafes.size() %></strong></a>
    </section>

    <section id="joined" class="detail-panel">
        <h2>가입한 카페</h2>
        <div class="community-list">
            <% if (joinedCafes.isEmpty()) { %>
                <p class="empty-cell">가입한 카페가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : joinedCafes) { %>
                <a class="community-row" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <span><strong><%= escapeHtml(cafe.getCafeName()) %></strong><br><small class="community-meta"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></small></span>
                    <span class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %></span>
                </a>
            <% } %>
        </div>
    </section>

    <section id="owned" class="detail-panel">
        <h2>만든 카페</h2>
        <div class="community-list">
            <% if (ownedCafes.isEmpty()) { %>
                <p class="empty-cell">운영 중인 카페가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : ownedCafes) { %>
                <a class="community-row" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <span><strong><%= escapeHtml(cafe.getCafeName()) %></strong><br><small class="community-meta"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></small></span>
                    <span class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %></span>
                </a>
            <% } %>
        </div>
    </section>

    <section id="favorite" class="detail-panel">
        <h2>즐겨찾기 카페</h2>
        <div class="community-list">
            <% if (favoriteCafes.isEmpty()) { %>
                <p class="empty-cell">즐겨찾기한 카페가 없습니다.</p>
            <% } %>
            <% for (CafeDTO cafe : favoriteCafes) { %>
                <a class="community-row" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafe.getCafeId() %>">
                    <span><strong><%= escapeHtml(cafe.getCafeName()) %></strong><br><small class="community-meta"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></small></span>
                    <span class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %></span>
                </a>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
