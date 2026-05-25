<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
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

    int cafeId = post.getCafeId();
    CafeDTO cafe = new CafeDAO().selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }
    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    boolean activeMember = memberDao.isActiveMember(cafeId, currentLoginId);
    boolean manager = memberDao.isCafeManagerOrOwner(cafeId, currentLoginId);
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
<main class="page-shell community-shell">
    <%
        request.setAttribute("cafeIncludeCafe", cafe);
        request.setAttribute("cafeIncludeCafeId", Integer.valueOf(cafeId));
        request.setAttribute("cafeIncludeCurrentBoardId", Integer.valueOf(post.getBoardId()));
    %>
    <%@ include file="includes/cafeHero.jsp" %>

    <section class="cafe-layout cafe-detail-layout">
        <aside class="cafe-left">
            <%@ include file="includes/cafeSideProfile.jsp" %>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=0">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO cafeBoard : boards) { %>
                        <a class="cafe-menu-item <%= cafeBoard.getBoardId() == post.getBoardId() ? "active" : "" %>" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= cafeBoard.getBoardId() %>">
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
                        <a href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>"><%= escapeHtml(post.getCafeName()) %></a>
                        <span>&gt;</span>
                        <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= post.getBoardId() %>"><%= escapeHtml(post.getBoardName()) %></a>
                    </p>
                    <h1>게시글 수정</h1>
                </div>
                <% if ("fail".equals(request.getParameter("error"))) { %>
                    <p class="field-message is-error">게시글 수정에 실패했습니다.</p>
                <% } %>
                <form class="cafe-write-form" action="<%= contextPath %>/community/postUpdateProcess.jsp" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <label class="visually-hidden" for="title">제목</label>
                    <input id="title" class="write-title-input" name="title" maxlength="200" value="<%= escapeHtml(post.getTitle()) %>" required>
                    <label class="visually-hidden" for="content">내용</label>
                    <textarea id="content" class="write-content-area" name="content" required><%= escapeHtml(post.getContent()) %></textarea>
                    <% if (manager) { %>
                        <label class="check-row"><input type="checkbox" name="isNotice" value="Y" <%= "Y".equals(post.getIsNotice()) ? "checked" : "" %>> 공지글</label>
                    <% } %>
                    <div class="write-actions">
                        <a class="button btn-sub" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= postId %>">취소</a>
                        <button class="btn-main" type="submit">수정</button>
                    </div>
                </form>
            </section>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
