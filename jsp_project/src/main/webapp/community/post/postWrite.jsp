<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.util.ParamParser" %>
<%@ include file="../../common/sessionCheck.jsp" %>
<%
    // 글쓰기 가능한 게시판인지 확인
    int cafeId = ParamParser.parseInt(request.getParameter("cafeId"));
    int boardId = ParamParser.parseInt(request.getParameter("boardId"));
    CafeBoardDAO boardDao = new CafeBoardDAO();
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    CafeBoardDTO board = boardDao.selectBoardById(boardId);
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = memberDao.isActiveMember(cafeId, currentLoginId);
    boolean manager = memberDao.isCafeManagerOrOwner(cafeId, currentLoginId);
    boolean canWrite = cafe != null && board != null && board.getCafeId() == cafeId
            && activeMember
            && ("MEMBER".equals(board.getWritePermission()) || manager);
    if (!canWrite) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeDetail.jsp?cafeId=" + cafeId + "&error=noPermission");
        return;
    }

    List<CafeBoardDTO> boards = boardDao.selectBoardsByCafeId(cafeId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글쓰기 | 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
<main class="page-shell community-shell">
    <%
        request.setAttribute("cafeIncludeCafe", cafe);
        request.setAttribute("cafeIncludeCafeId", Integer.valueOf(cafeId));
        request.setAttribute("cafeIncludeCurrentBoardId", Integer.valueOf(boardId));
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
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=0">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO cafeBoard : boards) { %>
                        <a class="cafe-menu-item <%= cafeBoard.getBoardId() == boardId ? "active" : "" %>" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= cafeBoard.getBoardId() %>">
                            <span><%= escapeHtml(cafeBoard.getBoardName()) %></span>
                            <span><%= cafeBoard.getPostCount() %></span>
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
            <section class="cafe-write-panel">
                <div class="cafe-write-head">
                    <h1>글쓰기</h1>
                </div>
                <form class="cafe-write-form" action="<%= contextPath %>/community/post/postWriteProcess.jsp" method="post">
                    <input type="hidden" name="cafeId" value="<%= cafeId %>">
                    <div class="write-board-row">
                        <label class="visually-hidden" for="boardSelect">게시판 선택</label>
                        <select id="boardSelect" class="write-board-select" name="boardId" required>
                            <% for (CafeBoardDTO cafeBoard : boards) {
                                boolean canSelectBoard = manager || "MEMBER".equals(cafeBoard.getWritePermission());
                                if (canSelectBoard) {
                            %>
                                <option value="<%= cafeBoard.getBoardId() %>" <%= cafeBoard.getBoardId() == boardId ? "selected" : "" %>><%= escapeHtml(cafeBoard.getBoardName()) %></option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <label class="visually-hidden" for="title">제목</label>
                    <input id="title" class="write-title-input" name="title" maxlength="200" placeholder="제목을 입력하세요." required>
                    <label class="visually-hidden" for="content">내용</label>
                    <textarea id="content" class="write-content-area" name="content" placeholder="내용을 입력하세요." required></textarea>
                    <% if (manager) { %>
                        <label class="check-row"><input type="checkbox" name="isNotice" value="Y"> 공지글</label>
                    <% } %>
                    <div class="write-actions">
                        <a class="button btn-sub" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">취소</a>
                        <button class="btn-main" type="submit">등록</button>
                    </div>
                </form>
            </section>
        </section>
    </section>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
