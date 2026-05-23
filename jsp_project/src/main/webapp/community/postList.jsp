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
    int pageNo = parseIntParam(request.getParameter("page"));
    if (pageNo <= 0) {
        pageNo = 1;
    }
    int pageSize = 10;
    String keyword = request.getParameter("keyword");
    String keywordParam = keyword == null ? "" : java.net.URLEncoder.encode(keyword, "UTF-8");

    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    CafeBoardDAO boardDao = new CafeBoardDAO();
    List<CafeBoardDTO> boards = boardDao.selectBoardsByCafeId(cafeId);
    if (boardId <= 0 && !boards.isEmpty()) {
        boardId = boards.get(0).getBoardId();
    }
    CafeBoardDTO selectedBoard = boardDao.selectBoardById(boardId);
    if (selectedBoard == null || selectedBoard.getCafeId() != cafeId) {
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId);
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = currentLoginId != null && memberDao.isActiveMember(cafeId, currentLoginId);
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;
    boolean canWrite = activeMember && ("MEMBER".equals(selectedBoard.getWritePermission()) || memberDao.isCafeManagerOrOwner(cafeId, currentLoginId));

    CafePostDAO postDao = new CafePostDAO();
    int totalCount = canRead ? postDao.countPosts(cafeId, boardId, keyword) : 0;
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNo > totalPages) {
        pageNo = totalPages;
    }
    List<CafePostDTO> posts = canRead ? postDao.selectPosts(cafeId, boardId, keyword, pageNo, pageSize) : java.util.Collections.emptyList();
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
            <input type="hidden" name="page" value="1">
            <div class="inline-check">
                <input name="keyword" placeholder="글 검색" value="<%= escapeHtml(keyword) %>">
                <button type="submit">검색</button>
            </div>
        </form>
    </section>

    <section class="detail-panel">
        <% if ("success".equals(request.getParameter("delete"))) { %>
            <p class="field-message is-success">게시글이 삭제되었습니다.</p>
        <% } %>
        <% if (!canRead) { %>
            <p class="empty-cell">비공개 카페입니다. 가입 후 글을 볼 수 있습니다.</p>
        <% } else if (posts.isEmpty()) { %>
            <p class="empty-cell">게시글이 없습니다.</p>
        <% } else { %>
            <div class="community-list">
                <% for (CafePostDTO post : posts) { %>
                    <a class="community-row" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                        <span>
                            <strong><%= "Y".equals(post.getIsNotice()) ? "[공지] " : "" %><%= escapeHtml(post.getTitle()) %></strong>
                            <br>
                            <small class="community-meta"><%= escapeHtml(post.getWriterNickname()) %> · 조회 <%= post.getViewCount() %></small>
                        </span>
                        <span class="community-meta">댓글 <%= post.getCommentCount() %></span>
                    </a>
                <% } %>
            </div>
            <div class="form-actions" style="justify-content:center;margin-top:16px;">
                <% if (pageNo > 1) { %>
                    <a class="button" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= pageNo - 1 %>">이전</a>
                <% } %>
                <span class="community-meta"><%= pageNo %> / <%= totalPages %> 페이지 · 총 <%= totalCount %>개</span>
                <% if (pageNo < totalPages) { %>
                    <a class="button" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= pageNo + 1 %>">다음</a>
                <% } %>
            </div>
        <% } %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
