<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
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
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    int boardId = parseIntParam(request.getParameter("boardId"));
    String keyword = request.getParameter("keyword");

    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
    if (boardId <= 0 && !boards.isEmpty()) {
        boardId = boards.get(0).getBoardId();
    }
    CafeBoardDTO selectedBoard = new CafeBoardDAO().selectBoardById(boardId);
    if (selectedBoard == null || selectedBoard.getCafeId() != cafeId) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId);
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = currentLoginId != null && memberDao.isActiveMember(cafeId, currentLoginId);
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;
    boolean canWrite = activeMember && ("MEMBER".equals(selectedBoard.getWritePermission()) || memberDao.isCafeManagerOrOwner(cafeId, currentLoginId));
    List<CafePostDTO> posts = canRead ? new CafePostDAO().selectPosts(cafeId, boardId, keyword, 100) : java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(selectedBoard.getBoardName()) %> | <%= escapeHtml(cafe.getCafeName()) %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <div class="detail-header">
            <div>
                <p><a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a></p>
                <h1><%= escapeHtml(selectedBoard.getBoardName()) %></h1>
                <p class="community-meta"><%= escapeHtml(selectedBoard.getDescription()) %></p>
            </div>
            <% if (canWrite) { %>
                <a class="button primary" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">글쓰기</a>
            <% } %>
        </div>
        <div class="community-tabs">
            <% for (CafeBoardDTO board : boards) { %>
                <a class="<%= board.getBoardId() == boardId ? "active" : "" %>" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                    <%= escapeHtml(board.getBoardName()) %>
                </a>
            <% } %>
        </div>
        <form class="form-grid" action="<%= contextPath %>/community/postList.jsp" method="get">
            <input type="hidden" name="cafeId" value="<%= cafeId %>">
            <input type="hidden" name="boardId" value="<%= boardId %>">
            <div class="inline-check">
                <input name="keyword" placeholder="글 검색" value="<%= escapeHtml(keyword) %>">
                <button type="submit">검색</button>
            </div>
        </form>
    </section>

    <section class="detail-panel">
        <% if (!canRead) { %>
            <p class="empty-cell">비공개 카페입니다. 가입 후 글을 볼 수 있습니다.</p>
        <% } else if (posts.isEmpty()) { %>
            <p class="empty-cell">게시글이 없습니다.</p>
        <% } else { %>
            <div class="community-list">
                <% for (CafePostDTO post : posts) { %>
                    <a class="community-row" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                        <span><strong><%= "Y".equals(post.getIsNotice()) ? "[공지] " : "" %><%= escapeHtml(post.getTitle()) %></strong><br><small class="community-meta"><%= escapeHtml(post.getWriterNickname()) %> · 조회 <%= post.getViewCount() %></small></span>
                        <span class="community-meta">댓글 <%= post.getCommentCount() %></span>
                    </a>
                <% } %>
            </div>
        <% } %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
