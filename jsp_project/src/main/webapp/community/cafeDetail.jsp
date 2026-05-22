<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dto.CafeBoardDTO" %>
<%@ page import="com.carrot.dto.CafeDTO" %>
<%@ page import="com.carrot.dto.CafeMemberDTO" %>
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
    CafeDAO cafeDao = new CafeDAO();
    CafeDTO cafe = cafeDao.selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafeList.jsp?error=noCafe");
        return;
    }

    String currentLoginId = (String) session.getAttribute("loginId");
    CafeMemberDAO memberDao = new CafeMemberDAO();
    CafeMemberDTO myMember = currentLoginId == null ? null : memberDao.selectCafeMember(cafeId, currentLoginId);
    boolean activeMember = myMember != null && "ACTIVE".equals(myMember.getStatus());
    boolean pendingMember = myMember != null && "PENDING".equals(myMember.getStatus());
    boolean ownerOrManager = myMember != null && "ACTIVE".equals(myMember.getStatus())
            && ("OWNER".equals(myMember.getRole()) || "MANAGER".equals(myMember.getRole()));
    boolean canRead = "PUBLIC".equals(cafe.getVisibility()) || activeMember;

    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
    List<CafePostDTO> posts = canRead ? new CafePostDAO().selectRecentPostsByCafeId(cafeId, 10) : java.util.Collections.emptyList();
    int writeBoardId = 0;
    if (activeMember) {
        for (CafeBoardDTO board : boards) {
            if (ownerOrManager || "MEMBER".equals(board.getWritePermission())) {
                writeBoardId = board.getBoardId();
                break;
            }
        }
    }
    cafeDao.increaseViewCount(cafeId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escapeHtml(cafe.getCafeName()) %> | 동네마켓 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell">
    <section class="detail-panel">
        <% if ("success".equals(request.getParameter("created"))) { %>
            <p class="field-message is-success">카페가 생성되었습니다.</p>
        <% } else if ("active".equals(request.getParameter("join"))) { %>
            <p class="field-message is-success">카페에 가입되었습니다.</p>
        <% } else if ("pending".equals(request.getParameter("join"))) { %>
            <p class="field-message">가입 신청이 접수되었습니다.</p>
        <% } else if ("banned".equals(request.getParameter("join"))) { %>
            <p class="field-message is-error">이 카페에서는 가입이 제한된 상태입니다.</p>
        <% } else if ("manageDenied".equals(request.getParameter("error"))) { %>
            <p class="field-message is-error">카페 관리 권한이 없습니다.</p>
        <% } %>
        <div class="detail-header">
            <div>
                <p class="eyebrow"><%= escapeHtml(cafe.getRegion()) %> · <%= escapeHtml(cafe.getCategory()) %></p>
                <h1><%= escapeHtml(cafe.getCafeName()) %></h1>
                <p><%= escapeHtml(cafe.getDescription()) %></p>
                <p class="community-meta">회원 <%= cafe.getMemberCount() %> · 글 <%= cafe.getPostCount() %> · 조회 <%= cafe.getViewCount() %></p>
            </div>
            <div class="form-actions">
                <% if (!loggedIn) { %>
                    <a class="button primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 가입</a>
                <% } else if (activeMember) { %>
                    <span class="status-badge is-active"><%= escapeHtml(myMember.getRole()) %></span>
                <% } else if (pendingMember) { %>
                    <span class="status-badge is-stopped">승인 대기</span>
                <% } else { %>
                    <a class="button primary" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeId %>">카페 가입</a>
                <% } %>
            </div>
        </div>
    </section>

    <section class="home-layout" style="align-items:start;">
        <aside class="status-panel">
            <h2>게시판</h2>
            <div class="community-tabs">
                <% for (CafeBoardDTO board : boards) { %>
                    <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                        <%= escapeHtml(board.getBoardName()) %> (<%= board.getPostCount() %>)
                    </a>
                <% } %>
            </div>
            <% if (writeBoardId > 0) { %>
                <a class="button primary" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= writeBoardId %>">글쓰기</a>
            <% } %>
            <% if (ownerOrManager) { %>
                <a class="button" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
            <% } %>
        </aside>

        <section class="detail-panel">
            <h2>최근 글</h2>
            <% if (!canRead) { %>
                <p class="empty-cell">비공개 카페입니다. 가입 후 글을 볼 수 있습니다.</p>
            <% } else if (posts.isEmpty()) { %>
                <p class="empty-cell">아직 작성된 글이 없습니다.</p>
            <% } else { %>
                <div class="community-list">
                    <% for (CafePostDTO post : posts) { %>
                        <a class="community-row" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <span><strong><%= escapeHtml(post.getTitle()) %></strong><br><small class="community-meta"><%= escapeHtml(post.getBoardName()) %> · <%= escapeHtml(post.getWriterNickname()) %></small></span>
                            <span class="community-meta">댓글 <%= post.getCommentCount() %></span>
                        </a>
                    <% } %>
                </div>
            <% } %>
            <% if (ownerOrManager) { %>
                <p class="community-meta">회원 관리는 다음 단계에서 확장 예정입니다.</p>
            <% } %>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
