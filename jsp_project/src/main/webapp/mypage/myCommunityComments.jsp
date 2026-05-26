<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    String currentLoginId = (String) session.getAttribute("loginId");
    List<CafeCommentDTO> comments = new CafeCommentDAO().selectCommentsByWriter(currentLoginId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 커뮤니티 댓글 | 동네마켓</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=mypage-community-1">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="admin-shell">
    <div class="admin-heading">
        <div>
            <p class="eyebrow">내 커뮤니티 활동</p>
            <h1>내가 쓴 댓글</h1>
        </div>
        <div class="admin-actions">
            <a class="button" href="<%= contextPath %>/mypage/mypage.jsp">마이페이지</a>
            <a class="button" href="<%= contextPath %>/mypage/myCommunityPosts.jsp">내가 쓴 글</a>
        </div>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>댓글</th>
                    <th>글</th>
                    <th>카페</th>
                    <th>게시판</th>
                    <th>작성일</th>
                </tr>
            </thead>
            <tbody>
                <% if (comments.isEmpty()) { %>
                    <tr><td class="empty-cell" colspan="5">작성한 커뮤니티 댓글이 없습니다.</td></tr>
                <% } %>
                <% for (CafeCommentDTO comment : comments) { %>
                    <tr>
                        <td><%= escapeHtml(comment.getContent()) %></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= comment.getPostId() %>"><%= escapeHtml(comment.getPostTitle()) %></a></td>
                        <td><a class="table-link" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= comment.getCafeId() %>"><%= escapeHtml(comment.getCafeName()) %></a></td>
                        <td><%= escapeHtml(comment.getBoardName()) %></td>
                        <td><%= comment.getCreatedAt() == null ? "-" : comment.getCreatedAt() %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
