<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
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
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    int boardId = parseIntParam(request.getParameter("boardId"));
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    CafeBoardDTO board = new CafeBoardDAO().selectBoardById(boardId);
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean canWrite = cafe != null && board != null && board.getCafeId() == cafeId
            && memberDao.isActiveMember(cafeId, currentLoginId)
            && ("MEMBER".equals(board.getWritePermission()) || memberDao.isCafeManagerOrOwner(cafeId, currentLoginId));
    if (!canWrite) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId + "&error=noPermission");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글쓰기 | 동네마켓 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="auth-wrap">
    <section class="auth-panel">
        <h1>글쓰기</h1>
        <p><%= escapeHtml(cafe.getCafeName()) %> · <%= escapeHtml(board.getBoardName()) %></p>
        <form class="form-grid" action="<%= contextPath %>/community/postWriteProcess.jsp" method="post">
            <input type="hidden" name="cafeId" value="<%= cafeId %>">
            <input type="hidden" name="boardId" value="<%= boardId %>">
            <div class="field">
                <label for="title">제목</label>
                <input id="title" name="title" maxlength="200" required>
            </div>
            <div class="field">
                <label for="content">내용</label>
                <textarea id="content" name="content" style="min-height:220px;" required></textarea>
            </div>
            <% if (memberDao.isCafeManagerOrOwner(cafeId, currentLoginId)) { %>
                <label><input type="checkbox" name="isNotice" value="Y"> 공지글</label>
            <% } %>
            <div class="form-actions">
                <button class="primary" type="submit">등록</button>
                <a class="button" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">취소</a>
            </div>
        </form>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
