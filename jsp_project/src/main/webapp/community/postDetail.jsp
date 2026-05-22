<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeCommentDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%!
    private int parseIntParam(String value) {
        try {
            return value == null ? 0 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
%>
<%
    int postId = parseIntParam(request.getParameter("postId"));
    CafePostDAO postDao = new CafePostDAO();
    CafePostDTO post = postDao.selectPostById(postId);
    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    CafeDTO cafe = new CafeDAO().selectCafeById(post.getCafeId());
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = currentLoginId != null && memberDao.isActiveMember(post.getCafeId(), currentLoginId);
    boolean manager = currentLoginId != null && memberDao.isCafeManagerOrOwner(post.getCafeId(), currentLoginId);
    boolean isWriter = currentLoginId != null && currentLoginId.equals(post.getWriterId());
    boolean canRead = cafe != null && ("PUBLIC".equals(cafe.getVisibility()) || activeMember);
    if (!canRead) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + post.getCafeId() + "&error=private");
        return;
    }

    postDao.increaseViewCount(postId);
    List<CafeCommentDTO> comments = new CafeCommentDAO().selectCommentsByPostId(postId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(post.getTitle()) %> | 동네마켓 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p><a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= post.getCafeId() %>&boardId=<%= post.getBoardId() %>"><%= escapeHtml(post.getCafeName()) %> · <%= escapeHtml(post.getBoardName()) %></a></p>
                <h1><%= escapeHtml(post.getTitle()) %></h1>
                <p class="community-meta"><%= escapeHtml(post.getWriterNickname()) %> · 조회 <%= post.getViewCount() + 1 %> · 댓글 <%= post.getCommentCount() %></p>
            </div>
            <% if (isWriter || manager) { %>
                <button type="button" onclick="deletePost(<%= postId %>)" style="border-color:#d93025;color:#d93025;">삭제</button>
            <% } %>
        </div>
        <div class="community-content"><%= escapeHtml(post.getContent()) %></div>
    </section>

    <section class="detail-panel">
        <h2>댓글 <%= comments.size() %></h2>
        <div class="community-list">
            <% if (comments.isEmpty()) { %>
                <p class="empty-cell">아직 댓글이 없습니다.</p>
            <% } %>
            <% for (CafeCommentDTO comment : comments) { %>
                <div class="community-card">
                    <strong><%= escapeHtml(comment.getWriterNickname()) %></strong>
                    <p><%= escapeHtml(comment.getContent()) %></p>
                    <p class="community-meta"><%= comment.getCreatedAt() %></p>
                </div>
            <% } %>
        </div>
        <% if (activeMember) { %>
            <form class="form-grid" action="<%= contextPath %>/community/commentWriteProcess.jsp" method="post">
                <input type="hidden" name="postId" value="<%= postId %>">
                <div class="inline-check">
                    <input name="content" maxlength="1000" placeholder="댓글을 입력하세요" required>
                    <button class="primary" type="submit">등록</button>
                </div>
            </form>
        <% } else if (!loggedIn) { %>
            <p class="community-meta">댓글은 로그인 후 작성할 수 있습니다.</p>
        <% } else { %>
            <p class="community-meta">댓글은 카페 가입 후 작성할 수 있습니다.</p>
        <% } %>
    </section>
</main>
<script>
    function deletePost(postId) {
        if (confirm("게시글을 삭제하시겠습니까?")) {
            location.href = "<%= request.getContextPath() %>/community/postDeleteProcess.jsp?postId=" + postId;
        }
    }
</script>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
