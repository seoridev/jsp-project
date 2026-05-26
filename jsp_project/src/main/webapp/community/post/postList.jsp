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
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
        return;
    }

    CafeBoardDAO boardDao = new CafeBoardDAO();
    List<CafeBoardDTO> boards = boardDao.selectBoardsByCafeId(cafeId);
    boolean allBoards = boardId <= 0;
    CafeBoardDTO selectedBoard = allBoards ? null : boardDao.selectBoardById(boardId);
    if (!allBoards && (selectedBoard == null || selectedBoard.getCafeId() != cafeId)) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId);
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = currentLoginId != null && memberDao.isActiveMember(cafeId, currentLoginId);
    boolean manager = currentLoginId != null && memberDao.isCafeManagerOrOwner(cafeId, currentLoginId);
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;
    int writeBoardId = 0;
    if (activeMember) {
        for (CafeBoardDTO board : boards) {
            if (manager || "MEMBER".equals(board.getWritePermission())) {
                writeBoardId = board.getBoardId();
                break;
            }
        }
    }
    boolean canWrite = allBoards
            ? writeBoardId > 0
            : activeMember && ("MEMBER".equals(selectedBoard.getWritePermission()) || manager);

    CafePostDAO postDao = new CafePostDAO();
    int totalCount = canRead ? postDao.countPosts(cafeId, boardId, keyword) : 0;
    int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) pageSize));
    if (pageNo > totalPages) {
        pageNo = totalPages;
    }
    List<CafePostDTO> posts = canRead ? postDao.selectPosts(cafeId, boardId, keyword, pageNo, pageSize) : java.util.Collections.emptyList();
    String postListRedirect = "/community/post/postList.jsp?cafeId=" + cafeId + "&boardId=" + boardId + "&page=" + pageNo;
    if (keyword != null && !keyword.trim().isEmpty()) {
        postListRedirect += "&keyword=" + keywordParam;
    }
    String encodedPostListRedirect = java.net.URLEncoder.encode(postListRedirect, "UTF-8");
    int pageBlockSize = 10;
    int pageBlockStart = ((pageNo - 1) / pageBlockSize) * pageBlockSize + 1;
    int pageBlockEnd = Math.min(pageBlockStart + pageBlockSize - 1, totalPages);
    int prevBlockPage = pageBlockStart - pageBlockSize;
    int nextBlockPage = pageBlockEnd + 1;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= allBoards ? "전체글 보기" : escapeHtml(selectedBoard.getBoardName()) %> | <%= escapeHtml(cafe.getCafeName()) %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="page-shell community-shell">
    <%
        request.setAttribute("cafeIncludeCafe", cafe);
        request.setAttribute("cafeIncludeCafeId", Integer.valueOf(cafeId));
        request.setAttribute("cafeIncludeCurrentBoardId", Integer.valueOf(allBoards ? 0 : boardId));
    %>
    <%@ include file="../includes/cafeHero.jsp" %>

    <section class="cafe-layout cafe-detail-layout">
        <aside class="cafe-left">
            <%@ include file="../includes/cafeSideProfile.jsp" %>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item <%= allBoards ? "active" : "" %>" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=0">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item <%= board.getBoardId() == boardId ? "active" : "" %>" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                            <span><%= escapeHtml(board.getBoardName()) %></span>
                            <span><%= board.getPostCount() %></span>
                        </a>
                    <% } %>
                </nav>
            </div>
            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">카페 통계</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>회원</span><strong><%= cafe.getMemberCount() %></strong></li>
                        <li><span>게시글</span><strong><%= cafe.getPostCount() %></strong></li>
                        <li><span>조회</span><strong><%= cafe.getViewCount() %></strong></li>
                    </ul>
                </div>
            </div>
            <% if (manager) { %>
                <div class="cafe-box">
                    <div class="cafe-section-title">관리 메뉴</div>
                    <nav class="cafe-menu-list">
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/board/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/member/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <section class="cafe-main">
            <div class="cafe-box">
                <div class="cafe-section-title">
                    <span><%= allBoards ? "전체글 보기" : escapeHtml(selectedBoard.getBoardName()) %></span>
                    <% if (canWrite) { %>
                        <a class="button btn-main btn-small" href="<%= contextPath %>/community/post/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= allBoards ? writeBoardId : boardId %>">글쓰기</a>
                    <% } %>
                </div>
                <div class="cafe-box-body">
                    <p class="community-meta"><%= allBoards ? "카페에 올라온 모든 게시글입니다." : escapeHtml(selectedBoard.getDescription()) %></p>
                </div>
                <% if ("success".equals(request.getParameter("delete"))) { %>
                    <p class="notice-toast">게시글이 삭제되었습니다.</p>
                <% } %>
                <% if (!canRead) { %>
                    <p class="empty-cell">비공개 카페입니다. 가입 후 글을 볼 수 있습니다.</p>
                <% } else if (posts.isEmpty()) { %>
                    <p class="empty-cell">게시글이 없습니다.</p>
                <% } else { %>
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
                                <th>작성자</th>
                                <th>조회</th>
                                <th>댓글</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (CafePostDTO post : posts) { %>
                                <tr>
                                    <td><span class="<%= "Y".equals(post.getIsNotice()) ? "notice-badge" : "board-badge is-normal" %>"><%= "Y".equals(post.getIsNotice()) ? "공지" : "일반" %></span></td>
                                    <td class="post-title-cell"><a href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                                    <td><%= escapeHtml(post.getWriterNickname()) %></td>
                                    <td><%= post.getViewCount() %></td>
                                    <td><%= post.getCommentCount() %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <form class="board-search-bar" action="<%= contextPath %>/community/post/postList.jsp" method="get">
                        <strong>글 검색</strong>
                        <input type="hidden" name="cafeId" value="<%= cafeId %>">
                        <input type="hidden" name="boardId" value="<%= boardId %>">
                        <input type="hidden" name="page" value="1">
                        <input name="keyword" placeholder="제목 또는 내용 검색" value="<%= escapeHtml(keyword) %>">
                        <button class="btn-sub btn-small" type="submit">검색</button>
                    </form>
                    <div class="pagination">
                        <% if (prevBlockPage >= 1) { %>
                            <a href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= prevBlockPage %>">이전</a>
                        <% } else { %>
                            <span class="is-disabled">이전</span>
                        <% } %>
                        <% for (int pageIndex = pageBlockStart; pageIndex <= pageBlockEnd; pageIndex++) { %>
                            <a class="<%= pageIndex == pageNo ? "is-current" : "" %>" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= pageIndex %>"><%= pageIndex %></a>
                        <% } %>
                        <% if (nextBlockPage <= totalPages) { %>
                            <a href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= nextBlockPage %>">다음</a>
                        <% } else { %>
                            <span class="is-disabled">다음</span>
                        <% } %>
                    </div>
                    <p class="community-meta board-result-count">총 <%= totalCount %>개</p>
                <% } %>
            </div>
        </section>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
