<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
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
    boolean ownerOrManager = activeMember && ("OWNER".equals(myMember.getRole()) || "MANAGER".equals(myMember.getRole()));
    boolean favoriteCafe = currentLoginId != null && new CafeFavoriteDAO().existsFavorite(cafeId, currentLoginId);
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
    <title><%= escapeHtml(cafe.getCafeName()) %> | 커뮤니티</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css">
</head>
<body>
<%@ include file="../common/header.jsp" %>
<main class="page-shell community-shell">
    <section class="cafe-profile-hero">
        <% if ("success".equals(request.getParameter("created"))) { %>
            <p class="field-message is-success">카페가 생성되었습니다.</p>
        <% } else if ("active".equals(request.getParameter("join"))) { %>
            <p class="field-message is-success">카페에 가입되었습니다.</p>
        <% } else if ("pending".equals(request.getParameter("join"))) { %>
            <p class="field-message">가입 신청이 접수되었습니다.</p>
        <% } else if ("success".equals(request.getParameter("leave"))) { %>
            <p class="field-message is-success">카페에서 탈퇴했습니다.</p>
        <% } else if (request.getParameter("error") != null) { %>
            <p class="field-message is-error">요청을 처리하지 못했습니다.</p>
        <% } %>
        <div class="cafe-cover cover-tone-<%= cafe.getCafeId() % 4 %>"></div>
        <div class="cafe-profile-content">
            <div class="cafe-avatar"><%= escapeHtml(cafe.getCafeName()).isEmpty() ? "C" : escapeHtml(cafe.getCafeName()).substring(0, 1) %></div>
            <div class="cafe-title-row">
                <div>
                    <span class="community-badge"><%= escapeHtml(cafe.getCategory()) %></span>
                    <h1><%= escapeHtml(cafe.getCafeName()) %></h1>
                    <p><%= escapeHtml(cafe.getDescription()) %></p>
                </div>
                <% if (activeMember) { %>
                    <span class="status-badge is-active"><%= escapeHtml(myMember.getRole()) %></span>
                <% } else if (pendingMember) { %>
                    <span class="status-badge is-stopped">승인 대기</span>
                <% } %>
            </div>
            <div class="cafe-stat-grid">
                <div><span>지역</span><strong><%= escapeHtml(cafe.getRegion()) %></strong></div>
                <div><span>회원</span><strong><%= cafe.getMemberCount() %></strong></div>
                <div><span>글</span><strong><%= cafe.getPostCount() %></strong></div>
                <div><span>조회</span><strong><%= cafe.getViewCount() + 1 %></strong></div>
            </div>
        </div>
    </section>

    <section class="community-two-column">
        <aside class="cafe-action-card">
            <h2>카페 활동</h2>
            <div class="form-actions">
                <% if (!loggedIn) { %>
                    <a class="button btn-primary" href="<%= contextPath %>/member/login.jsp?error=loginRequired">로그인 후 가입</a>
                <% } else if (activeMember && writeBoardId > 0) { %>
                    <a class="button btn-primary" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= writeBoardId %>">글쓰기</a>
                <% } else if (!pendingMember) { %>
                    <a class="button btn-primary" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeId %>">카페 가입</a>
                <% } %>
                <% if (loggedIn) { %>
                    <form action="<%= contextPath %>/community/cafeFavoriteProcess.jsp" method="post">
                        <input type="hidden" name="cafeId" value="<%= cafeId %>">
                        <button class="btn-secondary" type="submit"><%= favoriteCafe ? "즐겨찾기 해제" : "즐겨찾기" %></button>
                    </form>
                    <a class="button btn-ghost" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE&targetId=<%= cafeId %>">신고</a>
                <% } %>
                <% if (activeMember && !"OWNER".equals(myMember.getRole())) { %>
                    <form action="<%= contextPath %>/community/cafeLeaveProcess.jsp" method="post" onsubmit="return confirm('Leave this cafe?');">
                        <input type="hidden" name="cafeId" value="<%= cafeId %>">
                        <button class="btn-danger" type="submit">카페 탈퇴</button>
                    </form>
                <% } %>
                <% if (ownerOrManager) { %>
                    <a class="button btn-secondary" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                    <a class="button btn-secondary" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                <% } %>
            </div>
            <h2>게시판</h2>
            <div class="community-tabs vertical">
                <% for (CafeBoardDTO board : boards) { %>
                    <a href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
                        <%= escapeHtml(board.getBoardName()) %> <span><%= board.getPostCount() %></span>
                    </a>
                <% } %>
            </div>
        </aside>

        <section class="community-section">
            <div class="section-title-row">
                <h2>최근 글</h2>
            </div>
            <% if (!canRead) { %>
                <p class="empty-cell">비공개 카페입니다. 가입 후 글을 볼 수 있습니다.</p>
            <% } else if (posts.isEmpty()) { %>
                <p class="empty-cell">아직 작성된 글이 없습니다.</p>
            <% } else { %>
                <div class="post-feed-list">
                    <% for (CafePostDTO post : posts) { %>
                        <a class="post-feed-item" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <div class="post-title-row">
                                <% if ("Y".equals(post.getIsNotice())) { %><span class="notice-badge">공지</span><% } %>
                                <strong><%= escapeHtml(post.getTitle()) %></strong>
                            </div>
                            <div class="post-meta">
                                <span><%= escapeHtml(post.getBoardName()) %></span>
                                <span><%= escapeHtml(post.getWriterNickname()) %></span>
                                <span>댓글 <%= post.getCommentCount() %>개</span>
                            </div>
                        </a>
                    <% } %>
                </div>
            <% } %>
        </section>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
