<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
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
        response.sendRedirect(request.getContextPath() + "/community/cafeDetail.jsp?cafeId=" + cafeId + "&error=noPermission");
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
                    <span class="status-badge is-active">글 작성 중</span>
                </div>
            </div>

            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">내 카페 정보</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>내 등급</span><strong><%= manager ? "관리자" : "가입중" %></strong></li>
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
                    <% for (CafeBoardDTO cafeBoard : boards) { %>
                        <a class="cafe-menu-item <%= cafeBoard.getBoardId() == boardId ? "active" : "" %>" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= cafeBoard.getBoardId() %>">
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
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <section class="cafe-main">
            <section class="cafe-write-panel">
                <div class="cafe-write-head">
                    <p class="breadcrumb">
                        <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(cafe.getCafeName()) %></a>
                        <span>&gt;</span>
                        <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>"><%= escapeHtml(board.getBoardName()) %></a>
                    </p>
                    <h1>글쓰기</h1>
                </div>
                <form class="cafe-write-form" action="<%= contextPath %>/community/postWriteProcess.jsp" method="post">
                    <input type="hidden" name="cafeId" value="<%= cafeId %>">
                    <input type="hidden" name="boardId" value="<%= boardId %>">
                    <label class="visually-hidden" for="title">제목</label>
                    <input id="title" class="write-title-input" name="title" maxlength="200" placeholder="제목을 입력하세요." required>
                    <label class="visually-hidden" for="content">내용</label>
                    <textarea id="content" class="write-content-area" name="content" placeholder="내용을 입력하세요." required></textarea>
                    <% if (manager) { %>
                        <label class="check-row"><input type="checkbox" name="isNotice" value="Y"> 공지글</label>
                    <% } %>
                    <div class="write-actions">
                        <a class="button btn-sub" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boardId %>">취소</a>
                        <button class="btn-main" type="submit">등록</button>
                    </div>
                </form>
            </section>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
