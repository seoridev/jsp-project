<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    List<CafePostDTO> posts = new CafePostDAO().selectPostsByWriter(currentLoginId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 커뮤니티 글 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-community-1">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">내 커뮤니티 활동</p>
            <h1>내가 쓴 글</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a class="button" href="<%= contextPath %>/mypage/myCafeList.jsp">내 카페</a>
        </div>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>글 제목</th>
                    <th>카페</th>
                    <th>게시판</th>
                    <th>조회</th>
                    <th>댓글</th>
                    <th>좋아요</th>
                </tr>
            </thead>
            <tbody>
                <% if (posts.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="6">작성한 커뮤니티 글이 없습니다.</td></tr>
                <% } %>
                <% for (CafePostDTO post : posts) { %>
                    <tr>
                        <td><a class="table-link" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= post.getCafeId() %>"><%= escapeHtml(post.getCafeName()) %></a></td>
                        <td><%= escapeHtml(post.getBoardName()) %></td>
                        <td><%= post.getViewCount() %></td>
                        <td><%= post.getCommentCount() %></td>
                        <td><%= post.getLikeCount() %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
