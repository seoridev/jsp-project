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
    String cafeDetailRedirect = java.net.URLEncoder.encode("/community/cafeDetail.jsp?cafeId=" + cafeId, "UTF-8");
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
    <% if ("success".equals(request.getParameter("created"))) { %>
        <p class="notice-toast">카페가 생성되었습니다.</p>
    <% } else if ("active".equals(request.getParameter("join"))) { %>
        <p class="notice-toast">카페에 가입되었습니다.</p>
    <% } else if ("pending".equals(request.getParameter("join"))) { %>
        <p class="field-message">가입 요청이 접수되었습니다.</p>
    <% } else if ("success".equals(request.getParameter("leave"))) { %>
        <p class="notice-toast">카페에서 탈퇴했습니다.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="field-message is-error">요청을 처리하지 못했습니다.</p>
    <% } %>

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
                    <% if (loggedIn) { %>
                        <form class="cafe-title-favorite-form" action="<%= contextPath %>/community/cafeFavoriteProcess.jsp" method="post">
                            <input type="hidden" name="cafeId" value="<%= cafeId %>">
                            <button class="cafe-favorite-toggle <%= favoriteCafe ? "is-active" : "" %>" type="submit" aria-label="<%= favoriteCafe ? "즐겨찾기 해제" : "즐겨찾기" %>">
                                <%= favoriteCafe ? "★" : "☆" %>
                            </button>
                        </form>
                    <% } else { %>
                        <a class="cafe-favorite-toggle" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeDetailRedirect %>" aria-label="로그인 후 즐겨찾기">☆</a>
                    <% } %>
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
            <% if (!activeMember || !"OWNER".equals(myMember.getRole())) { %>
                <div class="cafe-box">
                    <div class="cafe-section-title">카페 활동</div>
                    <div class="cafe-box-body cafe-action-stack">
                        <% if (!loggedIn) { %>
                            <a class="button btn-main" href="<%= contextPath %>/member/login.jsp?error=loginRequired&amp;redirect=<%= cafeDetailRedirect %>">로그인 후 가입</a>
                        <% } else if (pendingMember) { %>
                            <span class="status-badge is-stopped">승인 대기</span>
                        <% } else if (!activeMember) { %>
                            <a class="button btn-main" href="<%= contextPath %>/community/cafeJoinProcess.jsp?cafeId=<%= cafeId %>">카페 가입</a>
                        <% } else { %>
                            <form action="<%= contextPath %>/community/cafeLeaveProcess.jsp" method="post" onsubmit="return confirm('카페에서 탈퇴하시겠습니까?');">
                                <input type="hidden" name="cafeId" value="<%= cafeId %>">
                                <button class="btn-danger btn-small" type="submit">카페 탈퇴</button>
                            </form>
                        <% } %>
                    </div>
                </div>
            <% } %>

            <div class="cafe-box cafe-info-box">
                <div class="cafe-section-title">내 카페 정보</div>
                <div class="cafe-box-body">
                    <ul class="cafe-stat-list">
                        <li><span>내 등급</span><strong><%= activeMember ? escapeHtml(myMember.getRole()) : (pendingMember ? "승인 대기" : "방문자") %></strong></li>
                        <li><span>지역</span><strong><%= escapeHtml(cafe.getRegion()) %></strong></li>
                        <li><span>공개</span><strong><%= escapeHtml(cafe.getVisibility()) %></strong></li>
                    </ul>
                    <% if (activeMember && writeBoardId > 0) { %>
                        <a class="button btn-main cafe-info-write" href="<%= contextPath %>/community/postWrite.jsp?cafeId=<%= cafeId %>&boardId=<%= writeBoardId %>">글쓰기</a>
                    <% } %>
                </div>
            </div>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item active" href="<%= contextPath %>/community/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= boards.get(0).getBoardId() %>">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
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
                        <li><span>조회</span><strong><%= cafe.getViewCount() + 1 %></strong></li>
                    </ul>
                </div>
            </div>
            <% if (ownerOrManager) { %>
                <div class="cafe-box">
                    <div class="cafe-section-title">관리 메뉴</div>
                    <nav class="cafe-menu-list">
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
                    </nav>
                </div>
            <% } %>
        </aside>

        <section class="cafe-main cafe-box">
            <div class="cafe-section-title">
                <span>최근 글</span>
            </div>
            <% if (!canRead) { %>
                <div class="cafe-private-guide">
                    <strong>비공개 카페입니다.</strong>
                    <p>가입 후 글을 볼 수 있습니다.</p>
                </div>
            <% } else if (posts.isEmpty()) { %>
                <p class="empty-cell">아직 작성된 글이 없습니다.</p>
            <% } else { %>
                <div class="cafe-post-list">
                    <% for (CafePostDTO post : posts) { %>
                        <a class="cafe-post-item <%= "Y".equals(post.getIsNotice()) ? "is-notice" : "" %>" href="<%= contextPath %>/community/postDetail.jsp?postId=<%= post.getPostId() %>">
                            <span class="<%= "Y".equals(post.getIsNotice()) ? "notice-badge" : "board-badge is-normal" %>"><%= "Y".equals(post.getIsNotice()) ? "공지" : "일반" %></span>
                            <span class="cafe-post-board"><%= escapeHtml(post.getBoardName()) %></span>
                            <span class="cafe-post-title"><%= escapeHtml(post.getTitle()) %></span>
                            <span class="cafe-post-author"><%= escapeHtml(post.getWriterNickname()) %></span>
                            <span class="cafe-post-comments">댓글 <%= post.getCommentCount() %></span>
                        </a>
                    <% } %>
                </div>
            <% } %>
        </section>
    </section>
    <% if (loggedIn) { %>
        <div class="cafe-report-row">
            <a class="cafe-report-link" href="<%= contextPath %>/community/communityReport.jsp?targetType=CAFE&targetId=<%= cafeId %>">이 카페 신고하기</a>
        </div>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
