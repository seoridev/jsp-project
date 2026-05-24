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
    boolean manager = currentLoginId != null && memberDao.isCafeManagerOrOwner(cafeId, currentLoginId);
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;
    boolean canWrite = activeMember && ("MEMBER".equals(selectedBoard.getWritePermission()) || manager);

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
<main class="page-shell community-shell">
    <section class="cafe-gate">
        <div class="cafe-cover-band">
            <span class="cafe-cover-label"><%= escapeHtml(cafe.getCategory()) %></span>
        </div>
        <div class="cafe-gate-content">
            <div class="cafe-avatar cafe-gate-avatar"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></div>
            <div class="cafe-gate-copy">
                <div class="cafe-title-row">
                    <h1><%= escapeHtml(cafe.getCafeName()) %></h1>
                    <span class="cafe-badge"><%= escapeHtml(cafe.getVisibility()) %></span>
                </div>
                <p><%= escapeHtml(cafe.getDescription()) %></p>
                <div class="cafe-meta-line">
                    <span><%= escapeHtml(cafe.getCategory()) %></span>
                    <span><%= escapeHtml(cafe.getRegion()) %></span>
                </div>
            </div>
        </div>
    </section>

    <section class="cafe-layout cafe-detail-layout">
        <aside class="cafe-left">
            <div class="cafe-box">
                <div class="cafe-section-title">카페 활동</div>
                <div class="cafe-box-body cafe-action-stack">
                    <% if (!loggedIn) { %>
                        <a class="button btn-main" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 가입</a>
                    <% } else if (canWrite) { %>
                        <a class="button btn-main" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">글쓰기</a>
                    <% } else if (activeMember) { %>
                        <span class="status-badge is-active">가입중</span>
                    <% } else { %>
                        <a class="button btn-main" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeId %>">카페 가입</a>
                    <% } %>
                </div>
            </div>

            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">내 카페 정보</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>내 등급</span><strong><%= manager ? "관리자" : (activeMember ? "가입중" : "방문자") %></strong></li>
                        <li><span>지역</span><strong><%= escapeHtml(cafe.getRegion()) %></strong></li>
                        <li><span>공개</span><strong><%= escapeHtml(cafe.getVisibility()) %></strong></li>
                    </ul>
                </div>
            </div>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boards.get(0).getBoardId() %>">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item <%= board.getBoardId() == boardId ? "active" : "" %>" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
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
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <section class="cafe-main">
            <div class="cafe-box">
                <div class="cafe-section-title">
                    <span><%= escapeHtml(selectedBoard.getBoardName()) %></span>
                    <% if (canWrite) { %>
                        <a class="button btn-main btn-small" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">글쓰기</a>
                    <% } %>
                </div>
                <div class="cafe-box-body">
                    <p class="community-meta"><%= escapeHtml(selectedBoard.getDescription()) %></p>
                </div>
                <form class="board-search-bar" action="<%= contextPath %>/community/postList.jsp" method="get">
                    <strong>글 검색</strong>
                    <input type="hidden" name="cafeId" value="<%= cafeId %>">
                    <input type="hidden" name="boardId" value="<%= boardId %>">
                    <input type="hidden" name="page" value="1">
                    <input name="keyword" placeholder="제목 또는 내용 검색" value="<%= escapeHtml(keyword) %>">
                    <button class="btn-sub btn-small" type="submit">검색</button>
                </form>

                <% if ("success".equals(request.getParameter("delete"))) { %>
                    <p class="field-message is-success">게시글이 삭제되었습니다.</p>
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
                                    <td class="post-title-cell"><a href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>"><%= escapeHtml(post.getTitle()) %></a></td>
                                    <td><%= escapeHtml(post.getWriterNickname()) %></td>
                                    <td><%= post.getViewCount() %></td>
                                    <td><%= post.getCommentCount() %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <div class="pagination">
                        <% if (pageNo > 1) { %>
                            <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= pageNo - 1 %>">이전</a>
                        <% } %>
                        <span class="community-meta"><%= pageNo %> / <%= totalPages %> 페이지 · 총 <%= totalCount %>개</span>
                        <% if (pageNo < totalPages) { %>
                            <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>&keyword=<%= keywordParam %>&page=<%= pageNo + 1 %>">다음</a>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
