<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafePostDTO" %>
<%@ include file="../common/sessionCheck.jsp" %>
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
    CafePostDTO post = new CafePostDAO().selectPostById(postId);
    if (post == null) {
        response.sendRedirect(request.getContextPath() + "/community/communityHome.jsp?error=noPost");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean manager = memberDao.isCafeManagerOrOwner(post.getCafeId(), currentLoginId);
    boolean isWriter = currentLoginId != null && currentLoginId.equals(post.getWriterId());
    if (!isWriter && !manager) {
        response.sendRedirect(request.getContextPath() + "/community/postDetail.jsp?postId=" + postId + "&error=updateDenied");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 수정 | 동네마켓 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>게시글 수정</h1>
        <p><%= escapeHtml(post.getCafeName()) %> · <%= escapeHtml(post.getBoardName()) %></p>
        <% if ("fail".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">게시글 수정에 실패했습니다.</p>
        <% } %>
        <form class="form-grid" action="<%= contextPath %>/community/postUpdateProcess.jsp" method="post">
            <input type="hidden" name="postId" value="<%= postId %>">
            <div class="field">
                <label for="title">제목</label>
                <input id="title" name="title" maxlength="200" value="<%= escapeHtml(post.getTitle()) %>" required>
            </div>
            <div class="field">
                <label for="content">내용</label>
                <textarea id="content" name="content" style="min-height:220px;" required><%= escapeHtml(post.getContent()) %></textarea>
            </div>
            <% if (manager) { %>
                <label><input type="checkbox" name="isNotice" value="Y" <%= "Y".equals(post.getIsNotice()) ? "checked" : "" %>> 공지글</label>
            <% } %>
            <div class="form-actions">
                <button class="primary" type="submit">수정</button>
                <a class="button" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= postId %>">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
