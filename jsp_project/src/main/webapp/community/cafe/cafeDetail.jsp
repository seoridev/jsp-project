<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="com.carrot.dao.CafeBoardDAO" %>
<%@ page import="com.carrot.dao.CafeCommentDAO" %>
<%@ page import="com.carrot.dao.CafeDAO" %>
<%@ page import="com.carrot.dao.CafeFavoriteDAO" %>
<%@ page import="com.carrot.dao.CafeMemberDAO" %>
<%@ page import="com.carrot.dao.CafePostDAO" %>
<%@ page import="com.carrot.dao.CafePostLikeDAO" %>
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

    private String formatCafeDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd."));
    }

    private String formatCafeRole(String role) {
        if ("OWNER".equals(role)) {
            return "스탭";
        }
        if ("MANAGER".equals(role)) {
            return "스탭";
        }
        if ("MEMBER".equals(role)) {
            return "멤버";
        }
        return role == null ? "방문자" : role;
    }

    private String formatCount(int value, String unit) {
        return String.format("%,d%s", value, unit);
    }
%>
<%
    int cafeId = parseIntParam(request.getParameter("cafeId"));
    String cafeDetailRedirect = java.net.URLEncoder.encode("/community/cafe/cafeDetail.jsp?cafeId=" + cafeId, "UTF-8");
    CafeDAO cafeDao = new CafeDAO();
    CafeDTO cafe = cafeDao.selectCafeById(cafeId);
    if (cafe == null) {
        response.sendRedirect(request.getContextPath() + "/community/cafe/cafeList.jsp?error=noCafe");
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
    String cafeImagePath = cafe.getImagePath();
    boolean hasCafeImage = cafeImagePath != null && !cafeImagePath.trim().isEmpty();
    String cafeImageUrl = hasCafeImage
            ? request.getContextPath() + (cafeImagePath.startsWith("/") ? cafeImagePath : "/" + cafeImagePath)
            : "";
    String createdDate = formatCafeDate(cafe.getCreatedAt());
    String joinedDate = myMember == null ? "" : formatCafeDate(myMember.getJoinedAt());
    String ownerDisplayName = cafe.getOwnerNickname();
    if (ownerDisplayName == null || ownerDisplayName.trim().isEmpty()) {
        ownerDisplayName = cafe.getOwnerId() == null ? "스탭" : cafe.getOwnerId();
    }

    CafePostDAO postDao = new CafePostDAO();
    List<CafeBoardDTO> boards = new CafeBoardDAO().selectBoardsByCafeId(cafeId);
    List<CafePostDTO> posts = canRead ? postDao.selectRecentPostsByCafeId(cafeId, 10) : java.util.Collections.emptyList();
    int myCafePostCount = currentLoginId != null ? postDao.countPostsByWriterInCafe(cafeId, currentLoginId) : 0;
    int myCafeCommentCount = currentLoginId != null ? new CafeCommentDAO().countCommentsByWriterInCafe(cafeId, currentLoginId) : 0;
    int myCafeLikeCount = currentLoginId != null ? new CafePostLikeDAO().countLikesByMemberInCafe(cafeId, currentLoginId) : 0;
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/app.css?v=20260525-cafe-side-profile-3">
</head>
<body>
<%@ include file="../../common/header.jsp" %>
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

    <%
        request.setAttribute("cafeIncludeCafe", cafe);
        request.setAttribute("cafeIncludeCafeId", Integer.valueOf(cafeId));
    %>
    <%@ include file="../includes/cafeHero.jsp" %>

    <section class="cafe-layout cafe-detail-layout">
        <aside class="cafe-left">
            <%@ include file="../includes/cafeSideProfile.jsp" %>

            <div class="cafe-box">
                <div class="cafe-section-title">게시판 목록</div>
                <nav class="cafe-menu-list" aria-label="카페 메뉴">
                    <a class="cafe-menu-item active" href="<%= contextPath %>/community/cafe/cafeDetail.jsp?cafeId=<%= cafeId %>">카페 홈</a>
                    <% if (!boards.isEmpty()) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=0">전체글 보기</a>
                    <% } %>
                    <% for (CafeBoardDTO board : boards) { %>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/post/postList.jsp?cafeId=<%= cafeId %>&boardId=<%= board.getBoardId() %>">
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
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/board/cafeBoardManage.jsp?cafeId=<%= cafeId %>">게시판 관리</a>
                        <a class="cafe-menu-item" href="<%= contextPath %>/community/member/cafeMemberManage.jsp?cafeId=<%= cafeId %>">회원 관리</a>
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
                        <a class="cafe-post-item <%= "Y".equals(post.getIsNotice()) ? "is-notice" : "" %>" href="<%= contextPath %>/community/post/postDetail.jsp?postId=<%= post.getPostId() %>">
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
            <a class="cafe-report-link" href="<%= contextPath %>/community/report/communityReport.jsp?targetType=CAFE&targetId=<%= cafeId %>">이 카페 신고하기</a>
        </div>
    <% } %>
</main>
<%@ include file="../../common/footer.jsp" %>
</body>
</html>
